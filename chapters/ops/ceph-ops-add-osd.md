# 添加OSD

1.列出节点上磁盘

```
# ceph-deploy disk list {hostname}
```

2.清理磁盘

```
# ceph-deploy disk zap {hostname}:{devicename}
```

执行清理的时候，会将该磁盘分区删除，磁盘上所有文件会丢失。

3.使用create命令创建OSD 

3.1如果journal和数据盘在一个磁盘上：

```
# ceph-deploy osd create {hostname}:{devicename}
```

该命令会在磁盘上创建两个分区，第一个分区为OSD的journal，另外一个分区格式化成文件系统供Ceph存储数据。 

3.2如果journal在额外的磁盘（通常为SSD）上：

```
# ceph-deploy osd create {hostname}:{devicename}:{journaldevice}
```

3.3如果需要替换Ceph OSD节点上的一个磁盘，这时可能会使用和旧的磁盘一样的journal分区，使用下面的步骤：

3.3.1找出OSD使用的journal设备(软连接到/var/lib/ceph/osd/ceph-{osd-num}/journal），例如：

```
# ls -al /var/lib/ceph/osd/ceph-1/journal
lrwxrwxrwx 1 ceph ceph 58  /var/lib/ceph/osd/ceph-1/journal -> /dev/disk/by-partuuid/xxxxxx
```

3.3.2移除一个OSD

3.3.3使用指定的分区创建新OSD

3.3.4使用新journal创建OSD

```
# ceph-deploy osd create {hostname}:{devicename}:{journaldevice}
```			

{journaldevice}为原先OSD journal使用的by-partuuid位置。

注意：尽量避免同时添加多个OSD，因为添加OSD时会进行backfill和recovery操作，影响集群性能。另外，可以在添加OSD时指定一个较小的weight，逐渐增加：

```
# ceph osd crush reweight osd.{osd-num} {weight-num}
```

4.检查集群OSD数量和数据迁移情况

