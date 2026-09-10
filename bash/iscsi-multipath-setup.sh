#!/usr/bin/env bash
# Reference: bring up 2-path iSCSI to the lab TerraMaster target.
# Not idempotent - a walkthrough, not production. See docs/module2-notes.md
set -euo pipefail
PORTAL=192.168.0.144
T=iqn.tnas.terramaster.26910113309
NIC_A=ens160
NIC_B=ens224

sudo iscsiadm -m iface -I iscsi-a --op new
sudo iscsiadm -m iface -I iscsi-a --op update -n iface.net_ifacename -v "$NIC_A"
sudo iscsiadm -m iface -I iscsi-b --op new
sudo iscsiadm -m iface -I iscsi-b --op update -n iface.net_ifacename -v "$NIC_B"

sudo iscsiadm -m discovery -t st -p "$PORTAL" -I iscsi-a -I iscsi-b
sudo iscsiadm -m node -T "$T" --op update -n node.session.auth.authmethod -v CHAP
sudo iscsiadm -m node -T "$T" --op update -n node.session.auth.username -v Vinsu
sudo iscsiadm -m node -T "$T" --op update -n node.session.auth.password -v '<CHAP-PASS>'
sudo iscsiadm -m node -T "$T" -o update -n node.startup -v automatic
sudo iscsiadm -m node -T "$T" -l

sudo mpathconf --enable --with_multipathd y --user_friendly_names y
sudo systemctl enable --now multipathd iscsi iscsid
sudo multipath -ll
