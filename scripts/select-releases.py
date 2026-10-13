#!/usr/bin/env python3
"""按 packages.toml 挑出该收哪些 release，每行输出 `仓库<TAB>tag`。

挑选逻辑放在这儿而不是 bash 里，是因为它要做版本比较：`sort -V` 对
`0.10.0` vs `0.9.0` 这种是对的，但对 `1.0.0-rc1` 这类后缀就不一定，而发布脚本
本来就不保证没人打过预发布 tag。
"""

import json
import subprocess
import sys
import tomllib


def ver(tag: str) -> tuple:
    """把 `v1.2.3` 变成可比较的 (1, 2, 3)。认不出的段当 0。"""
    body = tag.lstrip("vV").split("-")[0].split("+")[0]
    out = []
    for part in body.split("."):
        out.append(int(part) if part.isdigit() else 0)
    return tuple(out)


def releases(repo: str) -> list[str]:
    """仓库里的正式 release tag，新的在前。

    草稿和预发布不要：它们是给人单独试的，不该让 apt upgrade 自动装上。
    """
    out = subprocess.run(
        [
            "gh", "release", "list", "--repo", repo, "--limit", "100",
            "--json", "tagName,isDraft,isPrerelease",
        ],
        capture_output=True, text=True, check=True,
    ).stdout
    rs = json.loads(out)
    tags = [r["tagName"] for r in rs if not r["isDraft"] and not r["isPrerelease"]]
    # gh 按发布时间排，而我们要的是版本序——补发一个老版本的 patch 之后两者会分叉。
    return sorted(tags, key=ver, reverse=True)


def main() -> int:
    with open(sys.argv[1], "rb") as f:
        doc = tomllib.load(f)

    for s in doc.get("source", []):
        repo = s["repo"]
        keep = int(s.get("keep", 3))
        if keep < 1:
            sys.exit(f"{repo}: keep 至少是 1")
        floor = s.get("min_version")

        tags = releases(repo)
        if floor:
            tags = [t for t in tags if ver(t) >= ver(floor)]
        for t in tags[:keep]:
            print(f"{repo}\t{t}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
