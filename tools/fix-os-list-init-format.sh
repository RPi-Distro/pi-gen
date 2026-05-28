#!/bin/bash
# One-time fix: change init_format from "systemd" to "cloudinit-rpi" for CardputerZero OS
# Run locally with ossutil configured, or trigger publish-latest-stable workflow.

set -e

OSS_PATH="oss://cardputer-zero-repo/os-list.json"
LOCAL="os-list.json"

echo "Downloading current os-list.json..."
ossutil cp "$OSS_PATH" "$LOCAL"

echo "Before:"
python3 -c "
import json
data = json.load(open('$LOCAL'))
for item in data.get('os_list', []):
    if 'init_format' in item:
        print(f'  {item[\"name\"]}: init_format={item[\"init_format\"]}')
"

echo ""
echo "Fixing init_format for CardputerZero OS entry..."
python3 -c "
import json
data = json.load(open('$LOCAL'))
target = 'https://cardputer-zero-repo.oss-cn-shenzhen.aliyuncs.com/cardputerzero-trixie-arm64-latest.img.xz'
for item in data.get('os_list', []):
    if item.get('url') == target:
        item['init_format'] = 'cloudinit-rpi'
        print(f'  Updated: {item[\"name\"]} -> cloudinit-rpi')
        break
with open('$LOCAL', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
"

echo ""
echo "After:"
python3 -c "
import json
data = json.load(open('$LOCAL'))
for item in data.get('os_list', []):
    if 'init_format' in item:
        print(f'  {item[\"name\"]}: init_format={item[\"init_format\"]}')
"

echo ""
echo "Uploading fixed os-list.json..."
ossutil cp -f "$LOCAL" "$OSS_PATH"
rm -f "$LOCAL"
echo "Done."
