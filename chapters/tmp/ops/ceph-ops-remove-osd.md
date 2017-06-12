# 移除OSD

移除OSD会导致数据迁移（此时集群性能下降），并且可能导致集群空间达到full ratio（集群无法写入数据），需要考虑上述因素。 由于out osd和crush remove操作均会导致集群数据迁移，因此在官方步骤中进行优化。

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

从集群中移除OSD后，在CRUSH map中该OSD会有一个“占位”。如果使用ceph osd create创建新的OSD时不指定OSD id，那么新OSD会使用旧的OSD id

7.(可选）如果磁盘被替换了，可以通过添加OSD进行添加操作。




