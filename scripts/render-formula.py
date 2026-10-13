#!/usr/bin/env python3
"""按 packages.toml 生成 Homebrew formula。

  render-formula.py <packages.toml> <输出目录>

只处理带 `[source.brew]` 的项目，每个取它最新的正式版，从那次 release 下
SHA256SUMS，按里面的校验和拼出 `<包名>.rb`。

装的是发布好的二进制，不是从源码编：brew 从源码编得先有 Rust 工具链，而这些
工具里就有一个是用来装工具链的，那个顺序是反的。
"""

import json
import subprocess
import sys
import tempfile
from pathlib import Path

import manifest

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


def sums(path: Path) -> dict[str, str]:
    """读 SHA256SUMS。二进制模式的行是 `hash *name`，把那个星号去掉。"""
    out = {}
    for line in path.read_text().splitlines():
        parts = line.split()
        if len(parts) == 2 and len(parts[0]) == 64:
            out[parts[1].lstrip("*")] = parts[0]
    return out


def fetch_sums(repo: str, tag: str, into: Path) -> dict[str, str]:
    r = subprocess.run(
        [
            "gh", "release", "download", tag, "--repo", repo,
            "--pattern", "SHA256SUMS", "--dir", str(into), "--clobber",
        ],
        capture_output=True, text=True,
    )
    if r.returncode != 0:
        return {}
    return sums(into / "SHA256SUMS")


def render(source: dict, tag: str, checksums: dict[str, str]) -> str | None:
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
            checksums = fetch_sums(s["repo"], tag, Path(tmp))
            text = render(s, tag, checksums)
            if text is None:
                print(f"  {pkg} {tag}: 附件里没有能用的二进制包，跳过")
                continue
            (outdir / f"{pkg}.rb").write_text(text)
            print(f"  {pkg} {tag}: 已生成")
            wrote += 1

    if sources and not wrote:
        print("一个 formula 都没生成", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
