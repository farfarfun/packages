# farfarfun/packages

farfarfun 所有项目共用的包仓库。**用户只加一次源**，以后新增的包直接装。
这个仓库同时是 APT 源和 Homebrew tap。

站点: <https://farfarfun.github.io/packages>

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

#### GitHub 连不上的时候

formula 里每个 `url` 都配了一条 Gitee `mirror`，下包这一步 brew 自己会回落，不用
配任何东西。但 `brew tap` 做的是 git clone，那一步没有回落可言——改成从 Gitee 的
镜像 tap：

```bash
brew tap farfarfun/packages https://gitee.com/farfarfun/packages
brew trust farfarfun/packages
brew install fundeploy
```

镜像由本仓库的 `sync-gitee` 推过去，push 即跟。两边 formula 一字不差，装出来的也
是同一批二进制——mirror 和 url 共用同一行 `sha256`，对不上 brew 会停住。

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

**真的只改这一个文件**：两个装机验证（apt 的和 brew 的）都是按这张表遍历的，
不用回去改 workflow。当前收了 `fundeploy` 和 `funget` 两个。

前提是那个项目的 release 附件按约定命名：`.deb` 每个架构一个（`amd64`、`arm64`），
brew 要的是 `<包名>-<target>.tar.gz` 加一份 `SHA256SUMS`。项目那边再加一步，发完
release 通知这里重建：

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
                │   deploy-pages       发到 GitHub Pages
                │   verify             真加源装一遍，再退一版装一遍
                │
                └─► render-formula.py  按最新版的 SHA256SUMS 拼 Formula/*.rb，
                                       提交回本仓库 master
                    verify-brew        真 tap 一遍再 brew install
```

两条线都只收正式版，草稿和预发布不要。apt 那边留最近几版，tap 里一个包只有一份
formula，只能是最新的——想装旧版走 apt。

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

**保留最近 3 版而不是只留最新。** 留多于一个才能 `apt install fundeploy=0.3.0`
回退；只留最新的话，装坏了就没有退路。

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
formula 那条线不需要任何 secret——它提交回本仓库，默认的 `GITHUB_TOKEN` 就够。

## 本地跑

```bash
bash scripts/collect-debs.sh packages.toml debs
bash scripts/build-deb-repo.sh debs public/deb <GPG密钥ID>
python3 scripts/render-formula.py packages.toml Formula
```

需要 `gh`、`python3`、`dpkg-dev`、`apt-utils`、GnuPG。
