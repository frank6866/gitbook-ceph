# pool管理
介绍pool管理相关的命令

## 创建pool

```
# ceph osd pool create pool-frank6866 128
pool 'pool-frank6866' created
```



## 列出所有pool
```
# ceph osd pool ls
rbd
pool-frank6866
```

也可以查看pool的详细信息:  

```
# ceph osd pool ls detail
pool 0 'rbd' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 64 pgp_num 64 last_change 1 flags hashpspool stripe_width 0
pool 1 'pool-frank6866' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 37 flags hashpspool stripe_width 0
```

* replicated size: 副本数
* min_size: 最小的副本数
* pg_num: pg数量	



## 查看某个pool的pg个数
查看名为pool-frank6866的pool中pg的个数

```
# ceph osd pool get pool-frank6866 pg_num
pg_num: 128
```


## 修改pool中对象的副本数
将pool-frank6866的副本数设置为5

```
# ceph osd pool set pool-frank6866 size 5
set pool 1 size to 5
```






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



## 往pool中上传对象
```
# dd if=/dev/zero of=data.img bs=1M count=32
# rados -p pool-frank6866 put object-data data.img
```

## 列出pool中的对象

```
# rados -p pool-frank6866 ls
object-data
```




```
# ceph osd map pool-frank6866 object-data
osdmap e42 pool 'pool-frank6866' (1) object 'object-data' -> pg 1.c9cf1b74 (1.74) -> up ([2,0,1], p2) acting ([2,0,1], p2)
```

* osdmap e42: 表示osdmap的版本是42
* pool 'pool-frank6866': 表示pool的名称是pool-frank6866
* (1): 表示pool的id是1
* object 'object-data': 表示对象名是object-data
* pg 1.c9cf1b74 (1.74): 表示对象所属pg的id是1.74,c9cf1b74表示的是对象的id
* up ([2,0,1], p2): 这里副本数设置的是3,up表示该对象所在的osd的id



查找id为2的osd所在的主机

```
# ceph osd find 2
{
    "osd": 2,
    "ip": "10.10.10.77:6800\/20546",
    "crush_location": {
        "host": "ceph-3",
        "root": "default"
    }
}
```


登录osd所在主机上查看挂载的目录信息:

```
# df -lTh /var/lib/ceph/osd/ceph-2
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb1      xfs    45G   68M   45G   1% /var/lib/ceph/osd/ceph-2
```

根据pg id查看该pg存放数据的地方:

```
# ls -al /var/lib/ceph/osd/ceph-2/current | grep 1.74
drwxr-xr-x   2 ceph ceph    67 Jun  3 17:20 1.74_head
drwxr-xr-x   2 ceph ceph     6 Jun  3 16:53 1.74_TEMP
```

查看pg所在目录的结构:

```
# tree /var/lib/ceph/osd/ceph-2/current/1.74_head/
/var/lib/ceph/osd/ceph-2/current/1.74_head/
├── __head_00000074__1
└── object-data__head_C9CF1B74__1
```












