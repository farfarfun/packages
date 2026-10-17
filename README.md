# farfarfun/packages

farfarfun 所有项目共用的包仓库。**用户只加一次源**，以后新增的包直接装。
这个仓库同时是 APT 源和 Homebrew tap。

站点: <https://farfarfun.github.io/packages>（每个包还有自己的一页，中英各一份）

接一个新项目进来：**[docs/package-spec.md](docs/package-spec.md)** —— 发布约定、
清单字段、页面文案格式和自检命令都在里面，那份文档可以直接丢给项目维护者。

## 安装

### APT

```bash
curl -fsSL https://farfarfun.github.io/packages/farfarfun.gpg \
  | sudo tee /usr/share/keyrings/farfarfun.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/farfarfun.gpg] https://farfarfun.github.io/packages/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/farfarfun.list
sudo apt update && sudo apt install fundeploy
```

### Homebrew

```bash
brew tap farfarfun/packages https://github.com/farfarfun/packages
brew trust farfarfun/packages
brew install fundeploy
```

**`tap` 那行要把 URL 写出来**：`brew tap a/b` 默认去找 `github.com/a/homebrew-b`，而
这个仓库还要当 apt 源用，叫 `homebrew-packages` 的话 apt 地址里会凭空多出 homebrew
几个字。URL 形式是 brew 支持的，只是第一次多打一截。

**`trust` 那行不能省**：Homebrew 6.0 起第三方 tap 默认不可信，不 trust 的话裸名字
会被直接拒绝（`Refusing to load formula ... from untrusted tap`）。写全名
`brew install farfarfun/packages/fundeploy` 能装，是因为它顺带只信任了那一个
formula——所以很容易误以为是裸名字本身的问题。这儿 trust 整个 tap：这个仓库本来就
是用来一次管全组织的包的，逐个信任等于每加一个包再来一遍。

两行都过了之后就是裸名字装，brew 在所有已 tap 的仓库里解析。只有 homebrew-core 里
出现同名包时才需要写全路径——CI 的 `verify-brew` 每次都按裸名字装一遍，真撞名了那边
会先红。

#### macOS 上的桌面应用

桌面应用走 cask，装的是 DMG 里的 `.app`，不是命令行二进制：

```bash
brew install funclash          # 装进 /Applications/FunClash.app
brew uninstall --zap funclash  # 连 ~/Library 下的用户数据一起清
```

还是裸名字，不用写 `--cask`：brew 在已 tap 的仓库里按名字解析，formula 和 cask 都在
里面。cask 只有 macOS 一条线——linuxbrew 压根不读它，所以 CI 里 `verify-cask` 是整个
仓库唯一一个 macOS job。它装完会读 `.app` 自己的 `Info.plist` 跟 cask 声明的版本对
账：GUI 应用没有 `--version` 可问，而「装上了」和「装上的是这一版」是两件事。

#### GitHub 连不上的时候

formula 里每个 `url` 都配了一条 Gitee `mirror`，下包这一步 brew 自己会回落，不用
配任何东西。但 `brew tap` 做的是 git clone，那一步没有回落可言——改成从 Gitee 的
镜像 tap：

```bash
brew tap farfarfun/packages https://gitee.com/farfarfun/packages
brew trust farfarfun/packages
brew install fundeploy
```

镜像由本仓库的 `sync-gitee` 推过去，push 即跟（formula 是 CI 自己提交的，那种提交
不触发 workflow，所以构建完会额外打一下 `sync-gitee`，并且等它跑完才往下走）。两边
formula 一字不差，装出来的也是同一批二进制——mirror 和 url 共用同一行 `sha256`，对不
上 brew 会停住。

`mirror` 的写入条件是「这个项目在 Gitee 上有镜像仓库」，不是「这个附件已经同步到
Gitee 了」。后者看着更准，实际是个必然探空的判据：各项目的 `sync-gitee` 在推 tag
那一刻就跑了，那时附件还在构建，release 附件要等下一轮同步才过去，而这边是发版后
几十秒就被叫过来重渲染 formula 的。按附件探的话每个新版本第一次渲染一条 mirror 都
写不出来，得等两小时后的定时重建补——偏偏发版后那两小时正是人去 `brew upgrade` 的
时候。写在同步前面不会有坏处：brew 只在 `url` 下不动时才去读 mirror，指到一个还没
同步完的附件和压根没写这一行是同一个结局，而附件一到位，formula 不用重渲染就自己
成立了。

