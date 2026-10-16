# 接入 farfarfun 包仓库

把这份文档交给一个项目，它照着做完就会：

- 出现在 <https://farfarfun.github.io/packages> 上，并且有自己的一页（`/<包名>/`，中英各一份）
- 能 `sudo apt install <包名>`（加过一次源之后）
- 能 `brew install <包名>`（命令行工具出 formula，桌面应用出 cask）

全组织共用一个源、一个 tap、一把签名密钥。**项目这边要做的只有一件事：按约定发
release。**剩下的是在 [farfarfun/packages](https://github.com/farfarfun/packages)
里加几行配置，加完之后每次发版都是自动的。

> 为什么要有这份文档：收进来的项目越来越多，而「约定」如果只活在三个脚本的实现
> 里，接入的人就只能靠试。下面每一条约定都对应代码里的一行判断，并且有一条命令
> 能自检（见[第 7 节](#7-自检)）。

---

## 0. 三件事

| 做什么 | 在哪儿 | 谁做 | 要多久 |
| --- | --- | --- | --- |
| ① 按约定发 release | 你的项目仓库 | 项目维护者 | 一次性改 release workflow |
| ② 在 `packages.toml` 里加一节 | farfarfun/packages | 任何人，一个 PR | 五行 |
| ③ 写一份站点文案（可选） | farfarfun/packages 的 `site/pages/<包名>.toml` | 项目维护者 | 二十行 |

② 之后，这边每两小时扫一遍各项目的 Release，发现新版就重建索引、重渲染 formula
和 cask、重新发站点。想发版后立刻生效，加[第 5 节](#5-发版后立刻生效可选)那一步。

---

## 1. 发布约定

### 1.1 release 本身

| 要求 | 说明 |
| --- | --- |
| tag 形如 `v1.2.3` 或 `1.2.3` | 带不带 `v` 都收，但同一个项目要前后一致 —— cask 的 url 把 tag 的前缀当字面量 |
| 版本号是 `X.Y.Z` | 比较版本时按段拆数字，认不出的段当 0 |
| 必须是正式 release | 草稿和预发布一律不收：它们是给人单独试的，不该让 `apt upgrade` 自动装上 |

### 1.2 附件命名

这是整份文档最要紧的一节。**附件名就是接口**，三个渲染器都按名字认。

| 渠道 | 文件名 | 架构取值 | 缺了会怎样 |
| --- | --- | --- | --- |
| apt | `<包名>_<版本>_<架构>.deb` | `amd64`、`arm64` | 那个架构的机器在 `apt list` 里看不到这个包 |
| formula | `<包名>-<target>.tar.gz` | 见下 | 少一个平台就不渲染那一块（不是错） |
| cask | `<应用名>-<版本>-macos-<架构>.dmg` | `arm64`、`amd64` | **两个缺一个，整份 cask 都不生成** |

- `<包名>` 一律小写（Debian 对 `Package` 字段的要求），并且**等于 GitHub 仓库名** ——
  这个组织不单独配包名映射。
- `<版本>` 不带 `v`。
- `<应用名>` 是桌面应用的显示名，通常和包名不一样（`FunClash` 对 `funclash`）：
  它既是 DMG 名的前缀，也是装进 `/Applications` 的 `.app` 名。
- formula 的 target 认这四个：
  `aarch64-apple-darwin`、`x86_64-apple-darwin`、
  `aarch64-unknown-linux-musl`、`x86_64-unknown-linux-musl`。
  Linux 用 musl 而不是 gnu：静态链接的包不挑 glibc 版本，老发行版也能装。
  **这四个名字只是约定好的平台标签，和项目用什么语言写的无关** —— 它们长得像 Rust
  的目标三元组，是因为头两个收进来的项目是 Rust 的。Python / Go / Zig 写的工具照用
  这四个名字，渲染器只按名字取文件。
- `.tar.gz` 里是**一个可执行文件**，名字等于包名（或 `[source.brew].bin` 指定的名字）。
  formula 的 `bin.install` 直接装它。

**不是编译型语言的项目**（纯 Python、Node 之类）要进 apt 和 brew 这两条线，得先有一个
**自带运行时的单文件可执行程序**（PyInstaller、Nuitka、shiv、pkg 之类打出来的那种），
它才是上面那些附件里装的东西。这不是形式要求：apt 和 brew 的承诺是「装上就能跑」，
而一个依赖机器上恰好有对版本 Python 和一串第三方包的脚本给不了这个承诺 —— 那条路是
`pip` / `uv`，站点上可以把它写成一条额外渠道（见[第 3 节](#3-站点文案-sitepages包名toml可选)
的 `[[install]]`），但它不进索引也不进 tap。库本身只发 PyPI 的项目，今天这个仓库收不了。

### 1.3 `SHA256SUMS`（必需）

release 里要有一个名字就叫 `SHA256SUMS` 的附件，覆盖这次发布的所有文件：

```
e0980a95...b7efd7  fundeploy-aarch64-apple-darwin.tar.gz
85d3430e...f83188  fundeploy_0.3.7_amd64.deb
```

二进制模式的 `<hash> *<文件名>` 也认。

- 它是 formula 和 cask 校验和的**唯一来源**。没有它，这两份文件一行都生成不出来。
- **最后一步生成**：先算校验和再上传别的附件，后上传的那些就不在里面。

### 1.4 站点下载区怎么认附件

页面上的「下载」一节按文件名把附件分到平台和架构里。认法是这样（`scripts/sitedata.py`）：

| 看什么 | 怎么认 |
| --- | --- |
| 扩展名定平台 | `.apk`→Android，`.dmg`/`.pkg`→macOS，`.exe`/`.msi`→Windows，`.deb`/`.rpm`/`.AppImage`→Linux |
| 名字里的关键字定平台 | `android`、`apple-darwin`/`macos`/`darwin`、`pc-windows`/`windows`、`linux` |
| 架构 | `arm64-v8a`、`armeabi-v7a`、`aarch64`/`arm64`、`x86_64`/`amd64`/`x64`、`i686`/`i386` |
| 链接方式 | 名字里有 `musl` 标成静态链接，有 `-gnu` 标成动态链接 |
| 安装器 | Windows 下名字里有 `setup` 的算安装程序，`.zip` 算便携版 |

- `SHA256SUMS` 渲染成一条校验和链接，不占下载表的一行。
- `.whl`、`.sig`、`.asc`、`.sha256`、`.minisig`、`.pem` 不显示（它们有自己的渠道）。
- **认不出平台的附件不会丢**，会进可折叠的「其它文件」—— 但也就只是列在那儿。
  想让它进某个平台，按上面的关键字改名。

---

## 2. 在 `packages.toml` 里加一节

```toml
[[source]]
repo = "farfarfun/funget"
# 索引里保留最近几版。留多于一个是为了能 `apt install funget=1.1.73` 回退。
keep = 3
# 可选：比这更早的 tag 不收。
min_version = "1.1.73"
# 可选：这个包装出来的是窗口程序，没有能在无头 runner 上跑的命令行入口。
cli = false

# 有这一节才生成 formula。desc 用英文：brew 的搜索和 `brew desc` 都读它。
[source.brew]
desc = "HTTP file transfer tool with ranged concurrency and resume"
bin = "funget"                  # 可执行文件名和包名不一样时才写
license = "MIT"                 # 不写就是 MIT
checks = [["--help", "download"]]   # brew test 里的额外断言：[参数, 输出里该出现的字串]

# 发 DMG 的桌面应用用这一节代替 [source.brew]。
[source.cask]
app = "FunClash"                # 显示名：DMG 名的前缀，也是 .app 的名字
desc = "Multi-platform proxy client based on mihomo (Clash.Meta)"
min_macos = "monterey"          # 可选，Homebrew 的符号名
bundle_id = "com.farfarfun.funclash"   # 可选，`brew uninstall --zap` 按它清用户数据
```

| 字段 | 作用 | 默认 |
| --- | --- | --- |
| `repo` | `<组织>/<仓库>`，包名取仓库名 | 必填 |
| `keep` | 索引里留最近几版 | 3 |
| `min_version` | 收版本的下限。管的是「收哪几版进源」，不管「这个项目有过哪些版本」—— 页面上的更新日志不受它影响 | 无 |
| `cli` | 装出来有没有能跑 `--version` 的命令行入口 | `true` |
| `[source.brew]` | 有这一节才出 formula | 无 |
| `[source.cask]` | 有这一节才出 cask | 无 |

**体积要算一下。** 整个 Pages 站点上限 1 GB，而 `.deb` 是按 `keep` 份数×架构数累加的：
命令行工具几 MB，`keep = 3` 很合适；一个 45 MB 的桌面应用两个架构，`keep = 2`
就占去 180 MB。

**`cli = false` 是给装机验证看的**：CI 默认拿可执行文件跑 `--version`，而窗口程序在
无头 runner 上只会卡住。标了之后改成验 `.desktop` 的 `Exec` 指到的东西在 PATH 上、
版本问 `dpkg-query`。

---

## 3. 站点文案 `site/pages/<包名>.toml`（可选）

不写也有页面，只是首屏用 `packages.toml` 里那句英文 `desc`，没有功能点和截图。

```toml
# 标语：首屏那句话。写成 x.zh / x.en 两种语言；只写一个字符串的话两边共用。
tagline.zh = "HTTP 文件传输工具：Range 并发下载、断点续传、PUT/POST 上传。"
tagline.en = "HTTP file transfer tool with ranged concurrency, resume and PUT/POST upload."

# 搜索引擎和分享卡片用的简介。不写就用 tagline。
description.zh = "……"
description.en = "……"

# 首屏下面那一行四格。写几条出几条，建议四条（排版是四列的）。
[[features]]
title.zh = "并发下载"
title.en = "Ranged concurrency"
text.zh = "按 Range 切块并发拉，断了能接着下。"
text.en = "Splits a file by range, downloads in parallel and resumes."

# 截图。只认 PNG —— 宽高是从文件头读出来写进 <img> 的，为的是加载时不跳版。
# 图放在你自己的项目仓库里，这边构建时下到站点下面，不热链。
[[shots]]
light = "https://raw.githubusercontent.com/<组织>/<仓库>/master/docs/snapshots/preview.png"
dark = "https://raw.githubusercontent.com/<组织>/<仓库>/master/docs/snapshots/preview-dark.png"   # 可选
alt.zh = "……界面"
alt.en = "…… interface"

# apt / brew 之外的渠道，排在安装分段的后面。
[[install]]
id = "cargo"          # 这一页里要唯一，它会变成 DOM 的 id
title = "Cargo"       # 分段上的标签
cmd = "cargo install funget"
note.zh = "有 Rust 工具链的话。"
note.en = "If you have a Rust toolchain."
os = "macos"          # 可选：页面按访客系统预选分段时用，留空就不会被自动选中
```

---

## 4. `CHANGELOG.md`（可选，但格式决定展示成什么样）

包页上的「更新日志」一节取的是**发布那一刻**（按 tag 取，不是默认分支）的
`CHANGELOG.md`。两种结果：

**一、能解析成结构**（带分组标签的时间线，每条可点到 commit）：

```markdown
# Changelog

## v1.0.2 (2026-10-16)

**Features**

- **ui** A new app icon (a751b61)
- **remote** Turning on the remote panel now installs it for you (7bfb6af)

## v1.0.1 (2026-10-16)

**Breaking Changes**

- Rename the binaries to FunClash (b90568f)
```

- 版本标题：`## v1.0.2 (2026-10-16)`、`## [0.3.7] - 2026-10-16`、`## 1.2.0` 三种都认
- 分组标题：**单独一行的粗体**。`Breaking Changes`、`Features`、`Bug Fixes`、
  `Performance`、`Reverts` 会上色并翻译，其它标题按原文显示
- 条目：`- **范围** 文案 (commit 短 hash)`，`**范围**` 和 `(hash)` 都可以没有
- 续行：缩进的行接到上一条后面
- HTML 注释（`<!-- … -->`）会被跳过，可以放生成器的标记

**二、解析不出结构**（只列版本号、日期和一条指向 Release 的链接）。

判据是**每一行都被认下来了**，不是「认出了几行」。原因：拿上面那套规则去套一份
手写的长文日志，能认出零散几条 bullet，然后把它们之间的段落全丢掉 —— 页面上就是
一份被截过的、看不出在说什么的日志。宁可整块不渲染。

**所以：日志是 `git-cliff` / `funbuild` 这类工具生成的，就能拿到时间线；是人手写的
长文，就老老实实只列版本号。**两种都行，不要为了凑格式把日志写坏。

---

## 5. 发版后立刻生效（可选）

不加这一步也是对的：这边每两小时（`17 */2 * * *`）自己扫一遍，代价只是「发版后最多
等两小时才能 `apt install` 到新版」。加这一步的代价是项目仓库里要长期存一个 PAT
并盯着它过期 —— 跨仓库写绕不开这个，`GITHUB_TOKEN` 只对本仓库有效。

```yaml
  notify-packages:
    needs: release
    runs-on: ubuntu-latest
    steps:
      - env:
          GH_TOKEN: ${{ secrets.PACKAGES_DISPATCH_TOKEN }}
        run: |
          [ -n "$GH_TOKEN" ] || { echo "没配 token，跳过"; exit 0; }
          gh api repos/farfarfun/packages/dispatches -f event_type=package-published
```

等不了又不想存 PAT 的话，手动打一下，用的是人的身份：

```bash
gh workflow run build.yml -R farfarfun/packages
```

---

## 6. CI 会验什么

每次构建都真装一遍。接进来之后，这几个 job 红了就是你的发布出了问题：

| job | 做什么 | 常见红法 |
| --- | --- | --- |
| `verify` | 加源、`apt install`、再退一版装一遍 | 少了某个架构的 `.deb`；版本号和 tag 对不上 |
| `verify-brew` | 真 tap 一遍再 `brew install`，跑 `brew test` | `.tar.gz` 里不是单个二进制；`--version` 不打版本号；`checks` 的断言不成立 |
| `verify-cask` | macOS runner 上装 cask，读 `.app` 的 `Info.plist` 跟声明的版本对账 | DMG 里的 `.app` 名字和 `app =` 不一致；`CFBundleShortVersionString` 不是这一版 |
| `verify-brew-gitee` | 掐掉 GitHub，从 Gitee 镜像 tap 再装一遍 | 项目没有 Gitee 镜像（这时不写 mirror，不会红）；镜像落后一版 |

命令行工具的 `--version` 必须打出版本号本身（`brew test` 的默认断言就是它）。

---

## 7. 自检

接入前后各跑一遍，看站点认出了什么：

```bash
git clone https://github.com/farfarfun/packages && cd packages
python3 scripts/sitedata.py packages.toml --check <包名>
```

输出长这样：

```
funclash  farfarfun/funclash
  最新 release   v1.0.2（2026-10-16）
  渠道           apt, cask
  SHA256SUMS     有
  .deb           amd64、arm64 都有
  cask DMG       arm64、amd64 都有
  下载区 android  3 个文件
  下载区 linux    6 个文件
  ? 认不出平台   FunClash-1.0.2-panel.zip
  更新日志       结构化时间线，3 个版本
  页面文案       标语 有、功能点 4 条、截图 1 张、额外渠道 0 条
```

想看页面真长什么样（不用等 CI，也不用有 GPG 密钥）：

```bash
python3 scripts/render-site.py site /tmp/preview --packages packages.toml
python3 -m http.server -d /tmp/preview 8000   # 然后开 localhost:8000/<包名>/
```

需要 `gh` 已登录（只读公开 release）。没登录也能渲染，只是取不到的那几块不出。

---

## 8. 容易踩的坑

**包名大小写。** Debian 要求 `Package` 全小写，而桌面应用在界面上通常是驼峰的。
这个组织的约定是：包名 = 仓库名 = 小写，显示名写在 `[source.cask].app` 里，DMG 的
文件名用显示名、`.deb` 的文件名用包名。两者不一致是正常的。

**`SHA256SUMS` 生成得太早。** 它必须覆盖所有附件。先算完再上传 `.deb` 的话，
formula 能出、cask 出不来，而且报的是「附件里缺 xxx.dmg」，看着像构建矩阵的问题。

**只发了一个架构。** apt 那边不会报错，只是另一个架构的机器 `apt install` 时报
「没有可安装的候选」—— 每个架构有自己的索引。cask 那边是直接不生成。

**改过包名。** 老 tag 里的附件还是老名字，收进来会扫不到或者装出一个谁也不认识的
包。用 `min_version` 把改名之前的 tag 挡在外面。

**预发布。** 打了 `v1.0.0-rc1` 这种 tag 又勾了 prerelease 的，这边一律不收；没勾
prerelease 的话会被当成正式版收进来，而版本比较只看 `-` 前面那一截。

**站点上少了一块。** 先跑第 7 节那条自检命令。页面上每一块都对应一份数据，数据
取不到就整块不出，不会显示一个空壳 —— 所以「少了一块」永远是数据的问题，不是
样式的问题。
