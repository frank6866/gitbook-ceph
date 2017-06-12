# ceph存储对象的过程

往ceph中上传一个对象

```
# echo 'I am going to be stored in ceph' > data.txt
# rados -p pool-frank6866 put object-data data.txt
```

列出pool中的对象

```
# rados -p pool-frank6866 ls
object-data
```


查看pool中的对象所在的osd

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

查看文件的内容:

```
# cat object-data__head_C9CF1B74__1
I am going to be stored in ceph
```

可以发现,和data.txt文件的内容是一样的。
