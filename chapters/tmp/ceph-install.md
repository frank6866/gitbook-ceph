# install

* [部署ceph](chapters/ceph-deploy/ceph-install.md)

# 一、部署信息
## 软件环境

* 操作系统: CentOS7-1503
* ceph: 10.2.3.0


## 硬件环境

| ceph角色 | 主机名  | ip地址  | 配置 | 存储
| -------|---------|-----|---------------|--------------
| MON+OSD+ceph-deploy | ceph-1 | 10.10.10.75 | 2c4G | vda(16G，系统盘), vdb(50G，数据盘)
| MON+OSD | ceph-2 | 10.10.10.76 | 2c4G | vda(16G，系统盘), vdb(50G，数据盘)
| MON+OSD | ceph-3 | 10.10.10.77 | 2c4G | vda(16G，系统盘), vdb(50G，数据盘)


# 安装
## 安装ceph-deploy
> [root@ceph-1 ~]$ sudo yum install ceph-deploy

## MON
> [root@ceph-1 ~]# ceph-deploy new ceph-1 ceph-2 ceph-3

执行完成后，会在当前目录下生成一个名为**ceph.conf**的文件，如下：  

```
[global]
fsid = c712f08b-c001-4b1c-969d-abec240138f7
mon_initial_members = ceph-1, ceph-2, ceph-3
mon_host = 10.10.10.75,10.10.10.76,10.10.10.77
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
```


安装

> [root@ceph-1 ~]# ceph-deploy install ceph-1 ceph-2 ceph-3

> ceph-deploy mon create-initial


## OSD


```
[root@ceph-1 ~]# ceph-deploy osd create ceph-1:/dev/sdb
[root@ceph-1 ~]# ceph-deploy osd create ceph-2:/dev/sdb
[root@ceph-1 ~]# ceph-deploy osd create ceph-3:/dev/sdb
```

## 查看集群状态
> ceph -s





# ERROR
1. 错误1

```
[ceph-2][INFO  ] Running command: ssh -CT -o BatchMode=yes ceph-2
[ceph_deploy.new][WARNIN] could not connect via SSH
[ceph_deploy.new][INFO  ] will connect again with password prompt
Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
[ceph_deploy][ERROR ] RuntimeError: connecting to host: ceph-2 resulted in errors: HostNotFound ceph-2
```

将/etc/sudoers文件中的  

> Defaults    requiretty

注释掉



# ssh
* -C: compression压缩所有数据.
* -T: Disable pseudo-terminal allocation.





Host ceph-1
    Hostname ceph-1
    User centos
Host ceph-2
    Hostname ceph-2
    User centos
Host ceph-3
    Hostname ceph-3
    User centos







# offical
http://docs.ceph.com/ceph-deploy/docs/

```
[root@ceph-1 ~]# yum -y install epel-release
[root@ceph-1 ~]# yum -y install python-pip
[root@ceph-1 ~]# pip install ceph-deploy
```

> [root@ceph-1 ~]# vi /etc/ssh/sshd_config

```
...
PermitRootLogin yes
PermitEmptyPasswords yes
...
```


> [root@ceph-1 ~]# ssh-keygen -t rsa

















