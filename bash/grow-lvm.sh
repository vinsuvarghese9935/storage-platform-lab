#!/usr/bin/env bash
# grow-lvm.sh - extend an iSCSI-backed LV after the LUN was expanded on the array
# usage: sudo ./grow-lvm.sh <scsi-device e.g. sdb> <lv-path e.g. /dev/labvg/data>
set -euo pipefail

DEV="${1:?need a device name like sdb}"
LV="${2:?need an LV path like /dev/labvg/data}"

echo ">> rescanning /dev/${DEV} for new size"
echo 1 > "/sys/block/${DEV}/device/rescan"
sleep 2

echo ">> resizing PV /dev/${DEV}"
pvresize "/dev/${DEV}"

echo ">> extending LV ${LV} into all free space + growing filesystem"
lvextend -r -l +100%FREE "${LV}"

echo ">> done"
df -h "$(findmnt -no TARGET "${LV}" || echo /)"
