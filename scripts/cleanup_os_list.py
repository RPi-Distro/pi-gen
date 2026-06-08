#!/usr/bin/env python3
"""
cleanup_os_list.py — Remove specific entries from os-list.json by tag.

Usage:
    python3 scripts/cleanup_os_list.py \
        --json os-list.json \
        --remove-tags "20260608-081346-963b259,20260608-091152-6a86c35"
"""

import argparse
import json


def main():
    p = argparse.ArgumentParser(description="Remove entries from os-list.json by tag")
    p.add_argument("--json", required=True, help="Path to os-list.json (read + overwrite)")
    p.add_argument("--remove-tags", required=True,
                   help="Comma-separated list of tags to remove")
    args = p.parse_args()

    tags_to_remove = set(t.strip() for t in args.remove_tags.split(",") if t.strip())
    if not tags_to_remove:
        print("No tags specified, nothing to do.")
        return

    with open(args.json) as f:
        data = json.load(f)

    os_list = data.get("os_list", [])
    before_count = len(os_list)

    # Remove entries whose tag matches any in the removal set
    removed = []
    kept = []
    for e in os_list:
        tag = e.get("tag", "")
        if tag in tags_to_remove:
            removed.append(e)
        else:
            kept.append(e)

    data["os_list"] = kept

    with open(args.json, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"✓ Removed {len(removed)} entries, {len(kept)} remaining (was {before_count})")
    for e in removed:
        print(f"  - {e.get('name', '?')} | tag={e.get('tag', '?')}")
    if tags_to_remove - set(e.get("tag", "") for e in removed):
        missing = tags_to_remove - set(e.get("tag", "") for e in removed)
        print(f"  ⚠ Tags not found in JSON (already removed?): {missing}")


if __name__ == "__main__":
    main()
