# ceph-deploy用法

## 创建一个新的集群

使用ceph-deploy new命令创建一个新的集群,参数为monitor结点的主机名列表

```
# ceph-deploy new ceph-1 ceph-2 ceph-3
```

该命令会在当前目录下创建如下文件:

```
# ls
ceph.conf  ceph-deploy-ceph.log  ceph.mon.keyring
```


ceph.conf文件如下:

```
# cat ceph.conf
[global]
fsid = 21b1a0c0-6e0d-4d02-b7fb-e5209283abfb
mon_initial_members = ceph-1, ceph-2, ceph-3
mon_host = 10.10.10.5,10.10.10.6,10.10.10.7
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
```

生成的kering文件如下:

```
# cat ceph.mon.keyring
[mon.]
key = abcdefg
caps mon = allow *
```

## 安装ceph相关的package

```
# ceph-deploy install ceph-1 ceph-2 ceph-3
```

如果目标结点上/etc/yum.repos.d/ceph.repo文件不存在,ceph-deploy install会在目标结点上创建/etc/yum.repos.d/ceph.repo文件。也可以自定义repo的地址:


```
# ceph-deploy install ceph-1 ceph-2 ceph-3  --repo-url http://mirrors.aliyun.com/ceph/rpm-jewel/el7/
```



## 初始化Monitor节点

```
# ceph-deploy mon create-initial
```


## 推送配置文件

```
# ceph-deploy admin ceph-client
```

该命令会将ceph-deploy结点上的ceph.conf文件和ceph.client.admin.keyring文件拷贝到ceph-client结点的/etc/ceph目录中。


## 查看磁盘列表
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

## 添加osd结点

```
# ceph-deploy osd create ceph-1:/dev/sdb
```






