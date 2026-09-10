# Module 2 - Linux storage internals

- iSCSI: target=array port, initiator=HBA, IQN=WWPN, portal=FC port, CHAP=fabric auth
- Whole-disk PVs for array LUNs (no partition = no alignment issues)
- Online grow path: expand LUN on array -> `echo 1 > /sys/block/<dev>/device/rescan`
  -> `pvresize` -> `lvextend -r` (xfs_growfs runs automatically)
- XFS cannot shrink. To free a LUN: `vgextend` new LUN -> `pvmove` off old -> `vgreduce`/`pvremove`
- Scheduler `none` for SAN/iSCSI; `mq-deadline` for local disk
- iostat: r_await/w_await = latency (the number that matters), aqu-sz = queue depth

## Multipath (2-path iSCSI)
- 2nd NIC on host, one `iscsiadm iface` bound to each NIC (`iface.net_ifacename`)
- 2 NICs on one subnet => set `net.ipv4.conf.all.rp_filter = 2` (loose)
- `mpathconf --enable`; `multipath -ll` shows map (WWID = LUN NAA/serial equiv), path groups
- Equal `prio=1` + no ALUA handler => failover mode (1 active path). Real arrays: ALUA groups optimised paths `active`, non-optimised `enabled`
- `path_grouping_policy multibus` in multipath.conf => active/active round-robin
- LVM auto-uses /dev/mapper/mpathX, ignores underlying sdX (multipath_component_detection); `lvmdevices --update` fixes a stale devices file
- Failover: down one NIC -> path `failed faulty`, I/O continues on the other
- Both paths down -> `queue_if_no_path` holds I/O (stall, not error); restore -> queue flushes
