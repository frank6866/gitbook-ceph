# 移除OSD
本文参考同事的文档

1.在crush中设置OSD weight为0，等待迁移完成。

```		
# ceph osd crush reweight osd.{osd-num} 0
```

2.从集群中设置OSD为out（如果OSD还处于in状态）

```
# ceph osd out {osd-num}
```

3.停止OSD进程（如果进程还在运行）：

```
# systemctl stop ceph-osd@{osd-num}
```

4.从CRUSH map中移除osd

```
# ceph osd crush remove osd.{osd-num}
```

5.删除osd认证key

```
# ceph auth del osd.{osd-num}
```

6.从集群中移除集群

```
# ceph osd rm {osd-num}
```




