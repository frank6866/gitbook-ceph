# map

Ceph Monitor通过一系列的map来跟踪整个集群的健康状态: 

* mon map
* osd map
* pg map
* crush map

所有集群节点都向monitor节点报告状态，并分享每一个状态变化的信息。monitor为每个组件维护一个独立的map，monitor不存储实际数据，实际数据存储在osd中。

对于任何读或者写操作，客户端首先向monitor请求集群的map，之后就可以无需monitor干预直接与osd进行i/o操作。


## monitor map
monitor map维护着monitor结点间端到端的信息，包括:  

* 集群id
* monitor主机名
* monitor ip地址
* monitor端口号
* mon map的创建和最后一次修改时间

```
$ ceph mon dump
dumped monmap epoch 1
epoch 1
fsid b64cae0f-99fd-4ade-b07d-cb0b07145f3b
last_changed xxx
created xxx
0: 10.10.10.11:6789/0 mon.ceph-1
1: 10.10.10.12:6789/0 mon.ceph-2
2: 10.10.10.13:6789/0 mon.ceph-3
```

## osd map
osd map包含如下信息:  

* 集群id
* osd map的创建和最后一次修改时间
* 集群中pool相关的信息，比如副本数、pg数量等
* osd的相关信息，比如osd的id、状态、权重、osd所在主机的ip与端口信息

```
$ ceph osd dump
epoch 44560
fsid b64cae0f-99fd-4ade-b07d-cb0b07145f3b
created xxx
modified xxx
flags sortbitwise
pool 0 'rbd' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 512 pgp_num 512 last_change 2538 flags hashpspool stripe_width 0
        removed_snaps [1~3]
pool 3 'cephfs_data' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 16384 pgp_num 16384 last_change 2071 flags hashpspool crash_replay_interval 45 stripe_width 0
pool 4 'cephfs_metadata' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 1024 pgp_num 1024 last_change 2069 flags hashpspool stripe_width 0
max_osd 546
osd.0 up   in  weight 1 up_from 18561 up_thru 44007 down_at 18553 last_clean_interval [4,18556) 10.10.10.11:6800/18728 10.10.10.11:6837/1018728 10.10.10.11:6838/1018728 10.10.10.11:6839/1018728 exists,up b84555fe-af15-4959-b247-3fc578f4b39b
osd.1 up   in  weight 1 up_from 24508 up_thru 44402 down_at 24504 last_clean_interval [8,24506) 10.10.10.11:6804/19394 10.10.10.11:6848/1019394 10.10.10.11:6849/1019394 10.10.10.11:6850/1019394 exists,up fa5976b1-6504-4b87-8f50-911839fa93f3
......
......
```

其中max_osd-1表示集群中最大的osd编号









