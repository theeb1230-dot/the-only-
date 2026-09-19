#!/usr/bin/env bash
set -euo pipefail

# LIVE verification is intentionally separate from deterministic CI. It checks
# only public, authorization-safe sample media that the runtime demo providers
# expose. Never add scraped, credentialed, DRM, paywalled, or ambiguous URLs.
urls=(
  "https://mdn.github.io/shared-assets/videos/flower.mp4"
)

failures=0
passes=0

for url in "${urls[@]}"; do
  host="$(python3 -c 'import sys,urllib.parse; print(urllib.parse.urlsplit(sys.argv[1]).hostname or "")' "$url")"
  if [[ "$host" != "mdn.github.io" ]]; then
    echo "LIVE_FAIL reason=unapproved_host host=${host:-missing}" >&2
    failures=$((failures + 1))
    continue
  fi

  echo "LIVE_VERIFY host=$host"
  headers="$(mktemp)"
  body="$(mktemp)"
  trap 'rm -f "$headers" "$body"' EXIT

  if ! result="$(curl --silent --show-error --location --max-redirs 3 \
    --connect-timeout 10 --max-time 30 \
    --proto '=https' --proto-redir '=https' \
    --range 0-1023 \
    --dump-header "$headers" \
    --output "$body" \
    --write-out '%{http_code} %{url_effective}' \
    "$url")"; then
    echo "LIVE_FAIL reason=request_failed host=$host" >&2
    failures=$((failures + 1))
    rm -f "$headers" "$body"
    trap - EXIT
    continue
  fi

  code="${result%% *}"
  final_url="${result#* }"
  final_host="$(python3 -c 'import sys,urllib.parse; print(urllib.parse.urlsplit(sys.argv[1]).hostname or "")' "$final_url")"
  bytes="$(wc -c < "$body" | tr -d ' ')"
  content_type="$(awk 'BEGIN{IGNORECASE=1} /^content-type:/ {gsub("\r", ""); sub(/^[^:]+:[[:space:]]*/, ""); value=$0} END{print value}' "$headers")"

  reason=""
  case "$code" in
    200|206) ;;
    *) reason="http_status_$code" ;;
  esac
  if [[ -z "$reason" && "$bytes" -le 0 ]]; then reason="empty_body"; fi
  if [[ -z "$reason" && ( -z "$content_type" || "$content_type" != video/* ) ]]; then reason="unexpected_content_type"; fi
  if [[ -z "$reason" && "$final_host" != "mdn.github.io" ]]; then reason="redirect_escaped_allowlist"; fi

  if [[ -n "$reason" ]]; then
    echo "LIVE_FAIL reason=$reason status=$code bytes=$bytes content_type=${content_type:-missing} final_host=${final_host:-missing}" >&2
    failures=$((failures + 1))
  else
    echo "LIVE_PASS status=$code bytes=$bytes content_type=$content_type final_host=$final_host"
    passes=$((passes + 1))
  fi

  rm -f "$headers" "$body"
  trap - EXIT
done

echo "LIVE_SUMMARY passes=$passes failures=$failures"
if [[ "$failures" -ne 0 || "$passes" -eq 0 ]]; then
  exit 1
fi
