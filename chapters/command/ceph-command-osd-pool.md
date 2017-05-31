# pool管理
介绍pool管理相关的命令


## 列出所有pool
```
# ceph osd pool ls
rbd
volumes
images
vms
backups
.rgw.root
cn-bj-1.rgw.control
cn-bj-1.rgw.data.root
cn-bj-1.rgw.gc
cn-bj-1.rgw.log
cn-bj-1.rgw.users.uid
cn-bj-1.rgw.users.keys
cn-bj-1.rgw.buckets.index
cn-bj-1.rgw.buckets.data
cn-bj-1.rgw.usage
cn-bj-1.rgw.buckets.data.sp1
cephfs_data
cephfs_metadata
cephfs_data1
cn-bj-1.rgw.buckets.non-ec
cn-bj-1.rgw.users.email
cn-bj-1.rgw.users.swift
testrados
```

也可以查看pool的详细信息:  

```
# ceph osd pool ls detail
pool 0 'rbd' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 256 pgp_num 256 last_change 100 flags hashpspool stripe_width 0
	removed_snaps [1~3]
pool 369 'volumes' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 1742 flags hashpspool stripe_width 0
	removed_snaps [1~f]
```

* replicated size: 副本数
* min_size: 最小的副本数
* pg_num: pg数量	




## 查看所有pool的状态
```
# ceph osd pool stats
pool rbd id 0
  nothing is going on

pool volumes id 369
  client io 0 B/s rd, 264 kB/s wr, 44 op/s rd, 55 op/s wr

pool images id 370
  nothing is going on

pool vms id 371
  nothing is going on
```

* pool后面是pool的名称，比如rbd、volumes等，id后面是pool的id。
* io表示的是客户端使用这个pool的io情况，B/s rd表示读的速率，kB/s wr表示写速度；op/s rd表示读的iops，op/s wr表示写的iops

  

## 获取pool的配额信息

```
# ceph osd pool get-quota volumes
quotas for pool 'volumes':
  max objects: N/A
  max bytes  : N/A
```

* max objects: 最大对象数，默认为N/A，表示不限制
* max bytes: 最大空间，默认为N/A，表示不限制




  






