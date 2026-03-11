#!/bin/ash
set -e

# 获取脚本所在的目录
DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="/tmp"

URL_GEOIP="https://raw.githubusercontent.com/Loyalsoldier/geoip/release/geoip-only-cn-private.dat"
URL_GEOSITE="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

TMP_GEOIP="${TMP_DIR}/geoip.dat"
TMP_GEOSITE="${TMP_DIR}/geosite.dat"

download_and_verify() {
  local url="$1"
  local outfile="$2"

  echo "[*] 获取文件: $url"
  
  # 使用 curl -sIL 跟随重定向并获取文件大小
  local header_len
  header_len=$(curl -sIL "$url" | awk 'tolower($0) ~ /content-length/ {print $2}' | tr -d '\r')

  if [ -z "$header_len" ] || [ "$header_len" -eq 0 ]; then
    echo "[!] 无法获取有效的 Content-Length，尝试直接下载并计算实际大小。"
  fi

  echo "[*] 下载到临时文件: $outfile (期望大小: $header_len)"
  curl -sL -o "$outfile" "$url"

  # 获取实际下载文件的大小
  local file_len
  file_len=$(wc -c <"$outfile" | tr -d ' ')

  if [ "$file_len" -ne "$header_len" ]; then
    echo "[!] 文件大小不一致，期望 $header_len 实际 $file_len，终止。"
    exit 1
  fi

  echo "[✓] 校验通过 ($file_len bytes)"
}

main() {
  download_and_verify "$URL_GEOIP" "$TMP_GEOIP"
  download_and_verify "$URL_GEOSITE" "$TMP_GEOSITE"

  echo "[*] 替换 ${DIR}/geoip.dat 和 geosite.dat 文件"
  rm -f "${DIR}/geoip.dat" "${DIR}/geosite.dat"
  mv -f "$TMP_GEOIP" "${DIR}/geoip.dat"
  mv -f "$TMP_GEOSITE" "${DIR}/geosite.dat"

  echo "[*] 重启 mosdns 服务"
  service mosdns restart

  echo "[✓] 完成"
}

main "$@"

