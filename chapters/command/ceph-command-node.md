# 集群节点信息
使用ceph node命令可以查看集群的中所有结点的信息

```
# ceph node ls
{
    "mon": {
        "ceph-1": [
            0
        ],
        "ceph-2": [
            1
        ],
        "ceph-3": [
            2
        ]
    },
    "osd": {
        "ceph-1": [
            1,
            3,
            4,
            5
        ],
        "ceph-2": [
            6,
            7,
            8
        ],
        "ceph-3": [
            9,
            10,
            11
        ]
    },
    "mds": {}
}
```

mon表示monitor的结点信息，按照主机名输出，每个主机名后面的数组表示mon结点的编号；osd和mds也是。


也可以只查看部分信息，比如，只查看mon结点的信息:  

```
# ceph node ls mon
{
    "ceph-1": [
        0
    ],
    "ceph-2": [
        1
    ],
    "ceph-3": [
        2
    ]
}
```















