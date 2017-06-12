
# Ceph运维笔记
主要内容:

* Ceph的安装、配置
* Ceph常用命令
* Ceph的性能测试和压力测试工具及方法
* Ceph的监控和日志管理
* Ceph性能指标及优化


简介
Ceph的定位,能提供什么服务


ceph常用命令




ceph安装


基本概念,



日志管理,监控管理


性能优化


常见异常


和glance集成
和cinder集成




----
原理搞一章,每个过程,发生了哪些事情

常见集群状态告警



filestore性能和bluestore对比


leveldb性能测试

RocksDB


./snoop分析海量文件读写比


## 架构图(其他)
![ceph-04](resources/ceph-arch-04.png)
----分割线
![ceph-05](resources/ceph-arch-05.png)
----分割线
![ceph-06](resources/ceph-arch-06.png)
----分割线
![ceph-07](resources/ceph-arch-07.png)






块设备操作规范：
以下以pool rbd为例
创建用户
ceph auth get-or-create client.dba1 mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=rbd'
创建块设备
rbd create -p rbd dba1 --size=50T --image-feature=layering

挂载：
mount -o rw,noatime,inode64,discard,noquota /dev/rbd0 /backupstorage/pgsql




-----
* [运维操作](chapters/ops/ceph-ops.md)
    * [添加OSD](chapters/ops/ceph-ops-add-osd.md)
    * [移除OSD](chapters/ops/ceph-ops-remove-osd.md)
    * [更换journal device](chapters/ops/ceph-ops-replace-journal-device.md)
    * [移除Ceph Monitor](chapters/ops/ceph-ops-remove-monitor.md)
    * [添加RGW](chapters/ops/ceph-ops-add-rgw.md)
    * [移除RGW](chapters/ops/ceph-ops-remove-rgw.md)
    * [添加monitor](chapters/ops/ceph-ops-add-monitor.md)











