#!/usr/bin/env python3
"""按 packages.toml 生成 Homebrew formula。

  render-formula.py <packages.toml> <输出目录>

只处理带 `[source.brew]` 的项目，每个取它最新的正式版，从那次 release 下
SHA256SUMS，按里面的校验和拼出 `<包名>.rb`。

装的是发布好的二进制，不是从源码编：brew 从源码编得先有 Rust 工具链，而这些
工具里就有一个是用来装工具链的，那个顺序是反的。

各项目在 Gitee 上有镜像仓库的话，附件地址会多写一条 `mirror`：GitHub 下不动时
brew 自己会去试它，国内不用改任何配置。
"""

import json
import sys
import tempfile
import urllib.error
import urllib.request
from pathlib import Path

import manifest

GITEE = "https://gitee.com"

# 附件名的约定：`<包名>-<target>.tar.gz`，跟各项目 release workflow 的构建矩阵
# 一一对应。少了哪个平台就不渲染那一块，不是错——有的项目可能只发 Linux。
PLATFORMS = [
    ("on_macos", "on_arm", "aarch64-apple-darwin"),
    ("on_macos", "on_intel", "x86_64-apple-darwin"),
    ("on_linux", "on_arm", "aarch64-unknown-linux-musl"),
    ("on_linux", "on_intel", "x86_64-unknown-linux-musl"),
]


def class_name(pkg: str) -> str:
    """包名转 formula 的类名，照 Homebrew 的规矩：按分隔符切开，每段首字母大写。"""
    return "".join(p.capitalize() for p in pkg.replace("_", "-").split("-") if p)


class _Stay(urllib.request.HTTPRedirectHandler):
    """别跟 302。仓库在不在，Gitee 自己那一跳就答完了，没必要再跑一趟别处。"""

    def redirect_request(self, *_args, **_kw):
        return None


_opener = urllib.request.build_opener(_Stay)


def on_gitee(repo: str) -> bool:
    """这个项目在 Gitee 上有没有镜像仓库。

    判死不判活：只有明确 404 才算没有，超时、限流、连不上一律当有。多写一条
    mirror 的代价约等于零——brew 只在 url 下不动时才去试它，试到 404 和压根没写
    是同一个结局；漏写一条的代价是国内用户装不上。两边不对等，就往有的那边偏。
    """
    req = urllib.request.Request(f"{GITEE}/{repo}", method="HEAD")
    try:
        with _opener.open(req, timeout=10):
            return True
    except urllib.error.HTTPError as e:
        return e.code != 404
    except (urllib.error.URLError, OSError):
        return True


def gitee_mirrors(repo: str, tag: str, assets: list[str]) -> dict[str, str]:
    """这些附件在 Gitee 镜像上的直链，按附件名索引；没有镜像仓库就一条不写。

    探的是仓库在不在，而不是每个附件在不在。后者看着更准，实际是个必然探空的
    判据：各项目的 sync-gitee 在推 tag 那一刻就跑了（那时附件还在构建），release
    附件要等下一轮同步才到 Gitee，而本仓库是发版后几十秒被 dispatch 过来重渲染的。
    于是每个新版本第一次渲染一条 mirror 都写不出来，要等两小时后的定时重建才补上
    ——偏偏发版后那两小时正是人去 upgrade 的时候，而走到这条路上的人没有别的退路。

    写在同步前面是安全的：brew 只在 url 下不动时才去读 mirror，指到一个还没同步
    完的附件和压根没写这一行是同一个结局。附件同步上去之后，formula 不用重渲染
    就自己成立了。

    不问 `/api/v5`：那个 API 匿名限流很紧，几次调用就开始回 403 且一黏好一阵，而
    「被限流」和「还没同步」在返回里分不开（它对没同步的 tag 回的是 200 加一个裸
    `null`，连状态码都指望不上）。
    """
    if not on_gitee(repo):
        return {}
    return {name: f"{GITEE}/{repo}/releases/download/{tag}/{name}" for name in assets}


def render(
    source: dict, tag: str, checksums: dict[str, str], mirrors: dict[str, str]
) -> str | None:
    pkg = manifest.name_of(source)
    brew = source["brew"]
    version = tag.lstrip("vV")
    base = f"https://github.com/{source['repo']}/releases/download/{tag}"
    binary = brew.get("bin", pkg)

    # 按操作系统归组，组内再按架构——formula 的 on_macos/on_linux 是嵌套的。
    groups: dict[str, list[tuple[str, str]]] = {}
    for os_blk, arch_blk, target in PLATFORMS:
        asset = f"{pkg}-{target}.tar.gz"
        if asset in checksums:
            groups.setdefault(os_blk, []).append((arch_blk, asset))
    if not groups:
        return None

    body = []
    for os_blk, arches in groups.items():
        body.append(f"  {os_blk} do")
        for arch_blk, asset in arches:
            body.append(f"    {arch_blk} do")
            body.append(f'      url "{base}/{asset}"')
            # 镜像是整仓同步过去的，两边字节一致，所以共用下面那一行 sha256 ——
            # 万一哪天不一致了，brew 会在校验上停住，而不是装上一个来历不明的包。
            if asset in mirrors:
                body.append(f'      mirror "{mirrors[asset]}"')
            body.append(f'      sha256 "{checksums[asset]}"')
            body.append("    end")
        body.append("  end")
        body.append("")

    # --version 必查：它同时验证了装进去的是不是 formula 声明的那一版。
    tests = [
        f'    assert_match version.to_s, shell_output("#{{bin}}/{binary} --version")'
    ]
    for args, expect in brew.get("checks", []):
        tests.append(
            f'    assert_match {json.dumps(expect)}, '
            f'shell_output("#{{bin}}/{binary} {args}")'
        )

    return "\n".join([
        f"class {class_name(pkg)} < Formula",
        f'  desc "{brew["desc"]}"',
        f'  homepage "https://github.com/{source["repo"]}"',
        f'  version "{version}"',
        f'  license "{brew.get("license", "MIT")}"',
        "",
        *body,
        "  def install",
        f'    bin.install "{binary}"',
        "  end",
        "",
        "  test do",
        *tests,
        "  end",
        "end",
        "",
    ])


def main() -> int:
    sources = [s for s in manifest.load(sys.argv[1]) if "brew" in s]
    outdir = Path(sys.argv[2])
    outdir.mkdir(parents=True, exist_ok=True)

    wrote = 0
    with tempfile.TemporaryDirectory() as tmp:
        for s in sources:
            pkg = manifest.name_of(s)
            tags = manifest.selected(s)
            if not tags:
                print(f"  {pkg}: 没有够格的 release，跳过")
                continue
            # tap 里一个包只有一份 formula，只能是最新版。想装旧版走 apt。
            tag = tags[0]
            checksums = manifest.fetch_sums(s["repo"], tag, Path(tmp))
            want = [f"{pkg}-{t}.tar.gz" for *_, t in PLATFORMS if f"{pkg}-{t}.tar.gz" in checksums]
            mirrors = gitee_mirrors(s["repo"], tag, want)
            text = render(s, tag, checksums, mirrors)
            if text is None:
                print(f"  {pkg} {tag}: 附件里没有能用的二进制包，跳过")
                continue
            (outdir / f"{pkg}.rb").write_text(text)
            print(f"  {pkg} {tag}: 已生成（Gitee 镜像 {'有' if mirrors else '无'}）")
            wrote += 1

    if sources and not wrote:
        print("一个 formula 都没生成", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
