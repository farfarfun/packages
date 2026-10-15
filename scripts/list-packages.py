#!/usr/bin/env python3
"""列出 packages.toml 里的包，给 CI 的装机验证用。

  list-packages.py <packages.toml> [--brew | --cask]

每行 `包名<TAB>第二列`，用 TAB 分隔是为了 `while IFS=$'\t' read` 直接读。
不带开关就是 apt 那条线，它收所有项目；`--brew` 只列带 `[source.brew]` 的，
`--cask` 只列带 `[source.cask]` 的。

第二列按条线不同：

- apt 和 brew：可执行文件名，CI 拿它跑 `--version`。
- cask：应用的显示名，cask 装出来的是 `/Applications/<显示名>.app`。

apt 那条线的第二列可能是 `-`，意思是「这个包没有能在 CI 里跑的命令行入口」
（`cli = false`）。GUI 应用就是这样：装出来那个可执行文件是窗口程序，在无头
runner 上跑它只会卡住或崩。verify 对这种包改成查 `.desktop` 的 `Exec` 解析得到、
版本从 dpkg 问。

存在的理由：verify 和 verify-brew 原来把包名写死成 fundeploy，加一个项目就得回去
改 workflow，而 packages.toml 的头注释写着「加几行就完事」。让装机验证按这张表
遍历，那句话才是真的。
"""

import sys

import manifest

CHANNELS = ("brew", "cask")
NO_CLI = "-"


def main() -> int:
    args = sys.argv[1:]
    channel = next((a[2:] for a in args if a[2:] in CHANNELS), None)
    paths = [a for a in args if not a.startswith("-")]
    if len(paths) != 1:
        print(__doc__, file=sys.stderr)
        return 2

    sources = manifest.load(paths[0])
    if channel:
        sources = [s for s in sources if channel in s]

    for s in sources:
        pkg = manifest.name_of(s)
        if channel == "cask":
            print(f"{pkg}\t{s['cask']['app']}")
            continue
        # 包名和可执行文件名绝大多数时候一样，不一样的用 [source.brew].bin 改 ——
        # render-formula.py 的 `bin.install` 读的就是它，两边必须是同一个来源。
        binary = s.get("brew", {}).get("bin", pkg)
        print(f"{pkg}\t{binary if s.get('cli', True) else NO_CLI}")

    if not sources:
        where = f"带 [source.{channel}] 的" if channel else ""
        print(f"packages.toml 里一个{where}包都没有", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
