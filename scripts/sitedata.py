#!/usr/bin/env python3
"""站点要显示的东西在这儿收齐：清单、APT 索引、各项目 Release、更新日志、页面文案。

  sitedata.py <packages.toml> [--deb <APT 输出目录>] [--pages <文案目录>] [--offline]

单独跑会把收上来的数据按 JSON 打到标准输出，用来回答「页面上那一块为什么没了」。
站点本身由 render-site.py 渲染，这个文件只管「有什么」，一个字 HTML 都不碰。

和 render-formula.py / render-cask.py 共用 manifest.py：收哪些项目、每个项目收哪几版，
三条渠道必须是同一个答案 —— 不能站点上写着能 `apt install fundeploy=0.3.5` 而索引里
压根没有那一版。

**离线要能跑。** gh 不可用（没登录、断网、限流）时，每个取数据的地方都退化成「这块
没有」，收集继续 —— 改样式的人不该被迫先联网，而 CI 里真缺了数据，页面少一块总比
构建红掉好（索引那半边自己会在 collect-debs.sh 那步先红）。
"""

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

import manifest
import tomllib

# 渠道的显示顺序，也是包页上安装分段的顺序。apt 在前：Linux 上加一次源以后全组织的
# 包都能装，是这个仓库存在的理由。
CHANNELS = ("apt", "brew", "cask")

# 这些附件不往下载表里放：SHA256SUMS 渲染成一条校验和链接（它不是给人下的包），
# 签名和 wheel 各有自己的渠道（PyPI），列在这儿只会让人以为该下哪个。
SUMS = "SHA256SUMS"
HIDDEN_SUFFIXES = (".whl", ".sig", ".asc", ".sha256", ".minisig", ".pem")

# 架构关键字 → 架构 id。顺序要紧：Android 的 `arm64-v8a` 和 `armeabi-v7a` 必须在
# 裸 `arm64` / `arm` 之前匹配，否则两者都会归到 arm64，列表里就出现两个同名行。
ARCH_HINTS = (
    ("arm64-v8a", "arm64"),
    ("armeabi-v7a", "arm32"),
    ("aarch64", "arm64"),
    ("arm64", "arm64"),
    ("x86_64", "amd64"),
    ("amd64", "amd64"),
    ("x64", "amd64"),
    ("i686", "x86"),
    ("i386", "x86"),
)

# 平台关键字 → 平台 id。rust 的目标三元组和各项目自己拼的文件名都认：
# `funget-aarch64-apple-darwin` 和 `FunClash-1.0.2-macos-arm64.dmg` 是同一个平台。
PLATFORM_HINTS = (
    ("android", "android"),
    ("apple-darwin", "macos"),
    ("macos", "macos"),
    ("darwin", "macos"),
    ("pc-windows", "windows"),
    ("windows", "windows"),
    ("linux", "linux"),
)

# 扩展名 → (种类标签, 这个扩展名本身就能定下来的平台)。种类标签直接显示在文件行左边
# 那个小方块里，所以用大家在 Release 页上看到的那几个字。
KINDS = (
    (".apk", "APK", "android"),
    (".dmg", "DMG", "macos"),
    (".pkg", "PKG", "macos"),
    (".appimage", "AppImage", "linux"),
    (".deb", "DEB", "linux"),
    (".rpm", "RPM", "linux"),
    (".msi", "MSI", "windows"),
    (".exe", "EXE", "windows"),
    (".tar.gz", "TAR.GZ", None),
    (".tgz", "TAR.GZ", None),
    (".zip", "ZIP", None),
)

# 平台在下载区分段里的顺序，和每个平台里架构的排法。
PLATFORM_ORDER = ("android", "windows", "macos", "linux")
ARCH_ORDER = ("amd64", "arm64", "arm32", "x86")
# 同一个架构下多个文件时的排法：装得最省事的在上面。musl 的静态包排在 gnu 前面 ——
# 它不挑 glibc 版本，是更安全的默认。
KIND_ORDER = ("DEB", "RPM", "AppImage", "DMG", "PKG", "EXE", "MSI", "APK", "TAR.GZ", "ZIP", "BIN")

