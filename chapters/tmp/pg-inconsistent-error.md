故障现象：
# ceph -s
    cluster b64cae0f-99fd-4ade-b07d-cb0b07145f3b
     health HEALTH_ERR
            984 pgs backfill_wait
            18 pgs backfilling
            3 pgs degraded
            1 pgs inconsistent
            3 pgs recovery_wait
            1005 pgs stuck unclean
            recovery 30422/305338226 objects degraded (0.010%)
            recovery 12131514/305338226 objects misplaced (3.973%)
            1 scrub errors
     monmap e1: 3 mons at {xg-ops-ceph-1=10.0.36.23:6789/0,xg-ops-ceph-20=10.0.36.57:6789/0,xg-ops-ceph-40=10.0.36.44:6789/0}
            election epoch 794, quorum 0,1,2 xg-ops-ceph-1,xg-ops-ceph-40,xg-ops-ceph-20
      fsmap e2928: 1/1/1 up {0=xg-ops-ceph-20=up:active}, 2 up:standby
     osdmap e60158: 618 osds: 612 up, 612 in; 1002 remapped pgs
            flags sortbitwise
      pgmap v29614057: 17920 pgs, 3 pools, 375 TB data, 97405 kobjects
            1134 TB used, 1088 TB / 2222 TB avail
            30422/305338226 objects degraded (0.010%)
            12131514/305338226 objects misplaced (3.973%)
               16914 active+clean
                 984 active+remapped+wait_backfill
                  18 active+remapped+backfilling
                   3 active+recovery_wait+degraded
                   1 active+clean+inconsistent
