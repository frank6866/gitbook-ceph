# 集群信息

## 上海纪蕴机房
sh-ops-ceph-1

15台物理机, 每台物理机12块4T的SATA盘.

OSD个数: 179个

容量信息:

```
[root@sh-ops-ceph-1 ~]# ceph df
GLOBAL:
    SIZE     AVAIL     RAW USED     %RAW USED
    650T      303T         346T         53.28
POOLS:
    NAME                ID     USED       %USED     MAX AVAIL     OBJECTS
    rbd                 0           0         0        66586G            0
    cephfs_data         1        115T     53.24        66586G     30469566
    cephfs_metadata     2      47770k         0        66586G         8324
```


## 北京星光机房(fuss RGW集群)
xg-cloud-ceph-1

14台物理机, 每台物理机12块4T的SATA盘.

OSD个数: 462个

容量信息:

```
[root@xg-cloud-ceph-1 ~]# ceph df
GLOBAL:
    SIZE     AVAIL     RAW USED     %RAW USED
    379T      206T         173T         45.68
POOLS:
    NAME                           ID     USED       %USED     MAX AVAIL     OBJECTS
    rbd                            0           0         0        58130G             0
    .rgw.root                      1        1636         0        58130G             4
    default.rgw.control            2           0         0        58130G             8
    default.rgw.data.root          3        974k         0        58130G          3098
    default.rgw.gc                 4           0         0        58130G            32
    default.rgw.log                5           0         0        58130G           127
    default.rgw.users.uid          6        2800         0        58130G            14
    default.rgw.users.keys         7         120         0        58130G             9
    default.rgw.meta               8        985k         0         1617G          3131
    default.rgw.buckets.index      9           0         0         1617G        154798
    default.rgw.buckets.data       10     57153G     44.00        58130G     412436640
    default.rgw.buckets.non-ec     12          0         0        58130G             0
```


## 北京星光机房(DB备份集群)
xg-ops-ceph-1

40台物理机, 每台物理机12块4T的SATA盘.

OSD个数: 462个

容量信息:

```
[root@xg-ops-ceph-1 ~]# ceph df
GLOBAL:
    SIZE      AVAIL     RAW USED     %RAW USED
    1666T      427T        1239T         74.37
POOLS:
    NAME                ID     USED       %USED     MAX AVAIL     OBJECTS
    rbd                 0      10293G      1.81        44156G       2664569
    cephfs_data         3        402T     72.42        44156G     107077951
    cephfs_metadata     4      47416k         0        44156G         31878
```



## 万国
wg-cloud-cephmon-1

62台物理机作OSD结点, 每台物理机12块4T的SATA盘;3台作monitor结点。

OSD个数: 839个

容量信息:

```
# ceph df
GLOBAL:
    SIZE      AVAIL     RAW USED     %RAW USED
    2668T     1938T         730T         27.37
POOLS:
    NAME                           ID     USED       %USED     MAX AVAIL     OBJECTS
    rbd                            0      25589G      4.33          552T       6558805
    .rgw.root                      13       1588         0          552T             4
    default.rgw.control            14          0         0          552T             8
    default.rgw.data.root          15       975k         0          552T          3168
    default.rgw.gc                 16          0         0          552T            32
    default.rgw.log                17          0         0          552T           127
    default.rgw.users.uid          18       3332         0          552T            19
    default.rgw.users.keys         19        125         0          552T            10
    default.rgw.buckets.index      20          0         0        28042G        158400
    default.rgw.buckets.data       21       216T     28.12          552T     575844101
    default.rgw.users.email        22          0         0          552T             0
    default.rgw.buckets.non-ec     23          0         0          552T            31
```



# summary
4套集群的总容量为5363TB, 已用数据总量为2488TB.


