#!/usr/bin/env python3
"""读 packages.toml、挑 release、读 SHA256SUMS。几个脚本共用。

版本比较自己做而不是交给 `sort -V`：后者对 `0.10.0` vs `0.9.0` 是对的，但碰上
`1.0.0-rc1` 这类后缀就不一定，而没人保证仓库里没打过预发布 tag。
"""

import json
import subprocess
import tomllib
from pathlib import Path


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


def sums(path: Path) -> dict[str, str]:
    """读 SHA256SUMS。二进制模式的行是 `hash *name`，把那个星号去掉。"""
    out = {}
    for line in path.read_text().splitlines():
        parts = line.split()
        if len(parts) == 2 and len(parts[0]) == 64:
            out[parts[1].lstrip("*")] = parts[0]
    return out


def fetch_sums(repo: str, tag: str, into: Path) -> dict[str, str]:
    """下这次 release 的 SHA256SUMS，读成 {附件名: 校验和}。下不到就是空字典。

    两个渲染器（formula 和 cask）都从这里取校验和：各项目的 SHA256SUMS 是同一步
    生成的，没有理由让它们各读一遍。
    """
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