使用ceph health detail 确认出现问题的pg：
# ceph health detail | grep inconsistent
HEALTH_ERR 979 pgs backfill_wait; 20 pgs backfilling; 3 pgs degraded; 1 pgs inconsistent; 3 pgs recovery_wait; 1002 pgs stuck unclean; recovery 30576/305323886 objects degraded (0.010%); recovery 12100174/305323886 objects misplaced (3.963%); 1 scrub errors
pg 3.3eb is active+clean+inconsistent, acting [435,466,369]
出现pg的primary OSD为435，查询该OSD的日志：
# grep -Hn 'ERR' /var/log/ceph/ceph-osd.435.log
# zgrep -Hn 'ERR' /var/log/ceph/ceph-osd.435.log-201706*
/var/log/ceph/ceph-osd.435.log-20170623.gz:4953:2017-06-23 02:21:48.839993 7ff0c0ec7700 -1 log_channel(cluster) log [ERR] : 3.3eb shard 369: soid 3:d7c1465b:::100016e3881.0000012c:head candidate had a read error
/var/log/ceph/ceph-osd.435.log-20170623.gz:4963:2017-06-23 02:24:39.522052 7ff0be6c2700 -1 log_channel(cluster) log [ERR] : 3.3eb deep-scrub 0 missing, 1 inconsistent objects
/var/log/ceph/ceph-osd.435.log-20170623.gz:4964:2017-06-23 02:24:39.522095 7ff0be6c2700 -1 log_channel(cluster) log [ERR] : 3.3eb deep-scrub 1 errors
列出inconsistent的详细信息：
# rados list-inconsistent-obj 3.3eb --format=json-pretty
[
    {
        "object": {
            "name": "100016e3881.0000012c",
            "nspace": "",
            "locator": "",
            "snap": "head"
        },
        "missing": false,
        "stat_err": false,
        "read_err": true,
        "data_digest_mismatch": false,
        "omap_digest_mismatch": false,
        "size_mismatch": false,
        "attr_mismatch": false,
        "shards": [
            {
                "osd": 369,
                "missing": false,
                "read_error": true,
                "data_digest_mismatch": false,
                "omap_digest_mismatch": false,
                "size_mismatch": false,
                "size": 4194304
            },
            {
                "osd": 435,
                "missing": false,
                "read_error": false,
                "data_digest_mismatch": false,
                "omap_digest_mismatch": false,
                "size_mismatch": false,
                "data_digest_mismatch_oi": false,
                "omap_digest_mismatch_oi": false,
                "size_mismatch_oi": false,
                "size": 4194304,
                "omap_digest": "0xffffffff",
                "data_digest": "0x154cbce1"
            },
            {
                "osd": 466,
                "missing": false,
                "read_error": false,
                "data_digest_mismatch": false,
                "omap_digest_mismatch": false,
                "size_mismatch": false,
                "data_digest_mismatch_oi": false,
                "omap_digest_mismatch_oi": false,
                "size_mismatch_oi": false,
                "size": 4194304,
                "omap_digest": "0xffffffff",
                "data_digest": "0x154cbce1"
            }
        ]
    }
]
对象 100016e3881.0000012c 在OSD 369上出现read error。
查看对应主机上dmesg信息：
[16550100.097666] sd 0:2:2:0: [sdc]
[16550100.097676] Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE
[16550100.097678] sd 0:2:2:0: [sdc]
[16550100.097680] Sense Key : Medium Error [current]
[16550100.097683] sd 0:2:2:0: [sdc]
[16550100.097685] Add. Sense: Unrecovered read error
[16550100.097687] sd 0:2:2:0: [sdc] CDB:
[16550100.097689] Read(16): 88 00 00 00 00 00 02 00 6f d0 00 00 02 00 00 00
[16550100.097695] end_request: critical medium error, dev sdc, sector 33583056
[16550102.889716] sd 0:2:2:0: [sdc]
[16550102.889725] Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE
[16550102.889732] sd 0:2:2:0: [sdc]
[16550102.889734] Sense Key : Medium Error [current]
[16550102.889737] sd 0:2:2:0: [sdc]
[16550102.889739] Add. Sense: Unrecovered read error
[16550102.889741] sd 0:2:2:0: [sdc] CDB:
[16550102.889744] Read(16): 88 00 00 00 00 00 02 00 6f e0 00 00 00 08 00 00
[16550102.889751] end_request: critical medium error, dev sdc, sector 33583072
[16550105.783095] sd 0:2:2:0: [sdc]
[16550105.783104] Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE
[16550105.783106] sd 0:2:2:0: [sdc]
[16550105.783108] Sense Key : Medium Error [current]
[16550105.783112] sd 0:2:2:0: [sdc]
[16550105.783114] Add. Sense: Unrecovered read error
[16550105.783116] sd 0:2:2:0: [sdc] CDB:
[16550105.783117] Read(16): 88 00 00 00 00 00 02 00 6f e0 00 00 00 08 00 00
[16550105.783126] end_request: critical medium error, dev sdc, sector 33583072
有磁盘medium 错误。
该错误为磁盘故障导致，理论上无法通过软件层面（例如ceph pg repair进行修复）。
方案一： 尝试ceph pg repair
ceph pg repair 3.3eb
修复后集群恢复正常，查看OSD 435日志：
# grep -Hn 'ERR' /var/log/ceph/ceph-osd.435.log
/var/log/ceph/ceph-osd.435.log:1086:2017-06-23 10:09:06.645096 7ff0be6c2700 -1 log_channel(cluster) log [ERR] : 3.3eb shard 369: soid 3:d7c1465b:::100016e3881.0000012c:head candidate had a read error
/var/log/ceph/ceph-osd.435.log:1138:2017-06-23 10:12:31.125402 7ff0be6c2700 -1 log_channel(cluster) log [ERR] : 3.3eb repair 0 missing, 1 inconsistent objects
/var/log/ceph/ceph-osd.435.log:1139:2017-06-23 10:12:31.125427 7ff0be6c2700 -1 log_channel(cluster) log [ERR] : 3.3eb repair 1 errors, 1 fixed
虽然已经修复该问题，但是对应磁盘仍旧有故障情况，后续考虑更换磁盘。
方案二： 如果以上方案出现问题，可以手动停止该OSD进程，触发迁移。





