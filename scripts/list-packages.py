#!/usr/bin/env python3
"""列出 packages.toml 里的包，给 CI 的装机验证用。

  list-packages.py <packages.toml> [--brew]

每行 `包名<TAB>可执行文件名`，用 TAB 分隔是为了 `while IFS=$'\t' read` 直接读。
`--brew` 只列带 `[source.brew]` 的 —— apt 收所有项目，brew 只收配了 formula 的。

存在的理由：verify 和 verify-brew 原来把包名写死成 fundeploy，加一个项目就得回去
改 workflow，而 packages.toml 的头注释写着「加几行就完事」。让两个验证按这张表
遍历，那句话才是真的。
"""

import sys

import manifest


def main() -> int:
    args = sys.argv[1:]
    brew_only = "--brew" in args
    paths = [a for a in args if not a.startswith("-")]
    if len(paths) != 1:
        print(__doc__, file=sys.stderr)
        return 2

    sources = manifest.load(paths[0])
    if brew_only:
        sources = [s for s in sources if "brew" in s]

    for s in sources:
        pkg = manifest.name_of(s)
        # 包名和可执行文件名绝大多数时候一样，不一样的用 [source.brew].bin 改 ——
        # render-formula.py 的 `bin.install` 读的就是它，两边必须是同一个来源。
        print(f"{pkg}\t{s.get('brew', {}).get('bin', pkg)}")

    if not sources:
        print("packages.toml 里一个包都没有", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
