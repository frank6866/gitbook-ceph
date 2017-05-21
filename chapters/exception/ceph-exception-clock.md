# clock skew detected

ceph的健康状态为HEALTH_WARN,提示"Monitor clock skew detected":

```
# ceph -s
    cluster c712f08b-c001-4b1c-969d-abec240138f7
     health HEALTH_WARN
            clock skew detected on mon.frank-ceph-2, mon.frank-ceph-3
            Monitor clock skew detected
......
```

skew是偏离的意思,ceph的各个节点上时间需要一致,提示"Monitor clock skew detected"表示节点上的时间不一致。

解决思路:  检查口ntp服务状态

