#!/bin/bash -e

# Install CardputerZero app debs from GitHub releases. Asset names include the
# app version, so match package prefix/suffix instead of hard-coding versions.
AUTH_ARGS=()
GITHUB_AUTH_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -n "$GITHUB_AUTH_TOKEN" ]; then
    AUTH_ARGS=(-H "Authorization: Bearer ${GITHUB_AUTH_TOKEN}")
fi

download_and_install_deb() {
    local app_name="$1"
    local api_url="$2"
    local deb_url_var="$3"
    local filename_pattern="$4"
    local apt_options="${5:-}"

    local deb_url="${!deb_url_var:-}"
    local deb_file
    if [ -z "$deb_url" ]; then
        local response_file
        local http_status
        local curl_exit
        local asset_info

        response_file=$(mktemp)
        echo "Querying ${app_name} releases API: ${api_url}"
        set +e
        http_status=$(curl -sSL "${AUTH_ARGS[@]}" \
            -o "$response_file" \
            -w '%{http_code}' \
            "$api_url")
        curl_exit=$?
        set -e
        echo "${app_name}: GitHub API HTTP status ${http_status} (curl exit ${curl_exit})"

        if [ "$curl_exit" -ne 0 ]; then
            rm -f "$response_file"
            echo "ERROR: Failed to query ${app_name} releases API"
            exit 1
        fi

        if ! [[ "$http_status" =~ ^2 ]]; then
            rm -f "$response_file"
            echo "ERROR: ${app_name} releases API returned HTTP ${http_status}"
            exit 1
        fi

        asset_info=$(python3 - "$response_file" "$filename_pattern" <<'PY'
import json
import re
import sys

response_path, filename_pattern = sys.argv[1], sys.argv[2]
with open(response_path, "r", encoding="utf-8") as f:
    data = json.load(f)

releases = data if isinstance(data, list) else [data]
pattern = re.compile(filename_pattern)
for release in releases:
    for asset in release.get("assets", []):
        name = asset.get("name", "")
        browser_url = asset.get("browser_download_url", "")
        api_url = asset.get("url", "")
        if pattern.search(name) or pattern.search(browser_url):
            print(f"{name}\t{api_url}")
            raise SystemExit(0)
PY
)
        rm -f "$response_file"

        if [ -n "$asset_info" ]; then
            deb_file="${asset_info%%$'\t'*}"
            deb_url="${asset_info#*$'\t'}"
        fi
    fi

    if [ -z "$deb_url" ]; then
        echo "ERROR: Could not find ${app_name} m5stack1 arm64 deb URL matching ${filename_pattern}"
        exit 1
    fi

    deb_file="${deb_file:-${deb_url##*/}}"
    echo "Downloading ${app_name} from: $deb_url"
    curl -fsSL "${AUTH_ARGS[@]}" \
        -H "Accept: application/octet-stream" \
        -o "${ROOTFS_DIR}/tmp/${deb_file}" \
        -L "$deb_url"

on_chroot << CHROOT
set -e
apt-get install -y --no-install-recommends ${apt_options} "/tmp/${deb_file}"
rm -f "/tmp/${deb_file}"
CHROOT
}

RECORDER_RELEASES_URL="${RECORDER_RELEASES_URL:-https://api.github.com/repos/CardputerZero/Recorder/releases}"
COMPASS_RELEASE_TAG="${COMPASS_RELEASE_TAG:-v0.1.0}"
CAMERA_APP_RELEASES_URL="${CAMERA_APP_RELEASES_URL:-https://api.github.com/repos/CardputerZero/CameraApp/releases}"
FACTORY_TEST_RELEASES_URL="${FACTORY_TEST_RELEASES_URL:-https://api.github.com/repos/CardputerZero/FactoryTest/releases}"

download_and_install_deb \
    "Recorder" \
    "$RECORDER_RELEASES_URL" \
    "RECORDER_DEB_URL" \
    'm5cardputerzero-recorder_[^"/]*_m5stack1_arm64\.deb'

download_and_install_deb \
    "Compass" \
    "https://api.github.com/repos/CardputerZero/Compass/releases/tags/${COMPASS_RELEASE_TAG}" \
    "COMPASS_DEB_URL" \
    'm5cardputerzero-compass_[^"/]*_m5stack1_arm64\.deb'

download_and_install_deb \
    "CameraApp" \
    "$CAMERA_APP_RELEASES_URL" \
    "CAMERA_APP_DEB_URL" \
    'CameraApp_[^"/]*_m5stack1_arm64\.deb' \
    '-o Dpkg::Options::=--force-overwrite'

download_and_install_deb \
    "FactoryTest" \
    "$FACTORY_TEST_RELEASES_URL" \
    "FACTORY_TEST_DEB_URL" \
    '[^"/]*[Ff]actory[Tt]est[^"/]*_m5stack1_arm64\.deb'
