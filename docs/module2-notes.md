# Module 2 - Linux storage internals

- iSCSI: target=array port, initiator=HBA, IQN=WWPN, portal=FC port, CHAP=fabric auth
- Whole-disk PVs for array LUNs (no partition = no alignment issues)
- Online grow path: expand LUN on array -> `echo 1 > /sys/block/<dev>/device/rescan`
  -> `pvresize` -> `lvextend -r` (xfs_growfs runs automatically)
- XFS cannot shrink. To free a LUN: `vgextend` new LUN -> `pvmove` off old -> `vgreduce`/`pvremove`
- Scheduler `none` for SAN/iSCSI; `mq-deadline` for local disk
- iostat: r_await/w_await = latency (the number that matters), aqu-sz = queue depth
