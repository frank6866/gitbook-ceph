# 添加osd

首先进行安装前[准备工作](https://frank6866.gitbooks.io/ceph/content/chapters/ceph-deploy/ceph-install-prepare.html)

## 1.安装ceph相关的package

```
# ceph-deploy install ceph-1 ceph-2 ceph-3
```

如果目标结点上/etc/yum.repos.d/ceph.repo文件不存在,ceph-deploy install会在目标结点上创建/etc/yum.repos.d/ceph.repo文件。也可以自定义repo的地址:


```
# ceph-deploy install ceph-1 ceph-2 ceph-3  --repo-url http://mirrors.aliyun.com/ceph/rpm-jewel/el7/
```


## 2. 查看磁盘列表
```
# ceph-deploy disk list ceph-1
......
[ceph_deploy.osd][DEBUG ] Listing disks on ceph-1...
[ceph-1][DEBUG ] find the location of an executable
[ceph-1][INFO  ] Running command: /usr/sbin/ceph-disk list
[ceph-1][DEBUG ] /dev/dm-0 other, xfs, mounted on /
[ceph-1][DEBUG ] /dev/dm-1 swap, swap
[ceph-1][DEBUG ] /dev/sda :
[ceph-1][DEBUG ]  /dev/sda2 other, LVM2_member
[ceph-1][DEBUG ]  /dev/sda1 other, xfs, mounted on /boot
[ceph-1][DEBUG ] /dev/sdb :
[ceph-1][DEBUG ]  /dev/sdb2 other
[ceph-1][DEBUG ]  /dev/sdb1 ceph data, active, cluster ceph, osd.0
[ceph-1][DEBUG ] /dev/sr0 other, unknown
[root@ceph-1 deploy]#
```

## 3.清除磁盘数据
如果磁盘上有数据,可以先清除

```
# ceph-deploy disk zap ceph-1:/dev/sdb
```

## 4.添加osd结点

```
# ceph-deploy osd create ceph-1:/dev/sdb
```


