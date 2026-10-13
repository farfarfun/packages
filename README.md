# farfarfun/packages

farfarfun 所有项目共用的包仓库。**用户只加一次源**，以后新增的包直接
`apt install` 就有。Homebrew formula 也在这儿生成，推到
[farfarfun/homebrew-tap](https://github.com/farfarfun/homebrew-tap)。

站点: <https://farfarfun.github.io/packages>

```bash
curl -fsSL https://farfarfun.github.io/packages/farfarfun.gpg \
  | sudo tee /usr/share/keyrings/farfarfun.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/farfarfun.gpg] https://farfarfun.github.io/packages/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/farfarfun.list
sudo apt update && sudo apt install fundeploy
```

## 加一个新项目

在 `packages.toml` 里加几行，提交，完事：

```toml
[[source]]
repo = "farfarfun/funget"
keep = 3

# 可选。有这一节才生成 Homebrew formula。
[source.brew]
desc = "Download things, fast"
```

前提是那个项目的 release 附件按约定命名：`.deb` 每个架构一个（`amd64`、`arm64`），
brew 要的是 `funget-<target>.tar.gz` 加一份 `SHA256SUMS`。项目那边再加一步，发完
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

不加这一步也行，这边每天 04:17 会兜底扫一遍，只是当天看不到新版本。

## 它是怎么跑的

```
packages.toml ──┬─► collect-debs.sh    按清单从各项目 Release 下 .deb
                │   build-deb-repo.sh  拼 pool、每个架构各扫一份 Packages、
                │                      apt-ftparchive 出 Release、GPG 签名
                │   deploy-pages       发到 GitHub Pages
                │   verify             真加源装一遍 fundeploy
                │
                └─► render-formula.py  按最新版的 SHA256SUMS 拼 formula，
                                       推到 farfarfun/homebrew-tap
```

两条线都只收正式版，草稿和预发布不要。apt 那边留最近几版，tap 里一个包只有一份
formula，只能是最新的——想装旧版走 apt。

触发时机：各项目 `repository_dispatch`、改了 `packages.toml`、手动、每天兜底一次。

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
| `HOMEBREW_TAP_DEPLOY_KEY` | `farfarfun/homebrew-tap` 的可写 Deploy Key 私钥 |

```bash
gpg --armor --export-secret-keys <KEY_ID> \
  | gh secret set APT_GPG_PRIVATE_KEY --repo farfarfun/packages

ssh-keygen -t ed25519 -N '' -C 'farfarfun packages' -f tap_key
gh api --method POST repos/farfarfun/homebrew-tap/keys \
  -f title='farfarfun/packages' -F read_only=false \
  -f key="$(cat tap_key.pub)"
gh secret set HOMEBREW_TAP_DEPLOY_KEY --repo farfarfun/packages <tap_key
rm tap_key tap_key.pub
```

Settings → Pages 里把发布源选成 **GitHub Actions**。

两个 secret 各自独立：缺哪个就跳过哪条线并告警，不会发出一个没签名的 apt 仓库，
也不会因为 tap 推不上去让 apt 这边跟着红。

## 本地跑

```bash
bash scripts/collect-debs.sh packages.toml debs
bash scripts/build-deb-repo.sh debs public/deb <GPG密钥ID>
python3 scripts/render-formula.py packages.toml /tmp/formula
```

需要 `gh`、`python3`、`dpkg-dev`、`apt-utils`、GnuPG。
