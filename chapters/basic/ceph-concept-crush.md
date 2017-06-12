# CRUSH
CRUSH(Controlled Replication Under Scalable Hashing)算法通过计算数据存储的位置决定如何存储和获取数据。

CRUSH算法可以让客户端直接和OSD进行通信，而不用通过一个中心节点或者代理，从架构上避免了单点故障，避免了性能瓶颈，避免了容量限制。

1. Ceph首先计算数据data的hash值，用hash值对pg数进行取余运算，得到数据data的pg编号。  
2. 通过CRUSH算法将pg映射到一组OSD中
3. 把数据data存放到pg对应的OSD中

这个过程包含了两次映射：将数据映射到PG，将PG映射到OSD。


CRUSH算法的目的是给PG分配一组存储数据的OSD。在选择OSD的过程中，需要考虑：  

* PG在OSD上均衡地分布。根据OSD的权重，处理相应的PG；权重越大的OSD，存储更过的PG
* PG所在的OSD在不同的故障域上。


pg到osd的映射存储在Monitor节点中。






```
# ceph osd crush dump
{
    "devices": [
        {
            "id": 0,
            "name": "device0"
        },
        {
            "id": 1,
            "name": "osd.1"
        },
        {
            "id": 2,
            "name": "device2"
        },
        {
            "id": 3,
            "name": "osd.3"
        },
......
    ],
    "types": [
        {
            "type_id": 0,
            "name": "osd"
        },
        {
            "type_id": 1,
            "name": "host"
        },
        {
            "type_id": 2,
            "name": "chassis"
        },
        {
            "type_id": 3,
            "name": "rack"
        },
        {
            "type_id": 4,
            "name": "row"
        },
        {
            "type_id": 5,
            "name": "pdu"
        },
        {
            "type_id": 6,
            "name": "pod"
        },
        {
            "type_id": 7,
            "name": "room"
        },
        {
            "type_id": 8,
            "name": "datacenter"
        },
        {
            "type_id": 9,
            "name": "region"
        },
        {
            "type_id": 10,
            "name": "root"
        }
    ],
    "buckets": [
        {
            "id": -1,
            "name": "default",
            "type_id": 10,
            "type_name": "root",
            "weight": 572558,
            "alg": "straw",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": -2,
                    "weight": 230384,
                    "pos": 0
                },
                {
                    "id": -3,
                    "weight": 171087,
                    "pos": 1
                },
                {
                    "id": -4,
                    "weight": 171087,
                    "pos": 2
                }
            ]
        },
        {
            "id": -2,
            "name": "ceph-1",
            "type_id": 1,
            "type_name": "host",
            "weight": 230384,
            "alg": "straw",
            "hash": "rjenkins1",
            "items": [
                {
                    "id": 3,
                    "weight": 56957,
                    "pos": 0
                },
                {
                    "id": 4,
                    "weight": 56957,
                    "pos": 1
                },
                {
                    "id": 5,
                    "weight": 56957,
                    "pos": 2
                },
                {
                    "id": 1,
                    "weight": 59513,
                    "pos": 3
                }
            ]
        },
......
    ],
    "rules": [
        {
            "rule_id": 0,
            "rule_name": "replicated_ruleset",
            "ruleset": 0,
            "type": 1,
            "min_size": 1,
            "max_size": 10,
            "steps": [
                {
                    "op": "take",
                    "item": -1,
                    "item_name": "default"
                },
                {
                    "op": "chooseleaf_firstn",
                    "num": 0,
                    "type": "host"
                },
                {
                    "op": "emit"
                }
            ]
        }
    ],
    "tunables": {
        "choose_local_tries": 0,
        "choose_local_fallback_tries": 0,
        "choose_total_tries": 50,
        "chooseleaf_descend_once": 1,
        "chooseleaf_vary_r": 1,
        "chooseleaf_stable": 0,
        "straw_calc_version": 1,
        "allowed_bucket_algs": 22,
        "profile": "firefly",
        "optimal_tunables": 0,
        "legacy_tunables": 0,
        "minimum_required_version": "firefly",
        "require_feature_tunables": 1,
        "require_feature_tunables2": 1,
        "has_v2_rules": 0,
        "require_feature_tunables3": 1,
        "has_v3_rules": 0,
        "has_v4_buckets": 0,
        "require_feature_tunables5": 0,
        "has_v5_rules": 0
    }
}

```

CRUSH map主要包括四个部分:

* Devices: 表示集群中当前或者历史的OSD,如果id对应的OSD在集群中还存在,那么device的名称就是osd的名称,比如osd.1;如果device id对应的osd在集群中不存在了,那么device name的名称是device+id,比如device0
* Bucket Types: Bucket定义了CRUSH层级结构中Bucket的类型。比如rows, racks, chassis, hosts等
* Bucket instances: 对集群中的资源,定义它属于某个类型的bucket。比如物理机的bucket type为host
* Rules: 定义了选择bucket的规则


常见的type如下:

```
# types
type 0 osd
type 1 host
type 2 chassis
type 3 rack
type 4 row
type 5 pdu
type 6 pod
type 7 room
type 8 datacenter
type 9 region
type 10 root
```


CRUSH map包括

* OSD的列表
* bucket的列表,bucket将设备聚合到物理位置
* rule的列表,rule概述CRUSH算法如何将pool中的数据副本分布在集群中

通过映射底层的物理结构,CRUSH算法可以解决可能的关联设备失效,比如共享电源或网络导致的失效。将这些可能导致失效的信息存储到cluster map中,CRUSH放置副本的策略可以将对象的副本存储在不同的故障域中。

CRUSH可以帮助我们快速定位问题,比如一个OSD宕掉了,我们可以检查这个OSD所在的机房、机柜、机架等信息。


OSD在CRUSH中的层级结构位置被称为"cursh location", 比如

```
root=default row=a rack=a2 chassis=a2a host=a2a1
```

key表示的是CRUSH type, 并不是所有的key都需要设置。




ceph-crush-location工具可以找出某个OSD在CRUSH map中的位置

```
# ceph-crush-location --id 0 --type osd
host=ceph-1 root=default
```