# 更新日志里 funclash 那种生成式分组的标题 → 类型 id。类型只用来上色和排序，认不出的
# 分组按原标题显示。
GROUP_TYPES = {
    "breaking changes": "breaking",
    "features": "feat",
    "bug fixes": "fix",
    "fixes": "fix",
    "performance": "perf",
    "reverts": "revert",
}

# `## v1.0.2 (2026-10-16)`、`## [0.3.7] - 2026-10-16`、`## 1.2.0` 三种标题都认：三个
# 项目的 CHANGELOG 各写一种，而「有哪几版、哪天发的」是三种格式唯一的共同点。
VERSION_HEAD = re.compile(
    r"^## \[?(v?\d[^\s\]]*)\]?"
    r"(?:\s*\((\d{4}-\d{2}-\d{2})\)|\s*-\s*(\d{4}-\d{2}-\d{2}))?\s*$"
)


def warn(msg: str) -> None:
    print(f"warning: {msg}", file=sys.stderr)


def gh_json(args: list[str]):
    """跑一条 gh 命令并解析 JSON。失败返回 None —— 调用方负责退化。"""
    try:
        out = subprocess.run(
            ["gh", *args], capture_output=True, text=True, check=True
        ).stdout
        return json.loads(out) if out.strip() else None
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError) as e:
        warn(f"gh {' '.join(args[:3])} 取不到数据：{e}")
        return None


def arch_of(low: str) -> str | None:
    for hint, arch in ARCH_HINTS:
        if hint in low:
            return arch
    return None


def platform_of(low: str) -> str | None:
    for hint, plat in PLATFORM_HINTS:
        if hint in low:
            return plat
    return None


def classify(asset: dict) -> dict | None:
    """把一个 release 附件认成下载表里的一行。认不出平台的返回 kind 但不带平台。

    认的是文件名而不是 content-type：各项目的附件名本来就是按约定拼的（见
    packages.toml 的头注释），而 GitHub 给 `.AppImage` 之类一律报
    application/octet-stream，按它分不出任何东西。
    """
    name = asset["name"]
    low = name.lower()
    if name == SUMS or low.endswith(HIDDEN_SUFFIXES):
        return None

    kind = "BIN"
    fixed = None
    for suffix, label, plat in KINDS:
        if low.endswith(suffix):
            kind, fixed = label, plat
            break

    platform = fixed or platform_of(low)
    # 扩展名定不下平台、名字里也没有平台关键字的（funclash 的 `-panel.zip` 就是），
    # 不猜。它们会进「其它文件」那一栏，而不是被塞进某个平台里误导人。
    note = note_key(kind, platform, arch_of(low), low)
    return {
        "name": name,
        "url": asset["url"],
        "size": asset["size"],
        "sha256": asset["sha256"],
        "kind": kind,
        "platform": platform,
        "arch": arch_of(low),
        # musl 的静态二进制和 gnu 的动态链接版装出来的东西不一样，同一个架构下并排
        # 出现时必须能区分，否则两行一模一样。
        "variant": "musl" if "musl" in low else ("gnu" if "-gnu" in low else None),
        "note": note,
    }


def note_key(kind: str, platform: str | None, arch: str | None, low: str) -> str | None:
    """这一行底下那句说明用哪个文案键。文案本身在 site/strings.toml 里。"""
    if platform == "windows":
        if kind in ("EXE", "MSI"):
            # 带 setup 的是安装器，不带的就是那个命令行二进制本身（funget 的
            # `funget-x86_64-pc-windows-msvc.exe`），两者下载后要做的事完全不同。
            return "noteWinSetup" if "setup" in low else "noteBin"
        if kind == "ZIP":
            return "noteWinPortable"
    if platform == "macos" and kind == "DMG":
        return "noteMacArm" if arch == "arm64" else "noteMacIntel"
    if platform == "android":
        return {"arm64": "noteApkArm64", "arm32": "noteApkArm32"}.get(arch, "noteApkX64")
    if kind == "DEB":
        return "noteDeb"
    if kind == "RPM":
        return "noteRpm"
    if kind == "AppImage":
        return "noteAppImage"
    if kind == "TAR.GZ":
        return "noteTarMusl" if "musl" in low else "noteTar"
    if kind == "BIN":
        return "noteBinMusl" if "musl" in low else "noteBin"
    return None


