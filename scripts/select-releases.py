#!/usr/bin/env python3
"""按 packages.toml 挑出该收哪些 release，每行输出 `仓库<TAB>tag`。"""

import sys

import manifest


def main() -> int:
    for s in manifest.load(sys.argv[1]):
        for t in manifest.selected(s):
            print(f"{s['repo']}\t{t}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
