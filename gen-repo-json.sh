#!/usr/bin/env bash
set -euo pipefail

REPO="luarvique/openwebrx"
ICON_URL="https://www.receiverbook.de/static/img/openwebrx-avatar.png"
OUTFILE="repo.json"

echo "Fetching latest release metadata..."
LATEST_JSON=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")

TAG=$(echo "$LATEST_JSON" | jq -r .tag_name)
ASSETS_JSON=$(echo "$LATEST_JSON" | jq -c '.assets[]')

URL_64=$(echo "$ASSETS_JSON" | jq -r 'select(.name | test("image_.*OpenWebRX(%2B|\\+)-64bit.*\\.zip")) | .browser_download_url')
URL_32=$(echo "$ASSETS_JSON" | jq -r 'select(.name | test("image_.*OpenWebRX(%2B|\\+)-32bit.*\\.zip")) | .browser_download_url')

if [[ -z "$URL_64" ]]; then
    echo "ERROR: No 64-bit image found. This is required."
    exit 1
fi

SHA_64=$(echo "$ASSETS_JSON" | jq -r 'select(.name | test("image_.*OpenWebRX(%2B|\\+)-64bit.*\\.zip")) | .digest' | sed 's/^sha256://')
SHA_32=$(echo "$ASSETS_JSON" | jq -r 'select(.name | test("image_.*OpenWebRX(%2B|\\+)-32bit.*\\.zip")) | .digest' | sed 's/^sha256://')

FILENAME_64=$(basename "$URL_64")
DATE=$(echo "$FILENAME_64" | sed -n 's/^image_\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')

echo "Latest tag: $TAG"
echo "Release date (from filename): $DATE"
echo "Generating $OUTFILE..."

jq -n \
  --arg date "$DATE" \
  --arg icon "$ICON_URL" \
  --arg url64 "$URL_64" \
  --arg sha64 "$SHA_64" \
  --arg url32 "$URL_32" \
  --arg sha32 "$SHA_32" \
  --arg tag "$TAG" \
'
{
  os_list: [
    {
      name: ("OpenWebRX+ " + $tag + " (64-bit)"),
      description: "OpenWebRX+ preconfigured Raspberry Pi image (64-bit). Supported: Raspberry Pi 3 / 4 / 5.",
      icon: $icon,
      release_date: $date,
      url: $url64,
      sha256: $sha64,
      supports_customization: true
    },

    (if $url32 != "" and $sha32 != "" then
      {
        name: ("OpenWebRX+ " + $tag + " (32-bit)"),
        description: "OpenWebRX+ preconfigured Raspberry Pi image (32-bit). Supported: Raspberry Pi 3 / 4 / 5.",
        icon: $icon,
        release_date: $date,
        url: $url32,
        sha256: $sha32,
        supports_customization: true
      }
    else empty end)
  ]
}
' > "$OUTFILE"

echo "Done. Generated $OUTFILE"

