# pg状态

以一个正在扩容的集群为例:  

```
# ceph -s
    cluster xxxxxx
     health HEALTH_WARN
            9 pgs backfill_toofull
            854 pgs backfill_wait
            12 pgs backfilling
            569 pgs degraded
            441 pgs recovery_wait
            1420 pgs stuck unclean
            128 pgs undersized
            recovery 756251/330647041 objects degraded (0.229%)
            recovery 11888297/330647041 objects misplaced (3.595%)
            18 near full osd(s)
            mds0: Client 32724142 failing to respond to cache pressure
            1/472 in osds are down
            noout,sortbitwise flag(s) set
     monmap e1: 3 mons at {ceph-1=10.10.10.11:6789/0,ceph-20=10.10.10.12:6789/0,ceph-40=10.10.10.13:6789/0}
            election epoch 758, quorum 0,1,2 ceph-1,ceph-40,ceph-20
      fsmap e2910: 1/1/1 up {0=ceph-1=up:active}, 2 up:standby
     osdmap e31996: 476 osds: 471 up, 472 in; 1006 remapped pgs
            flags noout,sortbitwise
      pgmap v28969688: 17920 pgs, 3 pools, 406 TB data, 103 Mobjects
            1222 TB used, 491 TB / 1713 TB avail
            756251/330647041 objects degraded (0.229%)
            11888297/330647041 objects misplaced (3.595%)
               16466 active+clean
                 828 active+remapped+wait_backfill
                 414 active+recovery_wait+degraded
                 109 active+undersized+degraded
                  27 active+recovery_wait+degraded+remapped
                  22 active+clean+scrubbing+deep
                  18 active+undersized+degraded+remapped+wait_backfill
                  12 active+clean+scrubbing
                  11 active+remapped+backfilling
                   8 active+remapped+wait_backfill+backfill_toofull
                   3 active+remapped
                   1 active+remapped+backfill_toofull
                   1 active+undersized+degraded+remapped+backfilling
recovery io 1197 MB/s, 308 objects/s
  client io 8117 kB/s rd, 204 MB/s wr, 63 op/s rd, 116 op/s wr
```

* creating: ceph在创建pg
* active: 正常状态，ceph将请求发送到pg上
* clean: ceph对pg中所有对象都创建了配置的副本数
* down: pg中的对象不能满足法定个数，pg离线
* Scrubbing: ceph在check pg的不一致性
* Degraded: pg中的某些对象没有达到指定的副本数
* Inconsistent: ceph检测到pg中某个对象的副本不一致
* peering: pg在进行peering操作
* repairing: ceph在检查pg并尽可能修复不一致的数据
* recovering: ceph在迁移或者同步对象和它的副本
* Backfill: backfill是恢复的一种特例，ceph在扫描和同步pg所有的内容，而不是从日志中查看最近的操作来决定哪些内容需要同步
* Wait-backfill: pg在排队等待开始backfill
* Backfill-toofull: backfill操作在等待，因为目标OSD快满了
* Incomplete: ceph检测到丢失了写操作的信息，或者没有一个正常的副本。遇到这种情况，尝试启动down的osd，可能在这些down的osd里面有需要的信息
* Stale: pg处于未知的状态，自从pg map变化后，monitor没有收到来自pg的消息
* Remapped: pg被临时map到CRUSH指定的osd集合中
* Undersized: pg副本的数量小于pool设置的副本数
* Peered: peering操作已经完成








# osd down排查
查看down了的osd

```
# ceph osd tree | grep down
431    3.56000         osd.431            down        0          1.00000
178    3.63129         osd.178            down  1.00000          1.00000
461    3.63129         osd.461            down        0          1.00000
379    3.63129         osd.379            down        0          1.00000
411    3.63129         osd.411            down        0          1.00000
```

以431为例，查看osd所在的主机

```
# ceph osd find 431
{
    "osd": 431,
    "ip": "10.0.36.32:6812\/21453",
    "crush_location": {
        "host": "xg-ops-ceph-3",
        "root": "default"
    }
}
```

登录osd所在主机，




























