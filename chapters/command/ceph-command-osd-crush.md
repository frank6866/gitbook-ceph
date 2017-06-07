# crush管理

## 查看crush tree

```
# ceph osd crush tree
[
    {
        "id": -1,
        "name": "default",
        "type": "root",
        "type_id": 10,
        "items": [
            {
                "id": -2,
                "name": "ceph-1",
                "type": "host",
                "type_id": 1,
                "items": [
                    {
                        "id": 3,
                        "name": "osd.3",
                        "type": "osd",
                        "type_id": 0,
                        "crush_weight": 0.869095,
                        "depth": 2
                    },
                    {
                        "id": 4,
                        "name": "osd.4",
                        "type": "osd",
                        "type_id": 0,
                        "crush_weight": 0.869095,
                        "depth": 2
                    },
                    {
                        "id": 5,
                        "name": "osd.5",
                        "type": "osd",
                        "type_id": 0,
                        "crush_weight": 0.869095,
                        "depth": 2
                    },
                    {
                        "id": 1,
                        "name": "osd.1",
                        "type": "osd",
                        "type_id": 0,
                        "crush_weight": 0.908096,
                        "depth": 2
                    }
                ]
            },
......
        ]
    }
]
```

* 最顶层的是type为root的结点,其name为default。
* items数组中的是type为host的结点,其name一般是物理机的主机名
* items.items数组中是该host上osd结点的集合,osd的type名是osd




