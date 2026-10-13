#!/usr/bin/env bash
# 把一批 .deb 组装成一个签名好的 APT 仓库（给 GitHub Pages 托管用）。
#
#   build-deb-repo.sh <deb目录> <输出目录> <GPG密钥ID>
#
# 输出目录就是 APT 源地址指向的那一层：
#   <输出>/dists/stable/...   索引与签名
#   <输出>/pool/main/<首字母>/<包名>/*.deb
set -euo pipefail

DEB_DIR="${1:-}"
OUTPUT_DIR="${2:-}"
GPG_KEY_ID="${3:-}"

ORIGIN="farfarfun"
ARCHES=(amd64 arm64)

die() {
  echo "错误: $*" >&2
  exit 1
}

[[ -d "$DEB_DIR" ]] || die "找不到 deb 目录: ${DEB_DIR:-<空>}"
[[ -n "$OUTPUT_DIR" ]] || die "请指定输出目录"
[[ -n "$GPG_KEY_ID" ]] || die "请指定 GPG 签名密钥 ID"
for c in apt-ftparchive dpkg-scanpackages dpkg-deb gpg gzip; do
  command -v "$c" >/dev/null 2>&1 || die "缺少命令: $c"
done

shopt -s nullglob
DEBS=("$DEB_DIR"/*.deb)
shopt -u nullglob
[[ "${#DEBS[@]}" -gt 0 ]] || die "${DEB_DIR} 里一个 .deb 都没有"

if [[ -d "$OUTPUT_DIR" ]] && find "$OUTPUT_DIR" -mindepth 1 -print -quit | grep -q .; then
  die "输出目录必须为空: $OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
DIST="${OUTPUT_DIR}/dists/stable"

# 按包名分目录，而不是所有 deb 堆在一个 pool 下。Debian 的惯例是
# pool/<组件>/<首字母>/<包名>/——多个项目共用一个仓库之后，堆在一起很快就看不出
# 哪个文件属于谁，而出问题时第一件事就是去 pool 里核对。
# 首字母从包名的 control 字段取，不从文件名猜：文件名是构建脚本拼的，改个拼法
# 就和索引对不上了，而 control 是 apt 自己认的那一份。
declare -A WANT=()
for deb in "${DEBS[@]}"; do
  name="$(dpkg-deb -f "$deb" Package)"
  [[ -n "$name" ]] || die "读不出包名: $deb"
  case "$name" in
    lib?*) letter="${name:0:4}" ;;  # libfoo 归到 libf，和 Debian 一致
    *) letter="${name:0:1}" ;;
  esac
  dest="${OUTPUT_DIR}/pool/main/${letter}/${name}"
  mkdir -p "$dest"
  cp -f "$deb" "$dest/"
  arch="$(dpkg-deb -f "$deb" Architecture)"
  WANT["$arch"]=$(( ${WANT["$arch"]:-0} + 1 ))
done

# 每个架构扫出自己的 Packages。二进制是静态链接的、每个架构一个包，索引共用的话
# arm64 的机器会在列表里看到 amd64 的包，apt 直接判定「没有可安装的候选」。
#
# --multiversion 不能少：不加的话 dpkg-scanpackages 每个包只写最新的那一版，
# pool 里躺着 keep 规定的几版而索引里只有一版——`apt install fundeploy=0.3.0`
# 报「找不到该版本」，而回退正是留多版的全部理由。
for arch in "${ARCHES[@]}"; do
  mkdir -p "${DIST}/main/binary-${arch}"
  (
    cd "$OUTPUT_DIR"
    dpkg-scanpackages --multiversion --arch "$arch" pool
  ) >"${DIST}/main/binary-${arch}/Packages"
  [[ -s "${DIST}/main/binary-${arch}/Packages" ]] || die "${arch} 没有对应的包"

  # pool 里放进去几个，索引里就得有几条。漏掉的那种是最难发现的故障：装还是装
  # 得上（最新版在），只是回退悄悄没了。
  got="$(grep -c '^Package:' "${DIST}/main/binary-${arch}/Packages")"
  want="${WANT[$arch]:-0}"
  [[ "$got" -eq "$want" ]] || die "${arch}: pool 里 ${want} 个包，索引里只有 ${got} 条"

  gzip -9 -c "${DIST}/main/binary-${arch}/Packages" >"${DIST}/main/binary-${arch}/Packages.gz"
done

apt-ftparchive \
  -o "APT::FTPArchive::Release::Origin=${ORIGIN}" \
  -o "APT::FTPArchive::Release::Label=${ORIGIN}" \
  -o APT::FTPArchive::Release::Suite=stable \
  -o APT::FTPArchive::Release::Codename=stable \
  -o "APT::FTPArchive::Release::Architectures=${ARCHES[*]}" \
  -o APT::FTPArchive::Release::Components=main \
  -o "APT::FTPArchive::Release::Description=${ORIGIN} packages" \
  release "$DIST" >"${DIST}/Release"

GPG_ARGS=(--batch --yes --local-user "$GPG_KEY_ID")
if [[ -n "${APT_GPG_PASSPHRASE:-}" ]]; then
  GPG_ARGS+=(--pinentry-mode loopback --passphrase "$APT_GPG_PASSPHRASE")
fi
# InRelease（内嵌签名）和 Release.gpg（分离签名）都出：新版 apt 只取前者，
# 老一点的发行版还在找后者，少一个就是一句 "Release 文件没有签名" 的硬报错。
gpg "${GPG_ARGS[@]}" --armor --detach-sign --output "${DIST}/Release.gpg" "${DIST}/Release"
gpg "${GPG_ARGS[@]}" --clearsign --output "${DIST}/InRelease" "${DIST}/Release"

echo "$OUTPUT_DIR"
