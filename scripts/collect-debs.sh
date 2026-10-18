#!/usr/bin/env bash
# 按 packages.toml 把各项目 release 里的 .deb 拉到一个目录里。
#
#   collect-debs.sh <packages.toml> <输出目录>
#
# 需要 gh 已登录（CI 里 GITHUB_TOKEN 就够，只读公开 release）。
set -euo pipefail

MANIFEST="${1:-}"
OUT="${2:-}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() {
  echo "错误: $*" >&2
  exit 1
}

[[ -f "$MANIFEST" ]] || die "找不到清单: ${MANIFEST:-<空>}"
[[ -n "$OUT" ]] || die "请指定输出目录"
for c in gh python3; do
  command -v "$c" >/dev/null 2>&1 || die "缺少命令: $c"
done

mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"

rows="$(python3 "${HERE}/select-releases.py" "$MANIFEST")"
while IFS=$'\t' read -r repo tag; do
  [[ -n "$repo" ]] || continue
  if ! assets="$(gh release view "$tag" --repo "$repo" --json assets \
    --jq '.assets[].name | select(endswith(".deb"))')"; then
    die "${repo} ${tag}: 附件列表取不到"
  fi
  if [[ -z "$assets" ]]; then
    echo "  ${repo} ${tag}: 没有 .deb，跳过"
    continue
  fi
  gh release download "$tag" --repo "$repo" --pattern '*.deb' \
    --dir "$OUT" --clobber || die "${repo} ${tag}: .deb 下载失败"
  echo "  ${repo} ${tag}: 收到"
done <<< "$rows"

shopt -s nullglob
got=("$OUT"/*.deb)
shopt -u nullglob
[[ "${#got[@]}" -gt 0 ]] || die "一个 .deb 都没收到，不生成空仓库"
echo "共 ${#got[@]} 个 .deb → ${OUT}"
