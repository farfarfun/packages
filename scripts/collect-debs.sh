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

while IFS=$'\t' read -r repo tag; do
  [[ -n "$repo" ]] || continue
  # 老版本可能一个 .deb 都没有（比如某个项目改语言之前）。下不到东西是正常的，
  # 不该让整次构建失败。
  if gh release download "$tag" --repo "$repo" --pattern '*.deb' \
    --dir "$OUT" --clobber 2>/dev/null; then
    echo "  ${repo} ${tag}: 收到"
  else
    echo "  ${repo} ${tag}: 没有 .deb，跳过"
  fi
done < <(python3 "${HERE}/select-releases.py" "$MANIFEST")

shopt -s nullglob
got=("$OUT"/*.deb)
shopt -u nullglob
[[ "${#got[@]}" -gt 0 ]] || die "一个 .deb 都没收到，不生成空仓库"
echo "共 ${#got[@]} 个 .deb → ${OUT}"
