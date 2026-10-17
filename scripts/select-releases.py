#!/usr/bin/env python3
"""按 packages.toml 挑出该收哪些 release 进 APT 源，每行输出 `仓库<TAB>tag`。

走不走 apt 由 manifest.in_apt 定 —— uTools 插件的 release 里不会有 .deb，翻一遍只是
白费几次 API 调用，还在日志里留下一串「没有 .deb，跳过」。
"""

import sys

import manifest


def main() -> int:
    for s in manifest.load(sys.argv[1]):
        if not manifest.in_apt(s):
            continue
        for t in manifest.selected(s):
            print(f"{s['repo']}\t{t}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