这三行不是写在这儿就算数的：每次构建都有一个 `verify-brew-gitee`，把 github 的几
个域名指到 127.0.0.1、清掉下载缓存，再照上面这三行装一遍。装不上就是红的。它跑在
`sync` 之后，而且装之前先 `diff` 一遍 tap 下来的 `Formula/` 和这一轮推上去的那份
——Gitee 落后一版的话这儿就红了，不会装着上一版的包报绿。

cask 也没有这条路的后半截。Cask 的 `url` 不认 `mirror`——那是 Formula 的 DSL，cask
的 `url` 只收 `verified:`/`using:` 这类参数。`brew tap` 从 Gitee 来是可以的（cask
文件本身在 git 里，整仓搬得过去），但 DMG 只能从 GitHub 下。`verify-brew-gitee` 因此
不覆盖 cask：它按 `--brew` 遍历，cask 天然不在里面，不是漏了验。

apt 那半边没有这条路：deb 树是 Actions 部署到 GitHub Pages 的，不在 git 里，镜像
仓库带不走它。国内走 apt 装不上的话，用装机脚本（它自带 Gitee 回落）。

## 加一个新项目

在 `packages.toml` 里加几行，提交，完事。funget 就是这么加进来的：

```toml
[[source]]
repo = "farfarfun/funget"
keep = 3

# 可选。有这一节才生成 Homebrew formula。
[source.brew]
desc = "HTTP file transfer tool with ranged concurrency and resume"
```

发 DMG 的桌面应用把 `[source.brew]` 换成 `[source.cask]`，funclash 是这么加的：

```toml
[[source]]
repo = "farfarfun/funclash"
keep = 2
cli = false       # 没有能在无头 runner 上跑的命令行入口

[source.cask]
app = "FunClash"  # 显示名：既是 DMG 附件名的前缀，也是 .app 的名字
desc = "Multi-platform proxy client based on mihomo (Clash.Meta)"
min_macos = "monterey"
bundle_id = "com.farfarfun.funclash"   # --zap 按它拼要清的目录
```

uTools 插件用 `[source.utools]`。仓库在 `farfarfun-utools` 那个组织下也没关系，`repo`
写全名就行：

```toml
[[source]]
repo = "farfarfun-utools/utools-funotp"
keep = 3

[source.utools]
app = "两步验证 FunOTP"   # 插件在 uTools 里的名字，就是 plugin.json 的 pluginName
desc = "Manage two-factor accounts locally and generate TOTP / HOTP codes offline"
```

这一节和上面两个不是一类东西：它不进 APT 索引、不出 formula、CI 也装不了它（uTools
是个带界面的宿主程序，无头 runner 上没有「装一个插件」这回事）。它在这张表里只为了
一件事 —— 让插件也有一页中英双语的说明页，跟着 Release 自动更新。产物是一个
`<包名>-<版本>.upx`，三个桌面系统共用同一个文件。

`cli = false` 是给 apt 那条线看的：verify 默认拿第二列跑 `--version`，而这个包装出
来的是个窗口程序，在无头 runner 上跑它只会卡住。标了之后 verify 改成验 `.desktop`
的 `Exec` 指到的东西在 PATH 上、版本问 `dpkg-query`。

**真的只改这一个文件**：三个装机验证（apt、formula、cask）和站点（包列表、每个包
自己那一页）都是按这张表遍历的，不用回去改 workflow，也不用改页面。当前收了三个
能装的包（`fundeploy`、`funget`、`funclash`）和四个 uTools 插件（`utools-funotp`、
`utools-funlink`、`utools-funchat`、`utools-fundoc`）。

前提是那个项目的 release 附件按约定命名，并且带一份 `SHA256SUMS`：

