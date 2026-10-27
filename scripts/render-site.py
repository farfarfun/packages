#!/usr/bin/env python3
"""把 site/ 下的模板渲染成能直接挂到 GitHub Pages 上的站点。

  render-site.py <site 目录> <输出目录> [--packages packages.toml] [--deb <APT 目录>]
                 [--pages <文案目录>] [--fingerprint <GPG 指纹>] [--offline]

出一张总览页和每个包一页，中英各一份：

  /            /en/            总览（加源 + 包列表）
  /<包>/       /en/<包>/       包页（安装 / 下载 / 版本 / 更新日志）
  /assets/     /favicon.svg    /sitemap.xml  /robots.txt  /packages.json

数据全部来自 sitedata.py（清单、APT 索引、各项目 Release），**页面里没有一个写死的
包名** —— packages.toml 的头注释写着「加一个新项目就是在这儿加几行」，站点也得照办。

为什么自己写一个一百行的模板替换，而不是上 Jinja2：整仓到现在只用标准库，CI 里也
就没有 pip 这一步。这里要的东西只有三样 —— 换文案、插片段、拼生成的 HTML，够了。

  {{t.键}}     site/strings.toml 里对应语言的文案，自动 HTML 转义，键缺了就报错
  {{键}}       渲染器算出来的值，同样转义
  {{%键}}      渲染器拼好的 HTML，原样插入
  <!-- include 名.html -->   插入 site/partials/名.html

**离线要能跑。** sitedata 取不到的东西（没登录 gh、断网、没建索引）对应的区块整块
不出，渲染继续 —— 改样式的人不该被迫先联网。渲染完会自检一遍，模板里有没填上的占位
符就非零退出，不会把一个带 `{{` 的页面发出去。
"""

import argparse
import html
import json
import re
import shutil
import struct
import sys
import urllib.error
import urllib.request
from pathlib import Path

import sitedata
import tomllib

SITE_URL = "https://farfarfun.github.io/packages/"
REPO_URL = "https://github.com/farfarfun/packages"
GITEE_URL = "https://gitee.com/farfarfun/packages"

# (lang, <html lang>, og:locale, 路径前缀)。中文在前且前缀为空：它是 x-default，
# 也是这个组织的文档语言。
LANGS = (
    ("zh", "zh-CN", "zh_CN", ""),
    ("en", "en", "en_US", "en/"),
)

# 包名直接当目录名，所以撞上这些名字会覆盖站点自己的东西。宁可报错，不要悄悄发一个
# 坏站。
RESERVED = {"en", "assets", "deb", "pool", "dists", "shots"}

# 更新日志最多渲染多少个版本。再往前的在 GitHub 上 —— 页面不是日志的归档处。
CHANGELOG_MAX = 12

MONTHS_EN = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

# 渠道 → 文案键 / 分段标签。顺序由 sitedata.CHANNELS 定。
CHANNEL_KEYS = {
    "apt": "installApt",
    "brew": "installBrew",
    "cask": "installCask",
    "utools": "installUtools",
}
# 分段控件初选哪一个：JS 按 navigator 猜系统，猜中了就切过去。uTools 插件在三个系统
# 上是同一个包，没有可猜的，留 None 就不会被自动选中。
CHANNEL_OS = {"apt": "linux", "brew": "macos", "cask": "macos", "utools": None}
PLATFORM_OS = {"android": "android", "windows": "windows", "macos": "macos", "linux": "linux"}
# 包的类别 → 那枚灰 chip 的文案键。sitedata 算出 kind，这里只负责翻译。
KIND_KEYS = {"cli": "pkgCli", "gui": "pkgGui", "plugin": "pkgPlugin"}

ICON = {
    "copy": '<svg class="ico-copy" viewBox="0 0 20 20" width="16" height="16" aria-hidden="true">'
    '<rect x="6.75" y="6.75" width="9.5" height="9.5" rx="2.25" fill="none" stroke="currentColor" stroke-width="1.5"/>'
    '<path d="M13.25 4.75v-.5a1.5 1.5 0 0 0-1.5-1.5h-6.5a2.5 2.5 0 0 0-2.5 2.5v6.5a1.5 1.5 0 0 0 1.5 1.5h.5" '
    'fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>',
    "check": '<svg class="ico-check" viewBox="0 0 20 20" width="16" height="16" aria-hidden="true">'
    '<path d="m4.5 10.5 3.5 3.5 7.5-8" fill="none" stroke="currentColor" stroke-width="1.8" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>',
    "down": '<svg viewBox="0 0 20 20" width="18" height="18" aria-hidden="true">'
    '<path d="M10 3.5v11m0 0-4.5-4.5m4.5 4.5 4.5-4.5" fill="none" stroke="currentColor" stroke-width="1.8" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>',
    "arrow": '<svg viewBox="0 0 20 20" width="18" height="18" aria-hidden="true">'
    '<path d="M4 10h11m0 0-4.5-4.5M15 10l-4.5 4.5" fill="none" stroke="currentColor" stroke-width="1.7" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>',
    "ext": '<svg viewBox="0 0 16 16" width="12" height="12" aria-hidden="true">'
    '<path d="M6 3.5h6.5V10M12.25 3.75 4 12" fill="none" stroke="currentColor" stroke-width="1.5" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>',
    "search": '<svg viewBox="0 0 20 20" width="16" height="16" aria-hidden="true">'
    '<circle cx="9" cy="9" r="5.75" fill="none" stroke="currentColor" stroke-width="1.6"/>'
    '<path d="m13.25 13.25 3.5 3.5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>',
}

TOKEN = re.compile(r"\{\{(%?)([\w.]+)\}\}")
INCLUDE = re.compile(r"^[ \t]*<!-- include ([\w.-]+) -->[ \t]*\n?", re.MULTILINE)
# 模板里的注释是写给改模板的人看的，不发给访客 —— 它们解释的是「为什么这么写」，
# 对着页面源码看反而是噪音，而且每个页面都要带一份。
COMMENT = re.compile(r"[ \t]*<!--.*?-->\n?", re.DOTALL)


class Raw(str):
    """标记「这段已经是 HTML 了，别再转义」。"""


def esc(value) -> str:
    return html.escape(str(value), quote=True)


def warn(msg: str) -> None:
    print(f"warning: {msg}", file=sys.stderr)


