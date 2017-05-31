# Ceph日志简介



Ceph的日志文件保存在/var/log/ceph路径下，包含以下类型的日志:  

* audit日志: 审计日志，文件名是ceph.audit.log
* 集群日志: 集群的信息，文件名是ceph.log
* mds日志: mds的日志，命名格式是ceph-mds.<hostname>.log
* mon日志: monitor进程的日志，命名格式是ceph-mon.<hostname>.log
* osd日志: osd进程的日志，命名格式是ceph-osd.<osd-id>.log








