def downloads(assets: list[dict]) -> dict:
    """把附件分到平台里，顺带挑出 SHA256SUMS 的地址。"""
    sums = next((a["url"] for a in assets if a["name"] == SUMS), None)
    rows = [row for row in (classify(a) for a in assets) if row]

    groups: dict[str, list[dict]] = {}
    other = []
    for row in rows:
        if row["platform"]:
            groups.setdefault(row["platform"], []).append(row)
        else:
            other.append(row)

    def order(row: dict) -> tuple:
        arch = ARCH_ORDER.index(row["arch"]) if row["arch"] in ARCH_ORDER else len(ARCH_ORDER)
        kind = KIND_ORDER.index(row["kind"]) if row["kind"] in KIND_ORDER else len(KIND_ORDER)
        return (arch, kind, row["variant"] == "gnu", row["name"])

    platforms = []
    for plat in PLATFORM_ORDER:
        files = groups.pop(plat, None)
        if not files:
            continue
        files.sort(key=order)
        arches = [a for a in ARCH_ORDER if any(f["arch"] == a for f in files)]
        platforms.append({"id": plat, "arches": arches, "files": files})
    for plat, files in sorted(groups.items()):  # 以后出了新平台也不会被丢掉
        files.sort(key=order)
        platforms.append({"id": plat, "arches": [], "files": files})

    other.sort(key=lambda row: row["name"])
    return {"platforms": platforms, "other": other, "sums": sums}


def parse_entry(text: str) -> dict:
    """`**scope** 文案 (abc1234)` 拆成三段。"""
    scope = None
    commit = None
    scoped = re.match(r"^\*\*([^*]+)\*\*\s+(.+)$", text)
    if scoped:
        scope, text = scoped.group(1), scoped.group(2)
    hashed = re.match(r"^(.*)\s+\(([0-9a-f]{7,40})\)$", text)
    if hashed:
        text, commit = hashed.group(1), hashed.group(2)
    return {"scope": scope, "text": text, "commit": commit}


def parse_changelog(text: str) -> tuple[list[dict], bool]:
    """解析 CHANGELOG.md，返回（版本列表, 是不是结构化的）。

    结构化的判据是「每一行都被认下来了」，不是「认出了几行」。三个项目的日志格式
    差得很远：funclash 的是 funbuild 从 commit 生成的（`**Features**` 加一串带 hash
    的条目），fundeploy 和 funget 的是手写长段中文，带 `###` 小标题和成段的解释。
    用认 funclash 那套规则去套后两者，能认出零散几条 bullet，然后把它们之间的段落
    全丢掉 —— 页面上就是一份被截过的、看不出在说什么的日志。宁可整块不渲染，只给
    版本号、日期和一条指向 Release 的链接。
    """
    versions: list[dict] = []
    version = None
    group = None
    entry = None
    dropped = 0
    bold_groups = 0

    for raw in text.splitlines():
        line = raw.rstrip()
        head = VERSION_HEAD.match(line)
        if head:
            tag = head.group(1)
            version = {
                "tag": tag,
                "version": tag.lstrip("vV"),
                "date": head.group(2) or head.group(3) or "",
                "groups": [],
                "empty": False,
            }
            versions.append(version)
            group = entry = None
            continue
        if not line.strip():
            continue
        # HTML 注释是写给生成器看的标记（funclash 的 `<!-- changelog:frozen -->`），
        # 不是日志内容。不跳过的话它们会被算成「有没认下来的行」，整份结构化日志就
        # 因为两行注释退化成光秃秃的版本列表。
        if line.strip().startswith("<!--"):
            continue
        if version is None:
            continue  # 第一个版本标题之前是 `# Changelog` 和文件说明，不是日志内容

        bold = re.match(r"^\*\*(.+)\*\*$", line)
        if bold:
            title = bold.group(1)
            group = {
                "type": GROUP_TYPES.get(title.lower()),
                "title": title,
                "entries": [],
            }
            version["groups"].append(group)
            bold_groups += 1
            entry = None
            continue

        item = re.match(r"^[-*]\s+(.+)$", line)
        if item:
            if group is None:
                group = {"type": None, "title": "", "entries": []}
                version["groups"].append(group)
            entry = parse_entry(item.group(1))
            group["entries"].append(entry)
            continue

        if entry is not None and re.match(r"^\s+\S", raw):
            entry["text"] += f" {line.strip()}"
            continue

        if line == "Internal improvements only.":
            version["empty"] = True
            continue

        dropped += 1

    return versions, dropped == 0 and bold_groups > 0