def size_text(size: int) -> str:
    if not size:
        return ""
    if size < 1024 * 1024:
        return f"{size / 1024:.0f} KB"
    return f"{size / 1048576:.1f} MB"


def date_text(iso: str, lang: str) -> str:
    """`2026-10-16` 按语言写成人话。两种语言只差一个格式，不值得为它引 babel。"""
    if not iso or len(iso) < 10:
        return ""
    year, month, day = iso[:4], int(iso[5:7]), int(iso[8:10])
    if lang == "zh":
        return f"{year} 年 {month} 月 {day} 日"
    return f"{MONTHS_EN[month - 1]} {day}, {year}"


def fingerprint_text(fpr: str) -> str:
    """40 位指纹按 4 位一组分开 —— 这是 GnuPG 自己的排法，便于人工核对。"""
    clean = fpr.replace(" ", "").upper()
    return " ".join(clean[i : i + 4] for i in range(0, len(clean), 4))


def png_size(path: Path) -> tuple[int, int] | None:
    """读 PNG 头里的宽高。写进 <img> 可以免掉图片加载时的跳版。"""
    with open(path, "rb") as f:
        head = f.read(24)
    if len(head) < 24 or head[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    width, height = struct.unpack(">II", head[16:24])
    return width, height


class Site:
    def __init__(self, src: Path, out: Path, data: dict, site_url: str):
        self.src = src
        self.out = out
        self.data = data
        self.url = site_url
        self.strings = self._load_strings()
        self.partials: dict[str, str] = {}
        self.lang = "zh"
        self.shots: dict[str, dict] = {}

    # ---- 文案 ----

    def _load_strings(self) -> dict:
        with open(self.src / "strings.toml", "rb") as f:
            strings = tomllib.load(f)
        langs = {lang for lang, *_ in LANGS}
        missing = langs - set(strings)
        if missing:
            raise SystemExit(f"strings.toml 缺了 {', '.join(sorted(missing))} 这一张表")
        # 两张表的键必须完全一致。少一个键的代价是页面上留一句另一种语言的话，而那
        # 种错不会让构建红，只会让人看到半中半英的句子 —— 所以在这儿就判死。
        base = set(strings["zh"])
        for lang in langs:
            diff = base ^ set(strings[lang])
            if diff:
                raise SystemExit(f"strings.toml 里 zh 和 {lang} 的键不一致：{', '.join(sorted(diff))}")
        return strings

    def t(self, key: str, **kw) -> str:
        table = self.strings[self.lang]
        if key not in table:
            raise SystemExit(f"strings.toml 里没有 {key}（{self.lang}）")
        value = table[key]
        return value.format(**kw) if kw else value

    # ---- 模板 ----

    def partial(self, name: str) -> str:
        if name not in self.partials:
            self.partials[name] = (self.src / "partials" / name).read_text()
        return self.partials[name]

    def expand(self, text: str, depth: int = 0) -> str:
        if depth > 5:
            raise SystemExit("include 套得太深，大概是转圈了")
        if not INCLUDE.search(text):
            return text
        return self.expand(INCLUDE.sub(lambda m: self.partial(m.group(1)), text), depth + 1)

    def fill(self, text: str, ctx: dict, where: str) -> str:
        def sub(match: re.Match) -> str:
            raw, key = match.group(1), match.group(2)
            if key.startswith("t."):
                return esc(self.t(key[2:]))
            if key not in ctx:
                raise SystemExit(f"{where}: 模板要 {{{{{key}}}}}，渲染器没给")
            value = ctx[key]
            return str(value) if raw or isinstance(value, Raw) else esc(value)

        return TOKEN.sub(sub, text)

    def render(self, template: str, ctx: dict) -> str:
        text = COMMENT.sub("", self.expand((self.src / template).read_text()))
        return self.fill(text, ctx, template)

    def section(self, name: str, ctx: dict) -> str:
        return self.fill(COMMENT.sub("", self.expand(self.partial(name))), ctx, name)

    # ---- 组件 ----

    def cmd(self, text: str) -> str:
        """一个命令块加它的复制按钮。

        按钮不另存一份命令文本，点下去时从 <code> 里读 —— 两份文本不一致那种错，
        复制出来的人当场发现不了。
        """
        return (
            '<div class="cmd"><pre><code>'
            + esc(text)
            + '</code></pre><button class="copy" type="button" aria-label="'
            + esc(self.t("copy"))
            + '" data-copied="'
            + esc(self.t("copied"))
            + '">'
            + ICON["copy"]
            + ICON["check"]
            + "</button></div>"
        )

    def tip(self, title: str, text: str, extra: str = "") -> str:
        return f'<div class="tip"><h3>{esc(title)}</h3><p>{esc(text)}</p>{extra}</div>'

    def note_link(self, text: str, href: str, label: str) -> str:
        return (
            f'<p class="pane-note">{esc(text)} '
            f'<a href="{esc(href)}">{esc(label)} {ICON["ext"]}</a></p>'
        )

    def panes(self, group: str, items: list[dict], label: str) -> str:
        """分段控件加若干面板。面板全部预渲染，只有第一个是可见的。

        关掉 JS 时 head 里那段 noscript 样式会把分段藏掉、把所有面板展开 —— 页面少
        了点取舍的便利，但没有一句话是看不到的。

        只有一项时不出分段：一个点不动、也没有另一项可切的胶囊按钮，看着像控件坏了。
        uTools 插件就是这种包 —— 它只有「在 uTools 里装」这一条路。
        """
        if len(items) == 1:
            return f'<div class="panes single" data-group="{esc(group)}">{items[0]["body"]}</div>'
        tabs = []
        panes = []
        for i, item in enumerate(items):
            first = i == 0
            tab_id = f"{group}-tab-{item['id']}"
            pane_id = f"{group}-pane-{item['id']}"
            tabs.append(
                f'<button type="button" role="tab" id="{tab_id}" data-value="{esc(item["id"])}"'
                + (f' data-os="{esc(item["os"])}"' if item.get("os") else "")
                + f' aria-controls="{pane_id}" aria-selected="{"true" if first else "false"}"'
                + f' tabindex="{"0" if first else "-1"}">{esc(item["label"])}</button>'
            )
            panes.append(
                f'<div class="pane" id="{pane_id}" role="tabpanel" data-value="{esc(item["id"])}"'
                f' aria-labelledby="{tab_id}"{"" if first else " hidden"}>{item["body"]}</div>'
            )
        return (
            f'<div class="panes" data-group="{esc(group)}">'
            f'<div class="seg" role="tablist" aria-label="{esc(label)}">'
            f'<span class="seg-ink" aria-hidden="true"></span>{"".join(tabs)}</div>'
            f'{"".join(panes)}</div>'
        )

    def file_row(self, file: dict) -> str:
        sha = ""
        if file["sha256"]:
            sha = (
                f'<button class="sha" type="button" data-copy="{esc(file["sha256"])}"'
                f' title="{esc(file["sha256"])}" data-copied="{esc(self.t("copied"))}"'
                f' aria-label="{esc(self.t("copySha", name=file["name"]))}">SHA-256</button>'
            )
        note = f'<p class="note">{esc(self.t(file["note"]))}</p>' if file["note"] else ""
        return (
            '<li class="file">'
            f'<span class="kind" aria-hidden="true">{esc(file["kind"])}</span>'
            '<div class="file-main">'
            f'<a class="file-title" href="{esc(file["url"])}">{esc(file["name"])}</a>{note}</div>'
            f'<div class="meta"><span>{esc(size_text(file["size"]))}</span>{sha}</div>'
            f'<span class="go" aria-hidden="true">{ICON["down"]}</span></li>'
        )

    def file_list(self, files: list[dict], by_arch: bool = True) -> str:
        """一个平台下的文件。按架构分段并在段首写上架构名 —— 同一个平台下
        amd64 和 arm64 的包长得只差一个词，混在一起列很容易下错。
        """
        out = []
        last = object()
        for file in files:
            if by_arch and file["arch"] != last:
                last = file["arch"]
                if last:
                    out.append(f'<li class="arch-label">{esc(self.t("archLabel", arch=last))}</li>')
            out.append(self.file_row(file))
        return f'<ul class="files">{"".join(out)}</ul>'


def _text(value, lang: str, default: str = "") -> str:
    """文案文件里既可以写 `x = "..."`（两种语言共用），也可以写 `x.zh` / `x.en`。"""
    if isinstance(value, dict):
        return value.get(lang) or value.get("zh") or value.get("en") or default
    if isinstance(value, str):
        return value
    return default


def display_name(pkg: dict, lang: str) -> str:
    """页面上把这个包叫什么。

    默认就是包名，而且用等宽字体 —— 对 apt 和 brew 的包来说那串字正是你要照着敲的
    东西，没有比它更该显示的。uTools 插件没有这回事：它在 uTools 里叫「两步验证
    FunOTP」，没有一条命令里会出现 `utools-funotp`，页面上顶着仓库名等于让人自己去
    对。文案文件里写了 `name.zh` / `name.en` 就用那个，并且不走等宽（等宽排中文是一
    个字一个格，而等宽的好处在这儿一条都用不上）。
    """
    return _text(pkg["page"].get("name"), lang) or pkg["name"]


# --------------------------------------------------------------------------------------
# 首页
# --------------------------------------------------------------------------------------


def setup_panes(site: Site) -> str:
    base = site.url
    apt = (
        f"curl -fsSL {base}farfarfun.gpg \\\n"
        "  | sudo tee /usr/share/keyrings/farfarfun.gpg >/dev/null\n"
        'echo "deb [signed-by=/usr/share/keyrings/farfarfun.gpg] '
        f'{base}deb stable main" \\\n'
        "  | sudo tee /etc/apt/sources.list.d/farfarfun.list\n"
        "sudo apt update"
    )
    brew = f"brew tap farfarfun/packages {REPO_URL}\nbrew trust farfarfun/packages"
    gitee = f"brew tap farfarfun/packages {GITEE_URL}\nbrew trust farfarfun/packages"

    def body(hint: str, command: str, *tips: str) -> str:
        return (
            f'<p class="pane-hint">{esc(hint)}</p>'
            + site.cmd(command)
            + f'<div class="extras">{"".join(tips)}</div>'
        )

    items = [
        {
            "id": "apt",
            "label": site.t("setupApt"),
            "os": "linux",
            "body": body(
                site.t("setupAptHint"),
                apt,
                site.tip(site.t("tipAptTitle"), site.t("tipApt")),
            ),
        },
        {
            "id": "brew",
            "label": site.t("setupBrew"),
            "os": "macos",
            "body": body(
                site.t("setupBrewHint"),
                brew,
                site.tip(site.t("tipTapTitle"), site.t("tipTap")),
                site.tip(site.t("tipTrustTitle"), site.t("tipTrust")),
            ),
        },
        {
            "id": "gitee",
            "label": site.t("setupGitee"),
            "os": None,
            "body": body(
                site.t("setupGiteeHint"),
                gitee,
                site.tip(site.t("tipGiteeTitle"), site.t("tipGitee")),
            ),
        },
    ]
    return site.panes("setup", items, site.t("setupTitle"))


def channel_chips(site: Site, pkg: dict) -> str:
    chips = [
        f'<li class="chip chip-{c}">{esc(site.t(CHANNEL_KEYS[c]))}</li>' for c in pkg["channels"]
    ]
    chips.append(f'<li class="chip ghost">{esc(site.t(KIND_KEYS[pkg["kind"]]))}</li>')
    return "".join(chips)


def package_cards(site: Site, packages: list[dict], up: str) -> str:
    cards = []
    for pkg in packages:
        latest = pkg["latest"]
        version = latest["tag"].lstrip("vV") if latest else ""
        meta = []
        if latest and latest["date"]:
            meta.append(site.t("cardReleased", date=date_text(latest["date"], site.lang)))
        arches = sorted({a for v in pkg["versions"] for a in v["arches"]})
        if arches:
            meta.append(" ".join(arches))
        tagline = _text(pkg["page"].get("tagline"), site.lang) or pkg["desc"]
        shown = display_name(pkg, site.lang)
        cards.append(
            '<li class="card">'
            f'<a class="card-head" href="{esc(up + pkg["name"])}/"'
            f' aria-label="{esc(site.t("cardView", name=shown))}">'
            f'<span class="card-name{"" if shown == pkg["name"] else " plain"}">'
            f"{esc(shown)}</span>"
            + (f'<span class="ver">{esc(version)}</span>' if version else "")
            + f'<span class="go" aria-hidden="true">{ICON["arrow"]}</span></a>'
            + (f'<p class="card-desc">{esc(tagline)}</p>' if tagline else "")
            + f'<ul class="chips">{channel_chips(site, pkg)}</ul>'
            + (f'<p class="card-meta">{esc(" · ".join(meta))}</p>' if meta else "")
            + "</li>"
        )
    return f'<div class="col"><ul class="cards">{"".join(cards)}</ul></div>'


# --------------------------------------------------------------------------------------
# 包页
# --------------------------------------------------------------------------------------


def install_panes(site: Site, pkg: dict, home: str) -> tuple[str, int]:
    name = pkg["name"]
    items = []
    for channel in pkg["channels"]:
        if channel == "apt":
            body = (
                f'<p class="pane-hint">{esc(site.t("installAptHint", name=name))}</p>'
                + site.cmd(f"sudo apt install {name}")
                + f'<p class="sub-label">{esc(site.t("installUpgrade"))}</p>'
                + site.cmd(f"sudo apt update && sudo apt install --only-upgrade {name}")
                + '<div class="extras">'
                + site.note_link(
                    site.t("installAptNeedsSetup"), f"{home}#setup", site.t("installSetupLink")
                )
                + "</div>"
            )
        elif channel == "brew":
            body = (
                f'<p class="pane-hint">{esc(site.t("installBrewHint"))}</p>'
                + site.cmd(f"brew install {name}")
                + f'<p class="sub-label">{esc(site.t("installUpgrade"))}</p>'
                + site.cmd(f"brew upgrade {name}")
                + '<div class="extras">'
                + site.note_link(
                    site.t("installBrewNeedsTap"), f"{home}#setup", site.t("installSetupLink")
                )
                + "</div>"
            )
        elif channel == "utools":
            # 这一节里唯一一个没有命令的面板。uTools 插件的装法是「下一个文件拖进窗
            # 口」，硬塞一个命令块只会多出一个复制了也没用的按钮 —— 所以这里给的是那
            # 个文件本身，用的还是下载区同一个文件行（名字、大小、校验和、下载）。
            app = pkg["app"] or name
            upx = next(
                (f for p in pkg["downloads"]["platforms"] for f in p["files"] if f["kind"] in ("UPXS", "UPX")),
                None,
            )
            body = (
                (
                    f'<p class="pane-hint">{esc(site.t("installUtoolsHint", app=app))}</p>'
                    + site.file_list([upx], by_arch=False)
                )
                if upx
                # 还没发过版，或者这一版忘了传 .upxs。不编一个下载链接出来，指到 Release
                # 页去 —— 那边有没有东西是看得见的。提示语也要换一句：上面那句说的是
                # 「下面这个 .upxs」，而下面没有。摆成空状态那个框：这一格本来该有一个
                # 文件行，一句飘着的灰字看着像页面没渲染完。
                else '<div class="empty">'
                + site.note_link(
                    site.t("installUtoolsEmpty"),
                    f"{pkg['url']}/releases",
                    site.t("installUtoolsReleases"),
                )
                + "</div>"
            ) + (
                '<div class="extras">'
                + (
                    site.tip(site.t("tipUtoolsStoreTitle"), site.t("tipUtoolsStore", app=app))
                    if pkg["store"]
                    else ""
                )
                + "</div>"
            )
        else:
            macos = (
                f'<p class="pane-note">{esc(site.t("installCaskMacos", version=pkg["min_macos"]))}</p>'
                if pkg["min_macos"]
                else ""
            )
            body = (
                '<p class="pane-hint">'
                + esc(site.t("installCaskHint", app=pkg["app"] or name))
                + "</p>"
                + site.cmd(f"brew install {name}")
                + f'<p class="sub-label">{esc(site.t("installUpgrade"))}</p>'
                + site.cmd(f"brew upgrade --cask {name}")
                + '<div class="extras">'
                + macos
                + site.note_link(
                    site.t("installBrewNeedsTap"), f"{home}#setup", site.t("installSetupLink")
                )
                + "</div>"
            )
        items.append(
            {
                "id": channel,
                "label": site.t(CHANNEL_KEYS[channel]),
                "os": CHANNEL_OS[channel],
                "body": body,
            }
        )

    # 文案文件里额外写的渠道（cargo、装机脚本之类），排在后面：它们是旁路，而
    # apt / brew 是这个仓库自己提供的那条。
    for extra in pkg["page"].get("install", []):
        note = _text(extra.get("note"), site.lang)
        items.append(
            {
                "id": extra["id"],
                "label": extra.get("title", extra["id"]),
                "os": extra.get("os"),
                "body": (f'<p class="pane-hint">{esc(note)}</p>' if note else "")
                + site.cmd(extra["cmd"]),
            }
        )
    return site.panes("install", items, site.t("installTitle")), len(items)


def shows_downloads(pkg: dict) -> bool:
    """下载一节出不出。导航上那一条和首屏那个按钮也跟着它走，三处必须是同一个答案。

    有附件就出，但有一个例外：只带一个 .upxs 的 uTools 插件。它的安装一节给出的就是那
    个文件本身 —— 装法只有「下载再拖进窗口」这一种，没有命令 —— 再开一节把同一行列
    第二遍，看着像页面出了错。别的包不存在这个问题：它们的安装是一条命令，下载区是另
    一回事。
    """
    downloads = pkg["downloads"]
    if not (downloads["platforms"] or downloads["other"]):
        return False
    if pkg["channels"] == ["utools"] and not downloads["other"]:
        return any(f["kind"] not in ("UPXS", "UPX") for p in downloads["platforms"] for f in p["files"])
    return True


def shows_versions(pkg: dict) -> bool:
    """版本一节出不出。和下载一节同理，导航那条链接也跟着它走。

    这一节讲的是「APT 索引里还留着哪几版」。不进索引又一版都没有的包（uTools 插件就
    是）出这一节，看到的永远是「源里留着 0 版 / 索引还没建起来」—— 一节空话。包真在
    索引里只是这次没扫出来的话照旧出：那是构建中途的真实状态，藏起来反而看不见。
    """
    return bool(pkg["versions"] or pkg["in_apt"])


def shows_shots(site: Site, pkg: dict) -> bool:
    """截图一节出不出。图没下到站里（离线渲染、或者那张图 404）就整节不出，导航同理。"""
    return any(shot.get("light") in site.shots for shot in pkg["page"].get("shots", []))


def download_panes(site: Site, pkg: dict) -> str:
    downloads = pkg["downloads"]
    items = []
    for platform in downloads["platforms"]:
        items.append(
            {
                "id": platform["id"],
                "label": site.t(f"plat{platform['id'].capitalize()}")
                if f"plat{platform['id'].capitalize()}" in site.strings[site.lang]
                else platform["id"],
                "os": PLATFORM_OS.get(platform["id"]),
                "body": site.file_list(platform["files"]),
            }
        )
    if downloads["other"]:
        items.append(
            {
                "id": "other",
                "label": site.t("platOther"),
                "os": None,
                "body": f'<p class="pane-hint">{esc(site.t("downloadOtherHint"))}</p>'
                + site.file_list(downloads["other"], by_arch=False),
            }
        )
    return site.panes("download", items, site.t("downloadTitle"))


def version_rows(site: Site, pkg: dict) -> str:
    if not pkg["versions"]:
        return f'<p class="empty">{esc(site.t("versionsEmpty"))}</p>'
    rows = []
    for i, version in enumerate(pkg["versions"]):
        meta = []
        if version["date"]:
            meta.append(site.t("cardReleased", date=date_text(version["date"], site.lang)))
        for arch, size in sorted(version["arches"].items()):
            meta.append(f"{arch} {size_text(size)}")
        tag = version["tag"]
        head = (
            f'<a class="ver" href="{esc(pkg["url"])}/releases/tag/{esc(tag)}">'
            f'{esc(version["version"])} {ICON["ext"]}</a>'
            if tag
            else f'<span class="ver">{esc(version["version"])}</span>'
        )
        latest = f'<span class="latest">{esc(site.t("versionsLatest"))}</span>' if i == 0 else ""
        # 回退命令只在这个包真在 APT 索引里时才给：tap 里一个包只有最新版，而写一条
        # 装不上的命令比不写更糟。
        command = (
            site.cmd(f"sudo apt install {pkg['name']}={version['version']}")
            if pkg["in_apt"]
            else ""
        )
        rows.append(
            '<li class="row">'
            f'<div class="row-main"><div class="ver-row">{head}{latest}</div>'
            + (f'<p class="note">{esc(" · ".join(meta))}</p>' if meta else "")
            + f"</div>{command}</li>"
        )
    return f'<ul class="rows">{"".join(rows)}</ul>'


def timeline(site: Site, pkg: dict) -> str:
    releases = pkg["changelog"]["releases"][:CHANGELOG_MAX]
    latest = pkg["latest"]["tag"] if pkg["latest"] else ""
    out = []
    for release in releases:
        groups = []
        for group in release["groups"]:
            key = f"type{group['type'].capitalize()}" if group["type"] else ""
            title = site.t(key) if key and key in site.strings[site.lang] else group["title"]
            heading = (
                f'<h3 class="group-title"><span class="mark" aria-hidden="true"></span>{esc(title)}</h3>'
                if title
                else ""
            )
            entries = []
            for entry in group["entries"]:
                scope = (
                    f'<span class="scope">{esc(entry["scope"])}</span>' if entry["scope"] else ""
                )
                commit = (
                    f'<a class="hash" href="{esc(pkg["url"])}/commit/{esc(entry["commit"])}">'
                    f'{esc(entry["commit"][:7])}</a>'
                    if entry["commit"]
                    else ""
                )
                entries.append(
                    '<li class="entry"><span class="entry-text">'
                    f'{scope}{esc(entry["text"])}</span>{commit}</li>'
                )
            groups.append(
                f'<section class="group{"" if group["type"] else " plain"}"'
                f' data-type="{esc(group["type"] or "plain")}">{heading}'
                f'<ul class="entries">{"".join(entries)}</ul></section>'
            )
        if release["empty"] and not groups:
            groups.append(f'<p class="empty">{esc(site.t("changelogEmpty"))}</p>')
        tag = release["tag"]
        when = (
            f'<span class="when"><time datetime="{esc(release["date"])}">'
            f'{esc(date_text(release["date"], site.lang))}</time></span>'
            if release["date"]
            else ""
        )
        out.append(
            f'<article class="release" id="{esc(tag)}" data-version="{esc(release["version"])}">'
            f'<header class="release-head"><div class="ver-row">'
            f'<a class="ver" href="#{esc(tag)}">{esc(release["version"])}</a>'
            + (
                f'<span class="latest">{esc(site.t("versionsLatest"))}</span>'
                if tag == latest
                else ""
            )
            + f'</div>{when}<span class="when">'
            f'<a href="{esc(pkg["url"])}/releases/tag/{esc(tag)}">'
            f'{esc(site.t("changelogOnGithub"))} {ICON["ext"]}</a></span></header>'
            f'<div class="release-body">{"".join(groups)}</div></article>'
        )
    return f'<div class="timeline" id="timeline">{"".join(out)}</div>'


def plain_log(site: Site, pkg: dict) -> str:
    """认不出结构的日志：只列版本和日期，正文留给 GitHub。

    和版本一节共用 `.row`，但多加一个 `compact`：那边每行右边还挂着一条安装命令，
    这边一行只有版本号和日期，照同样的行高铺开就是几行大字加一片空白。
    """
    rows = []
    for release in pkg["changelog"]["releases"][:CHANGELOG_MAX]:
        rows.append(
            '<li class="row"><div class="row-main"><div class="ver-row">'
            f'<a class="ver" href="{esc(pkg["url"])}/releases/tag/{esc(release["tag"])}">'
            f'{esc(release["version"])} {ICON["ext"]}</a></div>'
            + (
                f'<p class="note">{esc(site.t("cardReleased", date=date_text(release["date"], site.lang)))}</p>'
                if release["date"]
                else ""
            )
            + "</div></li>"
        )
    return f'<ul class="rows compact">{"".join(rows)}</ul>'


def search_box(site: Site) -> str:
    raw = site.strings[site.lang]["changelogResults"]
    return (
        f'<label class="search" for="cl-search">{ICON["search"]}'
        f'<input id="cl-search" type="search" autocomplete="off" spellcheck="false"'
        f' placeholder="{esc(site.t("changelogSearch"))}"'
        f' aria-controls="timeline" data-results="{esc(raw)}"'
        f' data-none="{esc(site.t("changelogNone"))}"'
        f' data-clear="{esc(site.t("changelogClear"))}">'
        '<kbd aria-hidden="true">/</kbd></label>'
        '<p class="cl-status" id="cl-status" aria-live="polite"></p>'
    )


def figures(site: Site, pkg: dict, up: str) -> tuple[str, str]:
    """截图，返回 (图, 容器的类)。路径要带 up —— 图在站点根下的 assets/shots，而包页
    在下一层。

    容器有两种摆法，看这个包的图是什么形状：横图三张以上就两张一行（funchat 那样四
    张桌面截图，一张一行要滚三屏），否则横图各占一行、竖图并排。
    """
    out = []
    wide = 0
    for shot in pkg["page"].get("shots", []):
        light = site.shots.get(shot.get("light", ""))
        if not light:
            continue
        dark = site.shots.get(shot.get("dark", ""))
        alt = _text(shot.get("alt"), site.lang)
        source = (
            f'<source srcset="{esc(up + dark["href"])}" media="(prefers-color-scheme: dark)">'
            if dark
            else ""
        )
        dims = (
            f' width="{light["width"]}" height="{light["height"]}"'
            if light.get("width")
            else ""
        )
        # 手机竖图和桌面横图不能一个摆法：780×1688 的竖图铺满右列就是一张 1700px 高
        # 的图，一个包三张能把页面撑到七千像素。竖的并排铺，横的整行但限高（样式在
        # style.css 的截图一节）。读不到尺寸就按横图走，和以前一样。
        tall = light.get("width") and light["height"] > light["width"] * 1.2
        shape = "tall" if tall else "wide"
        if not tall:
            wide += 1
        # alt 是写给读屏的，caption 是写给看图的人的 —— 一张截图上有什么，光看图经常
        # 认不出来（「顶部那一行是分组」）。只有一张图的包不写也行，四五张的就该写。
        caption = _text(shot.get("caption"), site.lang)
        out.append(
            f'<figure class="shot {shape}">'
            f'<a class="shot-link" href="{esc(up + light["href"])}" target="_blank" rel="noopener"'
            f' aria-label="{esc(site.t("shotsOpen", name=alt))}">'
            f'{"<picture>" if source else ""}{source}'
            f'<img src="{esc(up + light["href"])}"{dims}'
            + (' loading="eager" fetchpriority="high"' if not out else ' loading="lazy"')
            + ' decoding="async"'
            + f' alt="{esc(alt)}">{"</picture>" if source else ""}</a>'
            + (f"<figcaption>{esc(caption)}</figcaption>" if caption else "")
            + "</figure>"
        )
    return "".join(out), "shots pairs" if wide > 2 else "shots"


def package_sections(site: Site, pkg: dict, ctx: dict) -> str:
    """包页上 hero 之后的几节，编号按真出了哪几节连续排。

    节号是写死的 01/02/03 的话，没有下载区的包（纯 apt 的命令行工具可能就没有多平台
    附件）页面上会出现 01、03、04 —— 看起来像少了一块。
    """
    out = []
    num = 0

    def nxt() -> str:
        nonlocal num
        num += 1
        return f"{num:02d}"

    shots, shots_class = figures(site, pkg, ctx["up"])
    if shots:
        out.append(
            site.section(
                "sec-shots.html",
                {
                    **ctx,
                    "shotsClass": shots_class,
                    "figures": Raw(shots),
                },
            )
        )
    out.append(site.section("sec-overview.html", {**ctx, "num": nxt()}))

    panes, count = install_panes(site, pkg, ctx["home"])
    # 「加源」那条链接只对走 apt / brew 的包有意义。uTools 插件的装法是把 .upxs 拖进
    # 窗口，把人送到首页的三行命令那儿纯属添乱。
    needs_setup = any(channel in ("apt", "brew", "cask") for channel in pkg["channels"])
    setup_link = (
        f'<a href="{esc(ctx["home"])}#setup">{esc(site.t("installSetupLink"))}</a>'
        if needs_setup
        else ""
    )
    if count:
        out.append(
            site.section(
                "sec-install.html",
                {
                    **ctx,
                    "num": nxt(),
                    "sub": site.t("installSubOne" if count == 1 else "installSub", count=count),
                    "lead": site.t("installLeadOne" if count == 1 else "installLead"),
                    "links": Raw(setup_link),
                    "panes": Raw(panes),
                },
            )
        )

    downloads = pkg["downloads"]
    if shows_downloads(pkg):
        sums = (
            f'<a href="{esc(downloads["sums"])}">{esc(site.t("downloadSums"))}</a>'
            if downloads["sums"]
            else ""
        )
        out.append(
            site.section(
                "sec-download.html",
                {
                    **ctx,
                    "num": nxt(),
                    "sub": site.t("downloadSub", version=ctx["version"]),
                    "panes": Raw(download_panes(site, pkg)),
                    "sumsLink": Raw(sums),
                },
            )
        )

    if shows_versions(pkg):
        out.append(
            site.section(
                "sec-versions.html",
                {
                    **ctx,
                    "num": nxt(),
                    "sub": site.t("versionsSub", count=len(pkg["versions"])),
                    "rows": Raw(version_rows(site, pkg)),
                },
            )
        )

    log = pkg["changelog"]
    if log["releases"]:
        structured = log["structured"]
        shown = min(len(log["releases"]), CHANGELOG_MAX)
        out.append(
            site.section(
                "sec-changelog.html",
                {
                    **ctx,
                    "num": nxt(),
                    "sub": site.t("changelogSubOne" if shown == 1 else "changelogSub", count=shown),
                    "lead": site.t("changelogLead" if structured else "changelogPlain"),
                    "search": Raw(search_box(site) if structured else ""),
                    "body": Raw(timeline(site, pkg) if structured else plain_log(site, pkg)),
                },
            )
        )

    return "".join(out)


# --------------------------------------------------------------------------------------
# 页面装配
# --------------------------------------------------------------------------------------


def nav_links(site: Site, items: list[tuple[str, str]]) -> str:
    return "".join(f'<a href="{esc(href)}">{esc(site.t(key))}</a>' for href, key in items)


def head_ctx(site: Site, lang: str, locale: str, og: str, prefix: str, pkg: str | None) -> dict:
    depth = len(f"{prefix}{pkg + '/' if pkg else ''}".rstrip("/").split("/")) if (prefix or pkg) else 0
    up = "../" * depth
    home = "../" * (depth - (1 if prefix else 0))
    tail = f"{pkg}/" if pkg else ""
    other = next(p for lg, _, _, p in LANGS if lg != lang)
    other_locale = next(lc for lg, lc, _, _ in LANGS if lg != lang)
    alternates = [
        f'  <link rel="alternate" hreflang="{lc}" href="{site.url}{p}{tail}">'
        for _, lc, _, p in LANGS
    ]
    alternates.append(f'  <link rel="alternate" hreflang="x-default" href="{site.url}{tail}">')
    return {
        "lang": lang,
        "locale": locale,
        "ogLocale": og,
        "up": up,
        # 自己就是首页时写 `./` 而不是空串：`href=""` 虽然也指向当前页，但它在地址栏
        # 和历史记录里是「重新加载」的语义，而这是一个链接。
        "home": home or "./",
        "canonical": f"{site.url}{prefix}{tail}",
        "otherHref": f"{up}{other}{tail}",
        "otherLocale": other_locale,
        "alternates": Raw("\n".join(alternates)),
    }


def jsonld(data: dict) -> Raw:
    text = json.dumps(data, ensure_ascii=False).replace("<", "\\u003c")
    return Raw(f'  <script type="application/ld+json">{text}</script>')


def render_home(site: Site, lang: str, locale: str, og: str, prefix: str) -> str:
    site.lang = lang
    ctx = head_ctx(site, lang, locale, og, prefix, None)
    packages = site.data["packages"]
    apps = [p for p in packages if "utools" not in p["channels"]]
    plugins = [p for p in packages if "utools" in p["channels"]]
    dates = [p["latest"]["date"] for p in packages if p["latest"] and p["latest"]["date"]]
    eyebrow = (
        site.t("homeEyebrow", count=len(packages), date=date_text(max(dates), lang))
        if dates
        else site.t("homeEyebrowBare", count=len(packages))
    )
    ctx.update(
        {
            "pageTitle": site.t("homePageTitle"),
            "pageDescription": site.t("homeDescription"),
            "jsonld": jsonld(
                {
                    "@context": "https://schema.org",
                    "@type": "WebSite",
                    "name": site.t("brand"),
                    "url": site.url + prefix,
                    "description": site.t("homeDescription"),
                    "inLanguage": locale,
                }
            ),
            "navLinks": Raw(
                nav_links(
                    site,
                    [("#setup", "navSetup"), ("#packages", "navPackages"),
                     ("#utools", "pluginsTitle"), ("#how", "navHow")],
                )
            ),
            "eyebrow": eyebrow,
            "packagesSub": site.t("packagesSub", count=len(apps)),
            "pluginsSub": site.t("pluginsSub", count=len(plugins)),
            "fingerprint": Raw(
                f'<p class="rail-note">{esc(site.t("setupFingerprint"))}'
                f'<code>{esc(fingerprint_text(site.data["fingerprint"]))}</code></p>'
                if site.data["fingerprint"]
                else ""
            ),
            "setupPanes": Raw(setup_panes(site)),
            "cards": Raw(package_cards(site, apps, ctx["home"])),
            "pluginCards": Raw(package_cards(site, plugins, ctx["home"])),
        }
    )
    return site.render("home.html", ctx)


def render_package(site: Site, pkg: dict, lang: str, locale: str, og: str, prefix: str) -> str:
    site.lang = lang
    ctx = head_ctx(site, lang, locale, og, prefix, pkg["name"])
    latest = pkg["latest"]
    version = latest["tag"].lstrip("vV") if latest else ""
    release_url = (
        f"{pkg['url']}/releases/tag/{latest['tag']}" if latest else f"{pkg['url']}/releases"
    )
    if latest and latest["date"]:
        eyebrow = site.t("pkgEyebrow", version=version, date=date_text(latest["date"], lang))
    elif version:
        eyebrow = site.t("pkgEyebrowBare", version=version)
    else:
        eyebrow = site.t("versionsAll")

    features = ""
    items = pkg["page"].get("features", [])
    if items:
        rows = "".join(
            f"<li><b>{esc(_text(f.get('title'), lang))}</b>"
            f"<span>{esc(_text(f.get('text'), lang))}</span></li>"
            for f in items
        )
        features = f'<ul class="facts">{rows}</ul>'

    has_downloads = shows_downloads(pkg)
    has_install = bool(pkg["channels"] or pkg["page"].get("install"))
    shown = display_name(pkg, lang)
    ctx.update(
        {
            "pkgName": shown,
            # 包名用等宽（那串字是要照着敲的），显示名不用。见 display_name。
            "heroClass": "display mono" if shown == pkg["name"] else "display",
            "version": version,
            "repoUrl": pkg["url"],
            "releaseUrl": release_url,
            "eyebrow": eyebrow,
            "tagline": _text(pkg["page"].get("tagline"), lang) or pkg["desc"],
            "pageTitle": site.t("pkgPageTitle", name=shown),
            "pageDescription": _text(pkg["page"].get("description"), lang)
            or _text(pkg["page"].get("tagline"), lang)
            or pkg["desc"],
            "chips": Raw(channel_chips(site, pkg)),
            "features": Raw(features),
            "contentAnchor": "#screens" if shows_shots(site, pkg) else "#overview",
            "primaryHref": "#install" if has_install else ("#download" if has_downloads else release_url),
            "primaryLabel": site.t("pkgCtaInstall" if has_install else "pkgCtaDownload"),
            "ctaDownload": Raw(
                f'<a class="btn quiet" href="#download">{esc(site.t("pkgCtaDownload"))}</a>'
                if has_install and has_downloads
                else ""
            ),
        }
    )
    ctx["description"] = Raw(
        f'<p class="overview-description">{esc(ctx["pageDescription"])}</p>'
        if ctx["pageDescription"] != ctx["tagline"] else ""
    )
    ctx["jsonld"] = jsonld(
        {
            "@context": "https://schema.org",
            "@type": "SoftwareApplication",
            "name": shown,
            # 显示名和包名不一样时两个都报上去：页面标题里只剩显示名了，而搜
            # `utools-funotp` 的人找的就是这一页。
            **({"alternateName": pkg["name"]} if shown != pkg["name"] else {}),
            "url": ctx["canonical"],
            "description": ctx["pageDescription"],
            "applicationCategory": "UtilitiesApplication",
            "operatingSystem": ", ".join(
                site.t(f"plat{p['id'].capitalize()}")
                for p in pkg["downloads"]["platforms"]
                if f"plat{p['id'].capitalize()}" in site.strings[lang]
            )
            or "Linux",
            **({"softwareVersion": version} if version else {}),
            "downloadUrl": release_url,
            "isAccessibleForFree": True,
            "offers": {"@type": "Offer", "price": "0", "priceCurrency": "USD"},
            "sameAs": [pkg["url"]],
        }
    )
    nav = [("#screens", "navScreens")] if shows_shots(site, pkg) else []
    nav.append(("#overview", "overviewTitle"))
    if has_install:
        nav.append(("#install", "navInstall"))
    if has_downloads:
        nav.append(("#download", "navDownload"))
    if shows_versions(pkg):
        nav.append(("#versions", "navVersions"))
    if pkg["changelog"]["releases"]:
        nav.append(("#changelog", "navChangelog"))
    ctx["navLinks"] = Raw(nav_links(site, nav))
    ctx["sections"] = Raw(package_sections(site, pkg, ctx))
    return site.render("package.html", ctx)


# --------------------------------------------------------------------------------------
# 截图
# --------------------------------------------------------------------------------------


def fetch_shots(site: Site, out: Path) -> None:
    """把文案文件里指到的截图下到站点里，而不是让页面从别处热链。

    下到自己站上的理由：这些图在各项目仓库里（funclash 的在 docs/snapshots），而
    raw.githubusercontent 和 Pages 是两套缓存和两套可用性 —— 页面上的图不该因为另一个
    域名挂了而空一块。二进制不进这个仓库的 git，和 .deb 是同一个道理（见 README）。
    """
    # 按包分子目录，不平铺。各项目的截图都叫 home.png / dark.png / settings.png 这类
    # 通名，平铺的话第二个包的 home.png 会盖掉第一个的，而且两边的 href 指向同一个
    # 文件 —— 页面上两个包显示同一张图，构建全绿。
    urls: dict[str, str] = {}
    for pkg in site.data["packages"]:
        for shot in pkg["page"].get("shots", []):
            for key in ("light", "dark"):
                if shot.get(key):
                    urls.setdefault(shot[key], pkg["name"])
    if not urls:
        return
    for url, pkg_name in urls.items():
        name = url.rsplit("/", 1)[-1]
        href = f"assets/shots/{pkg_name}/{name}"
        target = out / href
        target.parent.mkdir(parents=True, exist_ok=True)
        try:
            with urllib.request.urlopen(url, timeout=30) as response:
                target.write_bytes(response.read())
        except (urllib.error.URLError, OSError) as e:
            warn(f"截图下不来，跳过：{url}（{e}）")
            continue
        entry = {"href": href, "name": name}
        dims = png_size(target)
        if dims:
            entry["width"], entry["height"] = dims
        site.shots[url] = entry


# --------------------------------------------------------------------------------------


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def sitemap(site: Site, pages: list[str]) -> str:
    opening = (
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"'
        ' xmlns:xhtml="http://www.w3.org/1999/xhtml">'
    )
    out = ['<?xml version="1.0" encoding="UTF-8"?>', opening]
    for tail in pages:
        links = "".join(
            f'<xhtml:link rel="alternate" hreflang="{lc}" href="{site.url}{p}{tail}"/>'
            for _, lc, _, p in LANGS
        )
        for _, _, _, prefix in LANGS:
            out.append(f"  <url><loc>{site.url}{prefix}{tail}</loc>{links}</url>")
    out.append("</urlset>")
    return "\n".join(out) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="渲染 farfarfun 包仓库的站点")
    parser.add_argument("src", type=Path, help="模板目录（site）")
    parser.add_argument("out", type=Path, help="输出目录")
    parser.add_argument("--packages", default="packages.toml")
    parser.add_argument("--deb", type=Path, help="build-deb-repo.sh 的输出目录")
    parser.add_argument("--pages", type=Path, help="包页文案目录，默认 <site>/pages")
    parser.add_argument("--fingerprint", default="", help="签名密钥指纹，显示在加源一节")
    parser.add_argument("--offline", action="store_true", help="一次 gh 都不调")
    parser.add_argument("--site-url", default=SITE_URL, help="站点地址，用来拼 canonical")
    args = parser.parse_args()

    data = sitedata.collect(
        args.packages,
        args.deb,
        args.pages if args.pages is not None else args.src / "pages",
        args.offline,
        args.fingerprint,
    )
    bad = [p["name"] for p in data["packages"] if p["name"] in RESERVED]
    if bad:
        raise SystemExit(f"包名和站点自己的目录撞了：{', '.join(bad)}")

    out = args.out
    out.mkdir(parents=True, exist_ok=True)
    site = Site(args.src, out, data, args.site_url.rstrip("/") + "/")

    shutil.copytree(args.src / "assets", out / "assets", dirs_exist_ok=True)
    shutil.copy2(args.src / "favicon.svg", out / "favicon.svg")
    if not args.offline:
        fetch_shots(site, out)

    written = []
    for lang, locale, og, prefix in LANGS:
        write(out / prefix / "index.html", render_home(site, lang, locale, og, prefix))
        written.append(out / prefix / "index.html")
        for pkg in data["packages"]:
            path = out / prefix / pkg["name"] / "index.html"
            write(path, render_package(site, pkg, lang, locale, og, prefix))
            written.append(path)

    tails = [""] + [f"{p['name']}/" for p in data["packages"]]
    write(out / "sitemap.xml", sitemap(site, tails))
    write(out / "robots.txt", f"User-agent: *\nAllow: /\nSitemap: {site.url}sitemap.xml\n")
    write(out / "packages.json", json.dumps(data, ensure_ascii=False, indent=2) + "\n")

    # 自检。模板里漏了一个占位符、或者某个包少渲染了一页，都是「页面看着还行但缺了
    # 东西」那一类故障 —— 和 build-deb-repo.sh 核对索引条数一个道理，当场判死。
    for path in written:
        if "{{" in path.read_text():
            raise SystemExit(f"{path} 里还有没填的占位符")
    want = len(LANGS) * (1 + len(data["packages"]))
    if len(written) != want:
        raise SystemExit(f"该出 {want} 个页面，实际出了 {len(written)} 个")

    print(f"渲染了 {len(written)} 个页面到 {out}（{len(data['packages'])} 个包 × {len(LANGS)} 种语言）")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
