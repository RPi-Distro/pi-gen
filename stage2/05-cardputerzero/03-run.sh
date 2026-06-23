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

    local deb_url="${!deb_url_var:-}"
    if [ -z "$deb_url" ]; then
        deb_url=$({ curl -fsSL "${AUTH_ARGS[@]}" "$api_url" || true; } \
            | grep -Eo "https://github.com/[^\"]*/${filename_pattern}" \
            | head -1)
    fi

    if [ -z "$deb_url" ]; then
        echo "ERROR: Could not find ${app_name} m5stack1 arm64 deb URL"
        exit 1
    fi

    local deb_file="${deb_url##*/}"
    echo "Downloading ${app_name} from: $deb_url"
    curl -fsSL -o "${ROOTFS_DIR}/tmp/${deb_file}" -L "$deb_url"

    on_chroot << CHROOT
set -e
apt-get install -y --no-install-recommends "/tmp/${deb_file}"
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
    'CameraApp_[^"/]*_m5stack1_arm64\.deb'

download_and_install_deb \
    "FactoryTest" \
    "$FACTORY_TEST_RELEASES_URL" \
    "FACTORY_TEST_DEB_URL" \
    '[^"/]*[Ff]actory[Tt]est[^"/]*_m5stack1_arm64\.deb'
