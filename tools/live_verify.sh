#!/usr/bin/env bash
set -euo pipefail

# LIVE verification is intentionally separate from deterministic CI. It checks
# only public, authorization-safe sample media and the open-license provider
# discovery path used by production. Never add scraped, credentialed, DRM,
# paywalled, or ambiguous URLs.

failures=0
passes=0

host_allowed() {
  local host="$1"
  local allowed_host="$2"
  local allow_subdomains="${3:-false}"
  [[ "$host" == "$allowed_host" ]] && return 0
  [[ "$allow_subdomains" == "true" && "$host" == *".$allowed_host" ]] && return 0
  return 1
}

verify_media_url() {
  local url="$1"
  local allowed_host="$2"
  local label="$3"
  local allow_subdomains="${4:-false}"
  local host headers body result code final_url final_host bytes content_type reason

  host="$(python3 -c 'import sys,urllib.parse; print(urllib.parse.urlsplit(sys.argv[1]).hostname or "")' "$url")"
  if ! host_allowed "$host" "$allowed_host" "$allow_subdomains"; then
    echo "LIVE_FAIL label=$label reason=unapproved_host host=${host:-missing}" >&2
    failures=$((failures + 1))
    return
  fi

  echo "LIVE_VERIFY label=$label host=$host"
  headers="$(mktemp)"
  body="$(mktemp)"

  if ! result="$(curl --silent --show-error --location --max-redirs 3 \
    --connect-timeout 10 --max-time 30 \
    --proto '=https' --proto-redir '=https' \
    --range 0-1023 \
    --dump-header "$headers" \
    --output "$body" \
    --write-out '%{http_code} %{url_effective}' \
    "$url")"; then
    echo "LIVE_FAIL label=$label reason=request_failed host=$host" >&2
    failures=$((failures + 1))
    rm -f "$headers" "$body"
    return
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
  if [[ -z "$reason" ]] && ! host_allowed "$final_host" "$allowed_host" "$allow_subdomains"; then reason="redirect_escaped_allowlist"; fi

  if [[ -n "$reason" ]]; then
    echo "LIVE_FAIL label=$label reason=$reason status=$code bytes=$bytes content_type=${content_type:-missing} final_host=${final_host:-missing}" >&2
    failures=$((failures + 1))
  else
    echo "LIVE_PASS label=$label status=$code bytes=$bytes content_type=$content_type final_host=$final_host"
    passes=$((passes + 1))
  fi
  rm -f "$headers" "$body"
}

# Stable authorized public sample used by the built-in demo provider.
verify_media_url "https://mdn.github.io/shared-assets/videos/flower.mp4" "mdn.github.io" "demo-mp4"

# Exercise the production Internet Archive provider contract end-to-end:
# search only records with an explicit CC license, fetch metadata, re-check the
# license, select a direct MP4, then verify bytes without downloading the file.
search_json="$(curl --silent --show-error --fail --location --max-redirs 2 \
  --connect-timeout 10 --max-time 30 \
  --proto '=https' --proto-redir '=https' \
  --get 'https://archive.org/advancedsearch.php' \
  --data-urlencode 'q=(animation) AND mediatype:movies AND licenseurl:*' \
  --data-urlencode 'fl[]=identifier,title,licenseurl' \
  --data-urlencode 'rows=20' --data-urlencode 'page=1' --data-urlencode 'output=json')" || search_json=''

candidate="$(python3 -c '
import json,sys
try: data=json.load(sys.stdin)
except Exception: raise SystemExit(0)
for doc in data.get("response",{}).get("docs",[]):
    lic=doc.get("licenseurl","")
    if isinstance(lic,list): lic=lic[0] if lic else ""
    if isinstance(lic,str) and lic.lower().startswith(("https://creativecommons.org/","http://creativecommons.org/")):
        ident=doc.get("identifier","")
        if isinstance(ident,str) and ident: print(ident); break
' <<<"$search_json")"

if [[ -z "$candidate" ]]; then
  echo "LIVE_FAIL label=archive-provider reason=no_open_license_search_result" >&2
  failures=$((failures + 1))
else
  metadata="$(curl --silent --show-error --fail --location --max-redirs 2 \
    --connect-timeout 10 --max-time 30 --proto '=https' --proto-redir '=https' \
    "https://archive.org/metadata/${candidate}")" || metadata=''
  archive_url="$(python3 -c '
import json,sys,urllib.parse
try: data=json.load(sys.stdin)
except Exception: raise SystemExit(0)
lic=data.get("metadata",{}).get("licenseurl","")
if isinstance(lic,list): lic=lic[0] if lic else ""
if not isinstance(lic,str) or not lic.lower().startswith(("https://creativecommons.org/","http://creativecommons.org/")): raise SystemExit(0)
ident=data.get("metadata",{}).get("identifier","") or sys.argv[1]
for f in data.get("files",[]):
    name=f.get("name","")
    fmt=str(f.get("format","")).lower()
    if isinstance(name,str) and name.lower().endswith(".mp4") and (not fmt or "mpeg4" in fmt or "h.264" in fmt):
        print("https://archive.org/download/%s/%s" % (urllib.parse.quote(str(ident),safe=""), urllib.parse.quote(name,safe="/")))
        break
' "$candidate" <<<"$metadata")"
  if [[ -z "$archive_url" ]]; then
    echo "LIVE_FAIL label=archive-provider reason=no_licensed_mp4_source" >&2
    failures=$((failures + 1))
  else
    # archive.org legitimately redirects media bytes to hosts such as
    # ia600702.us.archive.org. Accept only archive.org itself or a true DNS
    # subdomain ending in .archive.org; lookalikes such as evilarchive.org fail.
    verify_media_url "$archive_url" "archive.org" "archive-provider" true
  fi
fi

echo "LIVE_SUMMARY passes=$passes failures=$failures"
if [[ "$failures" -ne 0 || "$passes" -lt 2 ]]; then
  exit 1
fi
