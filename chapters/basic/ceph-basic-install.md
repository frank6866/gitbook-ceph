# install

# 一、部署信息
## 软件环境

* 操作系统: CentOS7-1503
* ceph: 10.2.3.0


## 硬件环境

| ceph角色 | 主机名  | ip地址  | 配置 | 存储
| -------|---------|-----|---------------|--------------
| MON+OSD+ceph-deploy | nl-cloud-dyc-ceph-1 | 10.12.10.75 | 2c4G | vda(16G，系统盘), vdb(50G，数据盘)
| MON+OSD | nl-cloud-dyc-ceph-2 | 10.12.10.76 | 2c4G | vda(16G，系统盘), vdb(50G，数据盘)
| MON+OSD | nl-cloud-dyc-ceph-3 | 10.12.10.77 | 2c4G | vda(16G，系统盘), vdb(50G，数据盘)



# 二、准备工作

```
1、安装与配置ntp，确保节点间时间同步（非常重要）。
2、创建ceph-deploy用户（目前均为ceph.eleme），允许免密码sudo权限。
3、建立ceph-deploy节点与新节点免密ssh连接。
4、节点网络准备：确认节点使用静态IP，防火墙关闭。
```


## DNS配置
**如果主机名已加入DNS解析，这步可以忽略。**  

这里使用在/etc/hosts中配置，在nl-cloud-dyc-ceph-1、nl-cloud-dyc-ceph-2和nl-cloud-dyc-ceph-3上的/etc/hosts文件中，均增加以下内容:  

```
10.12.10.75    nl-cloud-dyc-ceph-1
10.12.10.76    nl-cloud-dyc-ceph-2
10.12.10.77    nl-cloud-dyc-ceph-3
```


## 用户配置

**所有节点**


[all] useradd ceph
[all] passwd ceph



所有节点上都有centos用户，使用nl-cloud-dyc-ceph-1作为ceph deploy机器，在nl-cloud-dyc-ceph-1上创建centos用户的密钥对，并将公钥拷贝到nl-cloud-dyc-ceph-2和nl-cloud-dyc-ceph-3上。  

```
[root@nl-cloud-dyc-ceph-1 ~]$ ssh-keygen -t rsa
[root@nl-cloud-dyc-ceph-1 ~]$ ssh-copy-id root@nl-cloud-dyc-ceph-1
[root@nl-cloud-dyc-ceph-1 ~]$ ssh-copy-id root@nl-cloud-dyc-ceph-2
[root@nl-cloud-dyc-ceph-1 ~]$ ssh-copy-id root@nl-cloud-dyc-ceph-3
```

## 配置yum源
如果网速较慢可以搭建本地源。  

> sudo vi /etc/yum.repos.d/ceph.repo

```
[ceph-noarch]
name=Ceph noarch packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/noarch/
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
```

## ntp配置



# 安装
## 安装ceph-deploy
> [root@nl-cloud-dyc-ceph-1 ~]$ sudo yum install ceph-deploy

## MON
> [root@nl-cloud-dyc-ceph-1 ~]# ceph-deploy new nl-cloud-dyc-ceph-1 nl-cloud-dyc-ceph-2 nl-cloud-dyc-ceph-3

执行完成后，会在当前目录下生成一个名为**ceph.conf**的文件，如下：  

```
[global]
fsid = c712f08b-c001-4b1c-969d-abec240138f7
mon_initial_members = nl-cloud-dyc-ceph-1, nl-cloud-dyc-ceph-2, nl-cloud-dyc-ceph-3
mon_host = 10.12.10.75,10.12.10.76,10.12.10.77
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
```


安装

> [root@nl-cloud-dyc-ceph-1 ~]# ceph-deploy install nl-cloud-dyc-ceph-1 nl-cloud-dyc-ceph-2 nl-cloud-dyc-ceph-3

> ceph-deploy mon create-initial


## OSD


```
[root@nl-cloud-dyc-ceph-1 ~]# ceph-deploy osd create nl-cloud-dyc-ceph-1:/dev/sdb
[root@nl-cloud-dyc-ceph-1 ~]# ceph-deploy osd create nl-cloud-dyc-ceph-2:/dev/sdb
[root@nl-cloud-dyc-ceph-1 ~]# ceph-deploy osd create nl-cloud-dyc-ceph-3:/dev/sdb
```

## 查看集群状态
> ceph -s





# ERROR
1. 错误1

```
[nl-cloud-dyc-ceph-2][INFO  ] Running command: ssh -CT -o BatchMode=yes nl-cloud-dyc-ceph-2
[ceph_deploy.new][WARNIN] could not connect via SSH
[ceph_deploy.new][INFO  ] will connect again with password prompt
Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
[ceph_deploy][ERROR ] RuntimeError: connecting to host: nl-cloud-dyc-ceph-2 resulted in errors: HostNotFound nl-cloud-dyc-ceph-2
```

将/etc/sudoers文件中的  

> Defaults    requiretty

注释掉



# ssh
* -C: compression压缩所有数据.
* -T: Disable pseudo-terminal allocation.





Host nl-cloud-dyc-ceph-1
    Hostname nl-cloud-dyc-ceph-1
    User centos
Host nl-cloud-dyc-ceph-2
    Hostname nl-cloud-dyc-ceph-2
    User centos
Host nl-cloud-dyc-ceph-3
    Hostname nl-cloud-dyc-ceph-3
    User centos







# offical
http://docs.ceph.com/ceph-deploy/docs/

```
[root@nl-cloud-dyc-ceph-1 ~]# yum -y install epel-release
[root@nl-cloud-dyc-ceph-1 ~]# yum -y install python-pip
[root@nl-cloud-dyc-ceph-1 ~]# pip install ceph-deploy
```

> [root@nl-cloud-dyc-ceph-1 ~]# vi /etc/ssh/sshd_config

```
...
PermitRootLogin yes
PermitEmptyPasswords yes
...
```


> [root@nl-cloud-dyc-ceph-1 ~]# ssh-keygen -t rsa

















