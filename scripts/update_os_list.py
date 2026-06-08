#!/usr/bin/env python3
"""
update_os_list.py — Accumulative update of os-list.json for the M5 Imager.

Adds a new CardputerZero OS entry (or updates an existing one with the same
tag). Preserves all historical entries so test engineers can flash any version.

Usage (called by the CI publish workflow):
    python3 scripts/update_os_list.py \
        --json os-list.json \
        --tag 20260601-022317-29f3dcd \
        --release-date 2026-06-01 \
        --is-prerelease false \
        --release-url https://github.com/CardputerZero/pi-gen/releases/tag/... \
        --oss-filename cardputerzero-trixie-arm64-20260601-022317-29f3dcd.img.xz \
        --download-size 1460389544 \
        --download-sha256 01a6abcc... \
        --extract-size 6576668672 \
        --extract-sha256 930fdab1...
"""

import argparse
import json
import sys


BASE_URL = "https://cardputer-zero-repo.oss-cn-shenzhen.aliyuncs.com"
ICON_URL = f"{BASE_URL}/icons/cardputerzero.png"


def main():
    p = argparse.ArgumentParser(description="Update os-list.json with a new release entry")
    p.add_argument("--json", required=True, help="Path to os-list.json (read + overwrite)")
    p.add_argument("--tag", required=True)
    p.add_argument("--release-date", required=True, help="YYYY-MM-DD from GitHub Release published_at")
    p.add_argument("--is-prerelease", required=True, choices=["true", "false"])
    p.add_argument("--release-url", required=True)
    p.add_argument("--oss-filename", required=True, help="e.g. cardputerzero-trixie-arm64-<tag>.img.xz")
    p.add_argument("--download-size", required=True, type=int)
    p.add_argument("--download-sha256", required=True)
    p.add_argument("--extract-size", required=True, type=int)
    p.add_argument("--extract-sha256", required=True)
    args = p.parse_args()

    is_prerelease = args.is_prerelease == "true"

    # Build the new entry
    if is_prerelease:
        display_name = f"CardputerZero OS {args.tag} (beta)"
        description = "Debian Trixie arm64 desktop for CardputerZero. Pre-release build."
    else:
        display_name = "CardputerZero OS (Trixie arm64)"
        description = "Debian Trixie arm64 desktop for CardputerZero. (建议)"

    new_entry = {
        "name": display_name,
        "description": description,
        "icon": ICON_URL,
        "url": f"{BASE_URL}/{args.oss_filename}",
        "extract_size": args.extract_size,
        "extract_sha256": args.extract_sha256,
        "image_download_size": args.download_size,
        "image_download_sha256": args.download_sha256,
        "release_date": args.release_date,
        "init_format": "cloudinit-rpi",
        "devices": ["m5-cardputerzero", "pi3-64bit"],
        "architecture": "armv8",
        "capabilities": ["i2c", "spi", "serial", "usb_otg"],
        "github_release": args.release_url,
        "tag": args.tag,
        "is_prerelease": is_prerelease,
    }

    # Load existing JSON
    with open(args.json) as f:
        data = json.load(f)

    os_list = data.get("os_list", [])

    # Remove any existing entry with the same tag (idempotent re-publish)
    os_list = [e for e in os_list if e.get("tag") != args.tag]

    # If stable release: also update/replace the "latest" alias entry
    if not is_prerelease:
        # Remove old "latest" entry (url contains -latest.img.xz)
        os_list = [e for e in os_list if "-latest.img.xz" not in e.get("url", "")]
        # Insert latest as top entry
        latest_entry = dict(new_entry)
        latest_entry["url"] = f"{BASE_URL}/cardputerzero-trixie-arm64-latest.img.xz"
        os_list.insert(0, latest_entry)

    # Insert the tagged entry among CardputerZero entries
    # Find where non-CardputerZero entries start
    insert_idx = len(os_list)
    for i, e in enumerate(os_list):
        if ("cardputerzero" not in e.get("url", "").lower()
                and "CardputerZero" not in e.get("name", "")):
            insert_idx = i
            break

    # Don't duplicate if same URL already exists (from the latest insert above)
    if not any(e.get("url", "").endswith(args.oss_filename) for e in os_list):
        os_list.insert(insert_idx, new_entry)

    # Sort CardputerZero entries: stable first (newest to oldest), then beta (newest to oldest)
    cz_entries = [e for e in os_list if "cardputerzero" in e.get("url", "").lower()]
    other_entries = [e for e in os_list if "cardputerzero" not in e.get("url", "").lower()]

    stable = sorted(
        [e for e in cz_entries if not e.get("is_prerelease")],
        key=lambda e: e.get("release_date", ""),
        reverse=True,
    )
    beta = sorted(
        [e for e in cz_entries if e.get("is_prerelease")],
        key=lambda e: e.get("release_date", ""),
        reverse=True,
    )

    data["os_list"] = stable + beta + other_entries

    # Write back
    with open(args.json, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")

    total_cz = len(stable) + len(beta)
    label = "beta" if is_prerelease else "stable"
    print(f"✓ Added {args.tag} ({label}), total CardputerZero entries: {total_cz}")
    for e in stable + beta:
        flag = "(beta)" if e.get("is_prerelease") else "(建议)"
        print(f"  {e['release_date']} {flag} {e.get('tag','?')}")


if __name__ == "__main__":
    main()
