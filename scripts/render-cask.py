#!/usr/bin/env python3
"""按 packages.toml 生成 Homebrew cask。

  render-cask.py <packages.toml> <输出目录>

只处理带 `[source.cask]` 的项目，每个取它最新的正式版，从那次 release 下
SHA256SUMS，按里面的校验和拼出 `<包名>.rb`。附件名按约定认
`<应用名>-<版本>-macos-<架构>.dmg` —— 注意前缀是应用的显示名（`FunClash`），
不是包名（`funclash`，Debian 要求小写），两者在桌面应用上通常不一样。

为什么不跟 render-formula.py 合成一个：两边的输入、输出和 DSL 都不一样。formula
装的是 `<包名>-<target>.tar.gz` 里的一个二进制，cask 装的是 DMG 里的一个 `.app`；
formula 用嵌套的 `on_macos`/`on_arm` 块并带一个 `test do`，cask 用 `arch` 加两分支
的 `sha256` 且没有 test 块；formula 两个系统四个架构都发，cask 只有 macOS。塞进
一个脚本等于两套逻辑共用一个名字。

**cask 没有 Gitee 回落。** Cask 的 `url` 不认 `mirror` —— 那是 Formula 的 DSL，
cask 的 `url` 只收 `using:`/`header:` 这类参数。所以 render-formula.py
里那一整套「GitHub 下不动就去 Gitee」在这儿无从写起。`brew tap` 那一步还是能从
Gitee 的镜像仓库来（cask 文件本身在 git 里，sync-gitee 整仓搬过去），但 DMG 只能
从 GitHub 下。CI 的 verify-brew-gitee 因此不覆盖 cask：它按 `--brew` 遍历，cask
天然不在里面，不是漏了。

`url` 不写 `verified:`：下载地址就挂在 `homepage` 底下，Homebrew 自己会认，显式
写反而是被废弃的参数。`depends_on macos:` 同理只给符号（`:monterey` 本身就是
「这个版本或更新」），字符串比较那种写法也废弃了。
"""

import sys
import tempfile
from pathlib import Path

import manifest

# 左边是 cask `arch` 关键字里的名字，右边是附件名和 sha256 分支里那一段。
ARCHES = [("arm", "arm64"), ("intel", "amd64")]

# 应用没开沙箱时数据就在 ~/Library 下按 bundle id 放，四个位置是 macOS 的固定
# 去处，不用每个项目各写一遍。`brew uninstall --zap` 清的是这些。
ZAP_DIRS = [
    "~/Library/Application Support/{bundle}",
    "~/Library/Caches/{bundle}",
    "~/Library/Preferences/{bundle}.plist",
    "~/Library/Saved Application State/{bundle}.savedState",
]


def render(source: dict, tag: str, checksums: dict[str, str]) -> str | None:
    pkg = manifest.name_of(source)
    cask = source["cask"]
    app = cask["app"]
    version = tag.lstrip("vV")
    # tag 前面那截（通常是 "v"）留成字面量，版本号用 `#{version}` 插值：cask 的
    # 惯例是 url 里不写死版本，而 tag 要不要带 v 是各项目自己的事，不能假设。
    prefix = tag[: len(tag) - len(version)]

    assets = {arch: f"{app}-{version}-macos-{arch}.dmg" for _, arch in ARCHES}
    missing = sorted(a for a in assets.values() if a not in checksums)
    # 两个架构缺一个就不出：`arch` + 两分支 `sha256` 是成对的写法，少一边得换成
    # 另一种单架构写法。真缺了更可能是构建矩阵出了岔子，不该悄悄发一个半截的 cask。
    if missing:
        print(f"  {pkg} {tag}: 附件里缺 {', '.join(missing)}，跳过")
        return None

    # `sha256 arm:` / `intel:` 两行的键名右对齐，照 homebrew/cask 里的排版。
    pad = max(len(key) for key, _ in ARCHES) + 1
    checks = [
        f'{(key + ":").ljust(pad)} "{checksums[assets[arch]]}"'
        for key, arch in ARCHES
    ]

    body = [
        f'cask "{pkg}" do',
        "  arch " + ", ".join(f'{key}: "{arch}"' for key, arch in ARCHES),
        "",
        f'  version "{version}"',
        "  sha256 " + (",\n" + " " * 9).join(checks),
        "",
        f'  url "https://github.com/{source["repo"]}/releases/download/'
        f'{prefix}#{{version}}/{app}-#{{version}}-macos-#{{arch}}.dmg"',
        f'  name "{app}"',
        f'  desc "{cask["desc"]}"',
        f'  homepage "https://github.com/{source["repo"]}"',
        "",
    ]

    if "min_macos" in cask:
        body += [f'  depends_on macos: :{cask["min_macos"]}', ""]

    body += [f'  app "{app}.app"']

    bundle = cask.get("bundle_id")
    if bundle:
        body += [
            "",
            "  zap trash: [",
            *(f'    "{d.format(bundle=bundle)}",' for d in ZAP_DIRS),
            "  ]",
        ]

    return "\n".join([*body, "end", ""])


def main() -> int:
    sources = [s for s in manifest.load(sys.argv[1]) if "cask" in s]
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
            # tap 里一个包只有一份 cask，只能是最新版。想装旧版去 Release 下 DMG。
            tag = tags[0]
            checksums = manifest.fetch_sums(s["repo"], tag, Path(tmp))
            text = render(s, tag, checksums)
            if text is None:
                continue
            (outdir / f"{pkg}.rb").write_text(text)
            print(f"  {pkg} {tag}: 已生成")
            wrote += 1

    if sources and not wrote:
        print("一个 cask 都没生成", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
