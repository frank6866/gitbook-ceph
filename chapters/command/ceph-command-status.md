# 集群状态

使用如下命令可以查看集群状态:

> ceph -s

示例输出

```
[root@frank-ceph-1 ~]# ceph -s
    cluster c712f08b-c001-4b1c-969d-abec240138f7
     health HEALTH_WARN
            clock skew detected on mon.frank-ceph-2, mon.frank-ceph-3
            Monitor clock skew detected
     monmap e1: 3 mons at {frank-ceph-1=10.10.10.5:6789/0,frank-ceph-2=10.10.10.6:6789/0,frank-ceph-3=10.10.10.7:6789/0}
            election epoch 4, quorum 0,1,2 frank-ceph-1,frank-ceph-2,frank-ceph-3
     osdmap e15: 3 osds: 3 up, 3 in
            flags sortbitwise,require_jewel_osds
      pgmap v31: 64 pgs, 1 pools, 0 bytes data, 0 objects
            101 MB used, 134 GB / 134 GB avail
                  64 active+clean
```


## cluster
> cluster c712f08b-c001-4b1c-969d-abec240138f7

cluster表示集群的id。

## health
health表示集群的健康状态:

* **HEALTH_OK**表示集群状态正常
* **HEALTH_WARN**表示有告警