def fetch_changelog(repo: str, tag: str) -> str | None:
    """取这次发布那一刻的 CHANGELOG.md。

    按 tag 取而不是按默认分支：日志不该跑在下载前面 —— 刚合进 master 还没发版的条目
    出现在页面上，而对应的包根本下不到。
    """
    try:
        return subprocess.run(
            [
                "gh", "api", f"repos/{repo}/contents/CHANGELOG.md?ref={tag}",
                "-H", "Accept: application/vnd.github.raw",
            ],
            capture_output=True, text=True, check=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        return None


def release_assets(repo: str, tag: str) -> list[dict]:
    """这次 release 的附件，带大小和校验和。"""
    data = gh_json(
        [
            "api", f"repos/{repo}/releases/tags/{tag}",
            "--jq", "[.assets[] | {name, size, url: .browser_download_url, digest}]",
        ]
    )
    if not data:
        return []
    out = []
    for a in data:
        digest = a.get("digest") or ""
        out.append(
            {
                "name": a["name"],
                "size": a["size"],
                "url": a["url"],
                # GitHub 给的是 `sha256:<hex>`，而页面上要复制的是能直接和
                # `sha256sum` 的输出比的那串十六进制。
                "sha256": digest.split(":", 1)[1] if ":" in digest else "",
            }
        )
    return out


def packages_index(deb_dir: Path) -> dict[str, list[dict]]:
    """读 APT 索引，拿到「每个包在源里留着哪几版、每版多大」。

    读索引而不是读 pool 里的文件名：索引才是 apt 认的那一份，而
    `apt install fundeploy=0.3.5` 能不能成立完全取决于它。
    """
    found: dict[tuple[str, str, str], dict] = {}
    for packages in sorted(deb_dir.glob("dists/*/*/binary-*/Packages")):
        for stanza in packages.read_text().split("\n\n"):
            fields = {}
            for line in stanza.splitlines():
                if line and not line[0].isspace() and ":" in line:
                    key, _, value = line.partition(":")
                    fields[key] = value.strip()
            if "Package" not in fields or "Version" not in fields:
                continue
            key = (fields["Package"], fields["Version"], fields.get("Architecture", ""))
            found[key] = fields

    out: dict[str, list[dict]] = {}
    for (name, version, arch), fields in found.items():
        versions = out.setdefault(name, [])
        row = next((v for v in versions if v["version"] == version), None)
        if row is None:
            row = {"version": version, "arches": {}}
            versions.append(row)
        row["arches"][arch] = int(fields.get("Size", 0))
    for versions in out.values():
        versions.sort(key=lambda v: manifest.ver(v["version"]), reverse=True)
    return out


def load_page(pages_dir: Path | None, pkg: str) -> dict:
    """包页的文案。没有这个文件的包就走最简页，不是错误。"""
    if pages_dir is None:
        return {}
    path = pages_dir / f"{pkg}.toml"
    if not path.exists():
        return {}
    with open(path, "rb") as f:
        return tomllib.load(f)


def collect(
    packages_toml: str,
    deb_dir: Path | None = None,
    pages_dir: Path | None = None,
    offline: bool = False,
    fingerprint: str = "",
) -> dict:
    sources = manifest.load(packages_toml)
    index = packages_index(deb_dir) if deb_dir and deb_dir.exists() else {}
    if deb_dir and not index:
        warn(f"{deb_dir} 里没有 APT 索引，版本一节退化成按 Release 列")

    packages = []
    for source in sources:
        name = manifest.name_of(source)
        brew = source.get("brew", {})
        cask = source.get("cask", {})
        # apt 那条线收所有项目，所以有索引时按「索引里有没有」算（某个项目的 release
        # 里压根没有 .deb 是容忍的，见 collect-debs.sh），没有索引时按清单算。
        in_apt = name in index if index else True
        channels = [c for c in CHANNELS if (c == "apt" and in_apt) or c in source]

        history = [] if offline else (manifest.release_list(source["repo"]) or [])
        floor = source.get("min_version")
        # min_version 管的是「收哪几版进源」，不是「这个项目有过哪些版本」。版本一节
        # 按它过滤（列出来的每一版都要真能装），更新日志一节不过滤 —— funget 的下限
        # 只是因为更早的 release 里没有 .deb，那些版本本身是真实发生过的。
        rels = (
            [r for r in history if manifest.ver(r["tag"]) >= manifest.ver(floor)] if floor else history
        )
        keep = int(source.get("keep", 3))
        latest = rels[0] if rels else None
        dates = {r["tag"]: r["date"] for r in history}

        # 版本一节优先用索引：它是 apt 真能装到的那几版。索引不在（本地渲染、或者
        # 还没跑 build-deb-repo.sh）就退到清单选中的 tag，页面结构不塌。
        if name in index:
            versions = index[name][:keep]
            for v in versions:
                v["tag"] = next((t for t in dates if t.lstrip("vV") == v["version"]), "")
                v["date"] = dates.get(v["tag"], "")
        else:
            versions = [
                {"version": r["tag"].lstrip("vV"), "tag": r["tag"], "date": r["date"], "arches": {}}
                for r in rels[:keep]
            ]

        assets = release_assets(source["repo"], latest["tag"]) if latest and not offline else []
        log: dict = {"structured": False, "releases": []}
        if latest and not offline:
            text = fetch_changelog(source["repo"], latest["tag"])
            if text:
                parsed, structured = parse_changelog(text)
                if structured:
                    # 日期以 Release 为准：CHANGELOG 的标题日期是写日志那天，不一定是
                    # 发布那天，而页面上这一列说的是「哪天发的」。tag 带不带 v 是各项目
                    # 自己的事，两种都试一下。
                    for v in parsed:
                        v["date"] = dates.get(v["tag"], dates.get(f"v{v['version']}", v["date"]))
                    log = {"structured": True, "releases": parsed}
            if not log["releases"]:
                # 日志取不到、或者认不出结构：按 Release 列「有哪几版、哪天发的」，
                # 正文留给 GitHub。
                log["releases"] = [
                    {
                        "tag": r["tag"],
                        "version": r["tag"].lstrip("vV"),
                        "date": r["date"],
                        "groups": [],
                        "empty": False,
                    }
                    for r in history
                ]

        packages.append(
            {
                "name": name,
                "repo": source["repo"],
                "url": f"https://github.com/{source['repo']}",
                "desc": cask.get("desc") or brew.get("desc") or "",
                "channels": channels,
                "binary": brew.get("bin", name),
                "app": cask.get("app", ""),
                "min_macos": cask.get("min_macos", ""),
                "gui": not source.get("cli", True),
                "keep": keep,
                "latest": latest,
                "versions": versions,
                "in_apt": in_apt,
                "downloads": downloads(assets),
                "changelog": log,
                "page": load_page(pages_dir, name),
            }
        )

    return {
        "generated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "fingerprint": fingerprint,
        "arches": ["amd64", "arm64"],
        "packages": packages,
    }


def check(data: dict, only: str | None) -> int:
    """按包打一份「站点看到了什么」的报告，给接入的项目自检用。

    存在的理由：docs/package-spec.md 里那些命名约定，光写在文档里是没有反馈的 ——
    附件名少一个词，页面上就少一块，而发版的人看不到。这个报告把「认出了什么、
    漏了什么」摆出来，接入时跑一遍就知道约定有没有对上。
    """
    packages = [p for p in data["packages"] if not only or p["name"] == only]
    if not packages:
        print(f"packages.toml 里没有 {only}", file=sys.stderr)
        return 2

    bad = 0
    for pkg in packages:
        print(f"\n{pkg['name']}  {pkg['repo']}")
        latest = pkg["latest"]
        if not latest:
            print("  ! 没有够格的正式 release（草稿和预发布不收）")
            bad += 1
            continue
        print(f"  最新 release   {latest['tag']}（{latest['date'] or '日期未知'}）")
        print(f"  渠道           {', '.join(pkg['channels']) or '无'}")

        downloads = pkg["downloads"]
        names = [f["name"] for p in downloads["platforms"] for f in p["files"]]
        names += [f["name"] for f in downloads["other"]]
        if downloads["sums"]:
            print("  SHA256SUMS     有")
        else:
            print("  SHA256SUMS     ! 没有 —— formula 和 cask 的校验和取不到，不会生成")
            bad += 1

        debs = [n for n in names if n.endswith(".deb")]
        missing = [a for a in ("amd64", "arm64") if not any(f"_{a}.deb" in n for n in debs)]
        if missing:
            print(f"  .deb           ! 缺 {', '.join(missing)}（那个架构的机器装不到）")
        else:
            print("  .deb           amd64、arm64 都有")

        if "cask" in pkg["channels"]:
            app = pkg["app"]
            want = [f"{app}-{latest['tag'].lstrip('vV')}-macos-{a}.dmg" for a in ("arm64", "amd64")]
            lost = [w for w in want if w not in names]
            if lost:
                print(f"  cask DMG       ! 缺 {', '.join(lost)}，整份 cask 不会生成")
                bad += 1
            else:
                print("  cask DMG       arm64、amd64 都有")

        for platform in downloads["platforms"]:
            print(f"  下载区 {platform['id']:<9}{len(platform['files'])} 个文件")
        if downloads["other"]:
            print(f"  ? 认不出平台   {', '.join(f['name'] for f in downloads['other'])}")
            print("                （会列在「其它文件」里；要进某个平台就按约定改名）")

        log = pkg["changelog"]
        print(
            f"  更新日志       {'结构化时间线' if log['structured'] else '只列版本（格式认不出）'}"
            f"，{len(log['releases'])} 个版本"
        )

        page = pkg["page"]
        if page:
            print(
                f"  页面文案       标语 {'有' if page.get('tagline') else '无'}"
                f"、功能点 {len(page.get('features', []))} 条"
                f"、截图 {len(page.get('shots', []))} 张"
                f"、额外渠道 {len(page.get('install', []))} 条"
            )
        else:
            print("  页面文案       无（首屏会用 packages.toml 里那句英文 desc）")

    print()
    return 1 if bad else 0


def main() -> int:
    parser = argparse.ArgumentParser(description="收集站点数据并按 JSON 打到标准输出")
    parser.add_argument("packages", help="packages.toml 的路径")
    parser.add_argument("--deb", type=Path, help="build-deb-repo.sh 的输出目录")
    parser.add_argument("--pages", type=Path, help="包页文案目录（site/pages）")
    parser.add_argument("--offline", action="store_true", help="一次 gh 都不调")
    parser.add_argument(
        "--check",
        nargs="?",
        const="",
        metavar="包名",
        help="按包打一份自检报告，不输出 JSON；不写包名就是全部",
    )
    args = parser.parse_args()

    # 文案目录默认按清单的位置猜，自检时不用每次把 --pages 写出来。
    pages = args.pages
    if pages is None:
        guess = Path(args.packages).resolve().parent / "site" / "pages"
        pages = guess if guess.is_dir() else None

    data = collect(args.packages, args.deb, pages, args.offline)
    if args.check is not None:
        return check(data, args.check or None)
    json.dump(data, sys.stdout, ensure_ascii=False, indent=2)
    print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
