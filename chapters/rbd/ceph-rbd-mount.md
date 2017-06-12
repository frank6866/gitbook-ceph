# Linux挂载RBD
以H版为例，对于RBD，如果使用Ceph Kernel Client，CentOS6内核在2.6.32及以上，CentOS7内核在3.10及以上。  

对于需要挂载RBD的Linux系统，下面我们称为client,其主机名为rbd-client。

## 1.在client上安装ceph
client上需要安装ceph才能挂载RBD，我们可以通过ceph-deploy工具在client上安装ceph。

在ceph-deploy结点执行如下命令:

```
# ceph-deploy install rbd-client
```


## 2.将配置文件推送到client

在ceph-deploy结点执行如下命令:

```
# ceph-deploy admin rbd-client
```

## 3.创建rbd image

在client结点上执行如下命令:

```
# rbd create pool-frank6866/frank6866 --size 1024 --image-feature=layering
```

> 注意,创建rbd的时候,使用--image-feature=layering选项,不然在CentOS7上使用rbd map的时候会报"RBD image feature set mismatch"错误.


## 4.将rbd image映射到块设备

```
# rbd map pool-frank6866/frank6866
/dev/rbd0
```

```
# lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
......
rbd0   252:0    0     1G  0 disk
```

## 5.创建文件系统
```
# mkfs.ext4 /dev/rbd0
```

## 6.挂载rbd设备
```
# mkdir /mnt/rbd
# mount /dev/rbd0 /mnt/rbd/

# df -lTh
Filesystem     Type      Size  Used Avail Use% Mounted on
......
/dev/rbd0      ext4      976M  2.6M  907M   1% /mnt/rbd
```
