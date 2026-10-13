#!/usr/bin/env python3
"""读 packages.toml、挑 release。select-releases.py 和 render-formula.py 共用。

版本比较自己做而不是交给 `sort -V`：后者对 `0.10.0` vs `0.9.0` 是对的，但碰上
`1.0.0-rc1` 这类后缀就不一定，而没人保证仓库里没打过预发布 tag。
"""

import json
import subprocess
import tomllib


def ver(tag: str) -> tuple:
    """把 `v1.2.3` 变成可比较的 (1, 2, 3)。认不出的段当 0。"""
    body = tag.lstrip("vV").split("-")[0].split("+")[0]
    return tuple(int(p) if p.isdigit() else 0 for p in body.split("."))


def load(path: str) -> list[dict]:
    with open(path, "rb") as f:
        return tomllib.load(f).get("source", [])


def name_of(source: dict) -> str:
    """包名取仓库名。两边同名是这个组织的约定，不单独配一遍。"""
    return source["repo"].split("/")[-1]


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


def selected(source: dict) -> list[str]:
    """这个项目该收进来的 tag，新的在前。"""
    keep = int(source.get("keep", 3))
    if keep < 1:
        raise SystemExit(f"{source['repo']}: keep 至少是 1")
    tags = releases(source["repo"])
    floor = source.get("min_version")
    if floor:
        tags = [t for t in tags if ver(t) >= ver(floor)]
    return tags[:keep]