| 渠道 | 附件名 |
| --- | --- |
| apt | `<包名>_<版本>_<架构>.deb`，`amd64`、`arm64` 各一个 |
| formula | `<包名>-<target>.tar.gz` |
| cask | `<应用名>-<版本>-macos-<架构>.dmg` |
| utools | `<包名>-<版本>.upx`，不分平台和架构 |

cask 那一行的前缀是**显示名**而不是包名：包名必须小写（Debian 的要求），而应用在
所有可见的地方叫 `FunClash`。

完整的约定（含页面文案格式、更新日志格式、CI 会验什么、自检命令）在
[docs/package-spec.md](docs/package-spec.md)，接入时照着那份走。加完之后跑一遍
`python3 scripts/sitedata.py packages.toml --check <包名>`，能看到站点认出了什么、
漏了什么。

项目那边再加一步，发完 release 通知这里重建：

```yaml
  notify-packages:
    needs: release
    runs-on: ubuntu-latest
    steps:
      - env:
          GH_TOKEN: ${{ secrets.PACKAGES_DISPATCH_TOKEN }}
        run: |
          [ -n "$GH_TOKEN" ] || { echo "没配 token，跳过"; exit 0; }
          gh api repos/farfarfun/packages/dispatches \
            -f event_type=package-published
```

**不加这一步是完全可以的，而且往往更可取。**这边每两小时（`17 */2 * * *`）会
自己扫一遍各项目的 Release，所以不通知的代价只是「发版后最多等两小时才能
`apt install` 到新版」。而加这一步的代价是项目仓库里要长期存一个 PAT 并盯着它
过期 —— 跨仓库写绕不开这个，workflow 自带的 `GITHUB_TOKEN` 只对本仓库有效，
同一个组织也不例外。funget 就是刻意不存，它的 secret 是零。

等不了两小时的话，手动打一下就行，用的是人的身份：

```bash
gh workflow run build.yml -R farfarfun/packages
```

## 它是怎么跑的

```
packages.toml ──┬─► collect-debs.sh    按清单从各项目 Release 下 .deb
                │   build-deb-repo.sh  拼 pool、每个架构各扫一份 Packages、
                │                      apt-ftparchive 出 Release、GPG 签名
                │   render-site.py     读清单 + 刚扫出来的索引 + 各项目 Release，
                │                      渲染总览页和每个包一页（中英各一份）
                │   deploy-pages       发到 GitHub Pages
                │   verify             真加源装一遍，再退一版装一遍
                │
                └─► render-formula.py  按最新版的 SHA256SUMS 拼 Formula/*.rb，项目在
                                       Gitee 上有镜像仓库就给每条 url 配一条 mirror
                    render-cask.py     同一张清单拼 Casks/*.rb（cask 没有 mirror 可
                                       配），两份一起提交回本仓库 master
                    sync               打一下 sync-gitee 并等它跑完
                    verify-brew        真 tap 一遍再 brew install
                    verify-cask        macOS runner 上装 cask，读 .app 的 Info.plist
                                       跟声明的版本对账
                    verify-brew-gitee  把 github 指到 127.0.0.1、清掉下载缓存，
                                       从 Gitee tap 再装一遍（三个 verify 都先 diff
                                       一遍 tap 到的文件是不是这一轮那份）
```

三条线都只收正式版，草稿和预发布不要。apt 那边留最近几版，tap 里一个包只有一份
formula 或 cask，只能是最新的——想装旧版走 apt，或者去项目的 Release 下 DMG。

触发时机：各项目 `repository_dispatch`、改了 `packages.toml`、手动、每两小时一次。

### 几个刻意的决定

**`.deb` 不提交进 git。** GitHub Pages 站点上限 1 GB，源仓库也建议不超过 1 GB，
而二进制只增不减——真到了那天想清理得改写历史。各项目的 Release 本来就是事实
来源，这边只记「收谁的、留几版」，pool 每次按清单重新拼。代价是每次重建重下一遍，
几 MB，只在发版时跑。

**`Filename:` 不能指向 Release 的 URL。** 否则连 pool 都不用拼了。但 `Packages`
里的 `Filename:` 必须是相对仓库根的路径，apt 不接受绝对 URL；要绕过去得有个能回
302 的真服务器，Pages 做不到。所以 pool 必须物理存在于站点里。

