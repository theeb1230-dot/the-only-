#!/usr/bin/env bash
set -euo pipefail

urls=(
  "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
  "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
)

for url in "${urls[@]}"; do
  echo "LIVE_VERIFY host=$(python3 -c 'import sys,urllib.parse; print(urllib.parse.urlsplit(sys.argv[1]).hostname)' "$url")"
  headers="$(mktemp)"
  body="$(mktemp)"
  code="$(curl --fail-with-body --location --max-redirs 3 --connect-timeout 10 --max-time 30 \
    --proto '=https' --proto-redir '=https' \
    --range 0-1023 \
    --dump-header "$headers" \
    --output "$body" \
    --write-out '%{http_code}' \
    "$url")"

  case "$code" in
    200|206) ;;
    *) echo "Unexpected HTTP status: $code" >&2; exit 1 ;;
  esac

  bytes="$(wc -c < "$body" | tr -d ' ')"
  if [[ "$bytes" -le 0 ]]; then
    echo "LIVE verification returned an empty body" >&2
    exit 1
  fi

  content_type="$(awk 'BEGIN{IGNORECASE=1} /^content-type:/ {gsub("\r", ""); sub(/^[^:]+:[[:space:]]*/, ""); print; exit}' "$headers")"
  if [[ -z "$content_type" || "$content_type" != video/* ]]; then
    echo "Unexpected content type: ${content_type:-missing}" >&2
    exit 1
  fi

  final_url="$(curl --silent --show-error --head --location --max-redirs 3 --connect-timeout 10 --max-time 30 \
    --proto '=https' --proto-redir '=https' --write-out '%{url_effective}' --output /dev/null "$url")"
  final_host="$(python3 -c 'import sys,urllib.parse; print(urllib.parse.urlsplit(sys.argv[1]).hostname)' "$final_url")"
  if [[ "$final_host" != "storage.googleapis.com" ]]; then
    echo "Redirect escaped approved host: $final_host" >&2
    exit 1
  fi

  echo "LIVE_PASS status=$code bytes=$bytes content_type=$content_type final_host=$final_host"
  rm -f "$headers" "$body"
done