**每个架构扫出自己的 `Packages`。** 包是静态链接的、每个架构一个，索引共用的话
arm64 的机器会在列表里看到 amd64 的包，apt 直接判定「没有可安装的候选」。

**`InRelease` 和 `Release.gpg` 都出。** 新版 apt 只取前者，老一点的发行版还在找
后者，少一个就是一句「Release 文件没有签名」的硬报错。

**保留最近几版而不是只留最新。** 留多于一个才能 `apt install fundeploy=0.3.0`
回退；只留最新的话，装坏了就没有退路。留几版按项目各写（`keep`）：命令行工具几 MB，
留 3 版；funclash 一个 `.deb` 45 MB、两个架构，留 2 版就占去 180 MB，而上面那条
1 GB 是整站的上限。

**站点在构建时整个生成，不写死任何包名。** 页面上的版本、附件、校验和、更新日志
全部来自 `packages.toml`、刚扫出来的 APT 索引和各项目的 Release —— 加一个包只改
清单，它自己就会多出一页。渲染这一步不挂 `if: signed`：它不用 GPG，让没配 secret
的 PR 也跑一遍，模板写坏当场就是红的。

**取不到的数据就整块不出。** `gh` 不可用、索引还没建、项目没写 `CHANGELOG.md`，
对应的那一节直接不渲染，而不是渲染一个空壳。所以页面上「少了一块」永远是数据的
问题，查 `scripts/sitedata.py ... --check <包名>` 就能看到少在哪儿。

## 站点

```
site/
  home.html  package.html   两种页面的模板
  partials/                 页头页脚、各节的骨架
  strings.toml              所有文案，[zh] 和 [en] 两张表，键必须一一对应
  pages/<包名>.toml         每个包的显示名、标语、功能点、截图、额外渠道（可选）
  assets/                   style.css 和 app.js（JS 里没有一个字的文案）
```

渲染器是 `scripts/render-site.py`，数据层是 `scripts/sitedata.py`，都只用标准库。
页面是静态生成的，JS 只做增强：关掉 JS 之后分段控件消失、所有面板展开，内容一句
不少。

## 一次性配置

| Secret | 用途 |
| --- | --- |
| `APT_GPG_PRIVATE_KEY` | ASCII-armored 签名私钥 |
| `APT_GPG_PASSPHRASE` | 私钥密码；无密码密钥可不设 |

```bash
gpg --armor --export-secret-keys <KEY_ID> \
  | gh secret set APT_GPG_PRIVATE_KEY --repo farfarfun/packages
```

Settings → Pages 里把发布源选成 **GitHub Actions**。

没配 `APT_GPG_PRIVATE_KEY` 时 apt 那条线会跳过并告警，不会发出一个没签名的仓库。
tap 那条线不需要任何 secret——formula 和 cask 都提交回本仓库，默认的 `GITHUB_TOKEN`
就够。

## 本地跑

```bash
bash scripts/collect-debs.sh packages.toml debs
bash scripts/build-deb-repo.sh debs public/deb <GPG密钥ID>
python3 scripts/render-formula.py packages.toml Formula
python3 scripts/render-cask.py packages.toml Casks
python3 scripts/render-site.py site public --packages packages.toml --deb public/deb
```

只看站点的话前两步可以跳过（没有索引时版本一节退化成按 Release 列）：

```bash
python3 scripts/render-site.py site /tmp/preview --packages packages.toml
python3 -m http.server -d /tmp/preview 8000
```

需要 `gh`、`python3`、`dpkg-dev`、`apt-utils`、GnuPG。渲染站点只要 `python3`，
`gh` 没登录也能跑（取不到的那几块不出）。

---

## 关于 farfarfun

[farfarfun](https://github.com/farfarfun) 是一个专注于实用工具库的开源组织，
涵盖云存储、数据处理、AI、多媒体与开发工具链等方向。

- 🏠 组织主页：<https://github.com/farfarfun>
- 📧 联系：farfarfun@qq.com

本项目基于 [MIT](LICENSE) 协议开源。
