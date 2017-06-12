# 星光Ceph部署

## 一、部署信息
### 主机环境


序号 | 主机名 | IP | 角色 | 硬件 
--- | --- | --- | --- | ---
1 | xg-cloud-cephrgw-1 | 10.0.55.102 | MON+RGW | 24C/32G/300G
2 | xg-cloud-cephrgw-2 | 10.0.45.37 | MON+RGW | 24C/32G/300G
3 | xg-cloud-cephrgw-3 | 10.0.43.176 | MON+RGW | 24C/32G/300G
4 | xg-cloud-ceph-1 | 10.0.41.64 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
5 | xg-cloud-ceph-2 | 10.0.41.88 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
6 | xg-cloud-ceph-3 | 10.0.41.147 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
7 | xg-cloud-ceph-4 | 10.0.41.77 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
8 | xg-cloud-ceph-5 | 10.0.45.61 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
9 | xg-cloud-ceph-6 | 10.0.45.91 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
10 | xg-cloud-ceph-7 | 10.0.45.107 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
11 | xg-cloud-ceph-8 | 10.0.45.136 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
12 | xg-cloud-ceph-9 | 10.0.45.137 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
13 | xg-cloud-ceph-10 | 10.0.45.167 | OSD | 32C/96G/300G+4T*10+ 2 * 480（SSD journal)
14 | xg-cloud-ceph-11 | 10.0.10.73 | OSD | 32C/128G/300G + 480SSD *4
15 | xg-cloud-ceph-12 | 10.0.22.93 | OSD | 32C/128G/300G + 480SSD *4
16 | xg-cloud-ceph-13 | 10.0.17.35 | OSD | 32C/128G/300G + 480SSD *4

备注：
xg-cloud-ceph-1-10为SATA存储+SSD journal存储池，xg-cloud-ceph-11-13为SSD存储池。

### 软件信息
使用ceph版本 10.2.3.0  
使用镜像地址：[链接](http://mirrors.aliyun.com/ceph/rpm-jewel/el7/)

### Ceph Deploy信息
部署节点xg-cloud-cephrgw-3
部署用户ceph.eleme

### Pool与pg规划信息
目前集群主要用途为提供对象存储，主要使用的pool为default.rgw.meta、default.rgw.buckets.index、default.rgw.buckets.data。其中default.rgw.buckets.data为数据存储pool，default.rgw.meta、default.rgw.buckets.index为元数据存储pool。

由于一次PUT请求时，会多次对default.rgw.buckets.index进行操作，为了提高索引和元数据性能，将default.rgw.buckets.index、default.rgw.meta pool设置到纯SSD组成的节点中。

pg信息：
数据存储部分由10个节点组成，每个节点4T\*10个OSD加两个SSD journal，总OSD数量为100个。考虑为未来可能会扩展到2倍左右的OSD数量，因此平均每个OSD pg数量介于200~300之间。Pool default.rgw.buckets.data pg数量设置为8192，平均每个OSD pg数量为8192\*3/100=245。
元数据存储部分由3个节点组成，每个节点480G*4个OSD，总OSD数量为12个。由于元数据量有限，增长速度较慢，当前规模可以满足未来增长需求，因此平均每个OSD pg数量介于100~200。Pool default.rgw.buckets.index、default.rgw.meta pg数量均设置为256，平均每个OSD pg数量为256*2*3/12=128。

### RAID 0与JBOD
目前多份网上测试报告中均显示JBOD会优于RAID 0，但是在使用的xg-cloud-ceph-1-10中，使用的华为服务器（RH2288)如果既存在JBOD和RAID，可能会导致重启时操作系统无法启动，因此在xg-cloud-ceph-1-10上全部磁盘使用RAID 0。
在xg-cloud-ceph-11-13上，服务器为DELL，重启未发现问题，这些服务器磁盘均使用JBOD。


## 二、部署环境准备
所有节点，添加ceph.eleme用户，添加sudo组

部署节点设置ssh/config：

```
Host xg-cloud-cephrgw-1
	Hostname xg-cloud-cephrgw-1
	User ceph.eleme
	Port 2014
Host xg-cloud-cephrgw-2
	Hostname xg-cloud-cephrgw-2
	User ceph.eleme
	Port 2014
Host xg-cloud-cephrgw-3
	Hostname xg-cloud-cephrgw-3
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-1
	Hostname xg-cloud-ceph-1
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-2
	Hostname xg-cloud-ceph-2
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-3
	Hostname xg-cloud-ceph-3
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-4
	Hostname xg-cloud-ceph-4
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-5
	Hostname xg-cloud-ceph-5
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-6
	Hostname xg-cloud-ceph-6
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-7
	Hostname xg-cloud-ceph-7
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-8
	Hostname xg-cloud-ceph-8
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-9
	Hostname xg-cloud-ceph-9
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-10
	Hostname xg-cloud-ceph-10
	User ceph.eleme
	Port 2014
Host xg-cloud-ceph-11
        Hostname xg-cloud-ceph-11
        User ceph.eleme
        Port 2014
Host xg-cloud-ceph-12
        Hostname xg-cloud-ceph-12
        User ceph.eleme
        Port 2014
Host xg-cloud-ceph-13
        Hostname xg-cloud-ceph-13
        User ceph.eleme
        Port 2014
```

添加公钥到被部署的节点上（略），从部署节点测试ssh连接可用性。

## 三、部署步骤
### 3.1 安装ceph-deploy节点
添加yum源

```
[dev-super@xg-cloud-cephrgw-3 ~]$ sudo vim /etc/yum.repos.d/ceph-noarch.repo
[ceph-noarch]
name=Ceph noarch packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-jewel/el7/noarch/
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
```
安装ceph-deploy
```
[dev-super@xg-cloud-cephrgw-3 ~]$ sudo yum install ceph-deploy
```

### 3.2 MON部署
创建集群

```
[ceph.eleme@xg-cloud-cephrgw-3 ceph20161114]$ ceph-deploy new xg-cloud-cephrgw-1 xg-cloud-cephrgw-2 xg-cloud-cephrgw-3
```
修改当前目录下ceph.conf，本次部署配置文件：
```
[global]
fsid = 2c0f6415-00de-4e4b-8eed-d36c83fc5d24
mon_initial_members = xg-cloud-cephrgw-1, xg-cloud-cephrgw-2, xg-cloud-cephrgw-3
mon_host = 10.0.55.102,10.0.45.37,10.0.43.176
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

mon_osd_full_ratio = 0.95
mon_osd_nearfull_ratio = 0.85
filestore_xattr_use_omap = true
osd_pool_default_size = 3
osd_pool_default_min_size = 0
osd_recovery_max_active = 1
osd_max_backfills = 1
osd_deep_scrub_interval = 3628800

[client.rgw.xg-cloud-cephrgw-3]
rgw_thread_pool_size = 100
rgw_num_rados_handles = 40 
rgw_override_bucket_index_max_shards = 100

[client.rgw.xg-cloud-cephrgw-2]
rgw_thread_pool_size = 100
rgw_num_rados_handles = 40 
rgw_override_bucket_index_max_shards = 100

[client.rgw.xg-cloud-cephrgw-1]
rgw_thread_pool_size = 100
rgw_num_rados_handles = 40 
rgw_override_bucket_index_max_shards = 100


[mon]
mon_osd_down_out_interval = 7200
mon_osd_adjust_down_out_interval = False

[osd]
#osd_journal_size = 81920
osd_journal_size = 20480
osd_scrub_begin_hour = 0
osd_scrub_end_hour = 7
filestore_op_threads = 32
filestore_split_multiple = 2
filestore_merge_threshold = 20
osd_max_scrubs = 1
osd_heartbeat_grace = 7
```

注意：不同角色ceph.conf可能有所不同。OSD节点config中不需要rgw配置。

安装一个节点ceph测试：

```
ceph-deploy install xg-cloud-cephrgw-1 --repo-url http://mirrors.aliyun.com/ceph/rpm-jewel/el7/
...
...
Error: Package: 1:ceph-9.2.0-0.el7.x86_64 (eleme)
           Requires: libcephfs1 = 1:9.2.0-0.el7
           Installing: 1:libcephfs1-0.80.7-0.4.el7.x86_64 (epel)
               libcephfs1 = 1:0.80.7-0.4.el7
Error: Package: 1:ceph-9.2.0-0.el7.x86_64 (eleme)
           Requires: ceph-selinux = 1:9.2.0-0.el7
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
```

发现eleme源中有较低版本的ceph，最终使用外部源。
所有节点均执行ceph-deploy install操作。

安装mon：

```
ceph-deploy mon create-initial
```
安装过程中报错，报错如下:

```
[xg-cloud-cephrgw-1][INFO  ] Running command: sudo ceph-mon --cluster ceph --mkfs -i xg-cloud-cephrgw-1 --keyring /var/lib/ceph/tmp/ceph-xg-cloud-cephrgw-1.
mon.keyring --setuser 167 --setgroup 167
[xg-cloud-cephrgw-1][DEBUG ] ceph-mon: mon.noname-a 10.0.55.102:6789/0 is local, renaming to mon.xg-cloud-cephrgw-1
[xg-cloud-cephrgw-1][DEBUG ] ceph-mon: set fsid to 89a4a16e-9bcb-40cf-b284-e84583ef2be8
[xg-cloud-cephrgw-1][WARNIN] *** Caught signal (Segmentation fault) **
[xg-cloud-cephrgw-1][WARNIN]  in thread 7ffd189b04c0 thread_name:ceph-mon
[xg-cloud-cephrgw-1][WARNIN]  ceph version 10.2.3 (ecc23778eb545d8dd55e2e4735b53cc93f92e65b)
[xg-cloud-cephrgw-1][WARNIN]  1: (()+0x50866a) [0x7ffd18ed166a]
[xg-cloud-cephrgw-1][WARNIN]  2: (()+0xf130) [0x7ffd17750130]
[xg-cloud-cephrgw-1][WARNIN] 2016-11-14 17:21:48.922151 7ffd189b04c0 -1 *** Caught signal (Segmentation fault) **
[xg-cloud-cephrgw-1][WARNIN]  in thread 7ffd189b04c0 thread_name:ceph-mon
[xg-cloud-cephrgw-1][WARNIN] 
[xg-cloud-cephrgw-1][WARNIN]  ceph version 10.2.3 (ecc23778eb545d8dd55e2e4735b53cc93f92e65b)
[xg-cloud-cephrgw-1][WARNIN]  1: (()+0x50866a) [0x7ffd18ed166a]
[xg-cloud-cephrgw-1][WARNIN]  2: (()+0xf130) [0x7ffd17750130]
[xg-cloud-cephrgw-1][WARNIN]  NOTE: a copy of the executable, or `objdump -rdS <executable>` is needed to interpret this.
[xg-cloud-cephrgw-1][WARNIN] 
[xg-cloud-cephrgw-1][WARNIN]      0> 2016-11-14 17:21:48.922151 7ffd189b04c0 -1 *** Caught signal (Segmentation fault) **
[xg-cloud-cephrgw-1][WARNIN]  in thread 7ffd189b04c0 thread_name:ceph-mon
[xg-cloud-cephrgw-1][WARNIN] 
[xg-cloud-cephrgw-1][WARNIN]  ceph version 10.2.3 (ecc23778eb545d8dd55e2e4735b53cc93f92e65b)
[xg-cloud-cephrgw-1][WARNIN]  1: (()+0x50866a) [0x7ffd18ed166a]
[xg-cloud-cephrgw-1][WARNIN]  2: (()+0xf130) [0x7ffd17750130]
[xg-cloud-cephrgw-1][WARNIN]  NOTE: a copy of the executable, or `objdump -rdS <executable>` is needed to interpret this.
[xg-cloud-cephrgw-1][WARNIN] 
[xg-cloud-cephrgw-1][ERROR ] RuntimeError: command returned non-zero exit status: -11
[ceph_deploy.mon][ERROR ] Failed to execute command: ceph-mon --cluster ceph --mkfs -i xg-cloud-cephrgw-1 --keyring /var/lib/ceph/tmp/ceph-xg-cloud-cephrgw$
1.mon.keyring --setuser 167 --setgroup 167
[ceph_deploy.mon][DEBUG ] detecting platform for host xg-cloud-cephrgw-2 ...
```

经过排查，为leveldb版本过低（1.7），添加epel源，升级至1.12后解决。

### 3.3 OSD部署

SATA+SSD journal池部署：
journal大小为80G（使用配置osd_journal_size = 81920）
对于每个主机，/dev/sdb、/dev/sdc均为SSD，其他磁盘为SATA盘。每个主机sdd-sdh使用sdb为journal，sdi-sdm使用sdc为journal。


```
#$1为hostname
for s in d e f g h
do 
ceph-deploy osd create $1:/dev/sd${s}:/dev/sdb
done

for s in i j k l m
do 
ceph-deploy osd create $1:/dev/sd${s}:/dev/sdc
done
```

SSD池部署：
journal大小为20G（使用配置osd_journal_size = 20480）
对于每个主机，/dev/sda-d均为480的SSD。

```
#$1为hostname
for s in a b c d
do 
ceph-deploy disk zap $1:/dev/sd$s 
ceph-deploy osd create $1:/dev/sd${s}
done
```


### 3.4 crushmap编辑
为了实现存储池和性能池分离，需要对crush map进行编辑。
导出当前crushmap:

```
ceph osd getcrushmap -o crushmaporign.map
```

转换crush map为文本：

```
crushtool -d crushmaporign.map -o crushmap.txt
```

当前crush map：

```
# begin crush map
tunable choose_local_tries 0
tunable choose_local_fallback_tries 0
tunable choose_total_tries 50
tunable chooseleaf_descend_once 1
tunable chooseleaf_vary_r 1
tunable straw_calc_version 1

# devices
device 0 osd.0
device 1 osd.1
device 2 osd.2
device 3 osd.3
device 4 osd.4
device 5 osd.5
device 6 osd.6
device 7 osd.7
device 8 osd.8
device 9 osd.9
device 10 osd.10
device 11 osd.11
device 12 osd.12
device 13 osd.13
device 14 osd.14
device 15 osd.15
device 16 osd.16
device 17 osd.17
device 18 osd.18
device 19 osd.19
device 20 osd.20
device 21 osd.21
device 22 osd.22
device 23 osd.23
device 24 osd.24
device 25 osd.25
device 26 osd.26
device 27 osd.27
device 28 osd.28
device 29 osd.29
device 30 osd.30
device 31 osd.31
device 32 osd.32
device 33 osd.33
device 34 osd.34
device 35 osd.35
device 36 osd.36
device 37 osd.37
device 38 osd.38
device 39 osd.39
device 40 osd.40
device 41 osd.41
device 42 osd.42
device 43 osd.43
device 44 osd.44
device 45 osd.45
device 46 osd.46
device 47 osd.47
device 48 osd.48
device 49 osd.49
device 50 osd.50
device 51 osd.51
device 52 osd.52
device 53 osd.53
device 54 osd.54
device 55 osd.55
device 56 osd.56
device 57 osd.57
device 58 osd.58
device 59 osd.59
device 60 osd.60
device 61 osd.61
device 62 osd.62
device 63 osd.63
device 64 osd.64
device 65 osd.65
device 66 osd.66
device 67 osd.67
device 68 osd.68
device 69 osd.69
device 70 osd.70
device 71 osd.71
device 72 osd.72
device 73 osd.73
device 74 osd.74
device 75 osd.75
device 76 osd.76
device 77 osd.77
device 78 osd.78
device 79 osd.79
device 80 osd.80
device 81 osd.81
device 82 osd.82
device 83 osd.83
device 84 osd.84
device 85 osd.85
device 86 osd.86
device 87 osd.87
device 88 osd.88
device 89 osd.89
device 90 osd.90
device 91 osd.91
device 92 osd.92
device 93 osd.93
device 94 osd.94
device 95 osd.95
device 96 osd.96
device 97 osd.97
device 98 osd.98
device 99 osd.99
device 100 osd.100
device 101 osd.101
device 102 osd.102
device 103 osd.103
device 104 osd.104
device 105 osd.105
device 106 osd.106
device 107 osd.107
device 108 osd.108
device 109 osd.109
device 110 osd.110
device 111 osd.111
device 112 osd.112
device 113 osd.113

# types
type 0 osd
type 1 host
type 2 chassis
type 3 rack
type 4 row
type 5 pdu
type 6 pod
type 7 room
type 8 datacenter
type 9 region
type 10 root

# buckets
host xg-cloud-ceph-1 {
        id -2           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.1 weight 3.636
        item osd.2 weight 3.636
        item osd.3 weight 3.636
        item osd.4 weight 3.636
        item osd.5 weight 3.636
        item osd.6 weight 3.636
        item osd.7 weight 3.636
        item osd.8 weight 3.636
        item osd.9 weight 3.636
        item osd.0 weight 3.636
}
host xg-cloud-ceph-2 {
        id -3           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.10 weight 3.636
        item osd.11 weight 3.636
        item osd.12 weight 3.636
        item osd.13 weight 3.636
        item osd.14 weight 3.636
        item osd.15 weight 3.636
        item osd.16 weight 3.636
        item osd.17 weight 3.636
        item osd.18 weight 3.636
        item osd.19 weight 3.636
}
host xg-cloud-ceph-3 {
        id -4           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.20 weight 3.636
        item osd.21 weight 3.636
        item osd.22 weight 3.636
        item osd.23 weight 3.636
        item osd.24 weight 3.636
        item osd.25 weight 3.636
        item osd.26 weight 3.636
        item osd.27 weight 3.636
        item osd.28 weight 3.636
        item osd.29 weight 3.636
}
host xg-cloud-ceph-4 {
        id -5           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.30 weight 3.636
        item osd.31 weight 3.636
        item osd.32 weight 3.636
        item osd.33 weight 3.636
        item osd.34 weight 3.636
        item osd.35 weight 3.636
        item osd.36 weight 3.636
        item osd.37 weight 3.636
        item osd.38 weight 3.636
        item osd.39 weight 3.636
}
host xg-cloud-ceph-5 {
        id -6           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.40 weight 3.636
        item osd.41 weight 3.636
        item osd.42 weight 3.636
        item osd.43 weight 3.636
        item osd.44 weight 3.636
        item osd.45 weight 3.636
        item osd.46 weight 3.636
        item osd.47 weight 3.636
        item osd.48 weight 3.636
        item osd.49 weight 3.636
}
host xg-cloud-ceph-6 {
        id -7           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.50 weight 3.636
        item osd.51 weight 3.636
        item osd.52 weight 3.636
        item osd.53 weight 3.636
        item osd.54 weight 3.636
        item osd.55 weight 3.636
        item osd.56 weight 3.636
        item osd.57 weight 3.636
        item osd.58 weight 3.636
        item osd.59 weight 3.636
}
host xg-cloud-ceph-7 {
        id -8           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.60 weight 3.636
        item osd.61 weight 3.636
        item osd.62 weight 3.636
        item osd.63 weight 3.636
        item osd.64 weight 3.636
        item osd.65 weight 3.636
        item osd.66 weight 3.636
        item osd.67 weight 3.636
        item osd.68 weight 3.636
        item osd.69 weight 3.636
}
host xg-cloud-ceph-8 {
        id -9           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.70 weight 3.636
        item osd.71 weight 3.636
        item osd.72 weight 3.636
        item osd.73 weight 3.636
        item osd.74 weight 3.636
        item osd.75 weight 3.636
        item osd.76 weight 3.636
        item osd.77 weight 3.636
        item osd.78 weight 3.636
        item osd.79 weight 3.636
}
host xg-cloud-ceph-9 {
        id -10          # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.80 weight 3.636
        item osd.81 weight 3.636
        item osd.82 weight 3.636
        item osd.83 weight 3.636
        item osd.84 weight 3.636
        item osd.85 weight 3.636
        item osd.86 weight 3.636
        item osd.87 weight 3.636
        item osd.88 weight 3.636
        item osd.89 weight 3.636
}
host xg-cloud-ceph-10 {
        id -11          # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.90 weight 3.636
        item osd.91 weight 3.636
        item osd.92 weight 3.636
        item osd.93 weight 3.636
        item osd.94 weight 3.636
        item osd.95 weight 3.636
        item osd.96 weight 3.636
        item osd.97 weight 3.636
        item osd.98 weight 3.636
        item osd.99 weight 3.636
}
host xg-cloud-ceph-11 {
        id -12          # do not change unnecessarily
        # weight 1.668
        alg straw
        hash 0  # rjenkins1
        item osd.102 weight 0.417
        item osd.103 weight 0.417
        item osd.104 weight 0.417
        item osd.105 weight 0.417
}
host xg-cloud-ceph-12 {
        id -13          # do not change unnecessarily
        # weight 1.668
        alg straw
        hash 0  # rjenkins1
        item osd.106 weight 0.417
        item osd.107 weight 0.417
        item osd.108 weight 0.417
        item osd.109 weight 0.417
}
host xg-cloud-ceph-13 {
        id -14          # do not change unnecessarily
        # weight 1.668
        alg straw
        hash 0  # rjenkins1
        item osd.110 weight 0.417
        item osd.111 weight 0.417
        item osd.112 weight 0.417
        item osd.113 weight 0.417
}
root default {
        id -1           # do not change unnecessarily
        # weight 368.623
        alg straw
        hash 0  # rjenkins1
        item xg-cloud-ceph-1 weight 36.362
        item xg-cloud-ceph-2 weight 36.362
        item xg-cloud-ceph-3 weight 36.362
        item xg-cloud-ceph-4 weight 36.362
        item xg-cloud-ceph-5 weight 36.362
        item xg-cloud-ceph-6 weight 36.362
        item xg-cloud-ceph-7 weight 36.362
        item xg-cloud-ceph-8 weight 36.362
        item xg-cloud-ceph-9 weight 36.362
        item xg-cloud-ceph-10 weight 36.362
        item xg-cloud-ceph-11 weight 1.668
        item xg-cloud-ceph-12 weight 1.668
        item xg-cloud-ceph-13 weight 1.668
}

# rules
rule replicated_ruleset {
        ruleset 0
        type replicated
        min_size 1
        max_size 10
        step take default
        step chooseleaf firstn 0 type host
        step emit
}

# end crush map
```

编辑后：

```
# begin crush map
tunable choose_local_tries 0
tunable choose_local_fallback_tries 0
tunable choose_total_tries 50
tunable chooseleaf_descend_once 1
tunable chooseleaf_vary_r 1
tunable straw_calc_version 1

# devices
device 0 osd.0
device 1 osd.1
device 2 osd.2
device 3 osd.3
device 4 osd.4
device 5 osd.5
device 6 osd.6
device 7 osd.7
device 8 osd.8
device 9 osd.9
device 10 osd.10
device 11 osd.11
device 12 osd.12
device 13 osd.13
device 14 osd.14
device 15 osd.15
device 16 osd.16
device 17 osd.17
device 18 osd.18
device 19 osd.19
device 20 osd.20
device 21 osd.21
device 22 osd.22
device 23 osd.23
device 24 osd.24
device 25 osd.25
device 26 osd.26
device 27 osd.27
device 28 osd.28
device 29 osd.29
device 30 osd.30
device 31 osd.31
device 32 osd.32
device 33 osd.33
device 34 osd.34
device 35 osd.35
device 36 osd.36
device 37 osd.37
device 38 osd.38
device 39 osd.39
device 40 osd.40
device 41 osd.41
device 42 osd.42
device 43 osd.43
device 44 osd.44
device 45 osd.45
device 46 osd.46
device 47 osd.47
device 48 osd.48
device 49 osd.49
device 50 osd.50
device 51 osd.51
device 52 osd.52
device 53 osd.53
device 54 osd.54
device 55 osd.55
device 56 osd.56
device 57 osd.57
device 58 osd.58
device 59 osd.59
device 60 osd.60
device 61 osd.61
device 62 osd.62
device 63 osd.63
device 64 osd.64
device 65 osd.65
device 66 osd.66
device 67 osd.67
device 68 osd.68
device 69 osd.69
device 70 osd.70
device 71 osd.71
device 72 osd.72
device 73 osd.73
device 74 osd.74
device 75 osd.75
device 76 osd.76
device 77 osd.77
device 78 osd.78
device 79 osd.79
device 80 osd.80
device 81 osd.81
device 82 osd.82
device 83 osd.83
device 84 osd.84
device 85 osd.85
device 86 osd.86
device 87 osd.87
device 88 osd.88
device 89 osd.89
device 90 osd.90
device 91 osd.91
device 92 osd.92
device 93 osd.93
device 94 osd.94
device 95 osd.95
device 96 osd.96
device 97 osd.97
device 98 osd.98
device 99 osd.99
device 100 device100
device 101 device101
device 102 osd.102
device 103 osd.103
device 104 osd.104
device 105 osd.105
device 106 osd.106
device 107 osd.107
device 108 osd.108
device 109 osd.109
device 110 osd.110
device 111 osd.111
device 112 osd.112
device 113 osd.113

# types
type 0 osd
type 1 host
type 2 chassis
type 3 rack
type 4 row
type 5 pdu
type 6 pod
type 7 room
type 8 datacenter
type 9 region
type 10 root

# buckets
host xg-cloud-ceph-1 {
        id -2           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.1 weight 3.636
        item osd.2 weight 3.636
        item osd.3 weight 3.636
        item osd.4 weight 3.636
        item osd.5 weight 3.636
        item osd.6 weight 3.636
        item osd.7 weight 3.636
        item osd.8 weight 3.636
        item osd.9 weight 3.636
        item osd.0 weight 3.636
}
host xg-cloud-ceph-2 {
        id -3           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.10 weight 3.636
        item osd.11 weight 3.636
        item osd.12 weight 3.636
        item osd.13 weight 3.636
        item osd.14 weight 3.636
        item osd.15 weight 3.636
        item osd.16 weight 3.636
        item osd.17 weight 3.636
        item osd.18 weight 3.636
        item osd.19 weight 3.636
}
host xg-cloud-ceph-3 {
        id -4           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.20 weight 3.636
        item osd.21 weight 3.636
        item osd.22 weight 3.636
        item osd.23 weight 3.636
        item osd.24 weight 3.636
        item osd.25 weight 3.636
        item osd.26 weight 3.636
        item osd.27 weight 3.636
        item osd.28 weight 3.636
        item osd.29 weight 3.636
}
host xg-cloud-ceph-4 {
        id -5           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.30 weight 3.636
        item osd.31 weight 3.636
        item osd.32 weight 3.636
        item osd.33 weight 3.636
        item osd.34 weight 3.636
        item osd.35 weight 3.636
        item osd.36 weight 3.636
        item osd.37 weight 3.636
        item osd.38 weight 3.636
        item osd.39 weight 3.636
}
host xg-cloud-ceph-5 {
        id -6           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.40 weight 3.636
        item osd.41 weight 3.636
        item osd.42 weight 3.636
        item osd.43 weight 3.636
        item osd.44 weight 3.636
        item osd.45 weight 3.636
        item osd.46 weight 3.636
        item osd.47 weight 3.636
        item osd.48 weight 3.636
        item osd.49 weight 3.636
}
host xg-cloud-ceph-6 {
        id -7           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.50 weight 3.636
        item osd.51 weight 3.636
        item osd.52 weight 3.636
        item osd.53 weight 3.636
        item osd.54 weight 3.636
        item osd.55 weight 3.636
        item osd.56 weight 3.636
        item osd.57 weight 3.636
        item osd.58 weight 3.636
        item osd.59 weight 3.636
}
host xg-cloud-ceph-7 {
        id -8           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.60 weight 3.636
        item osd.61 weight 3.636
        item osd.62 weight 3.636
        item osd.63 weight 3.636
        item osd.64 weight 3.636
        item osd.65 weight 3.636
        item osd.66 weight 3.636
        item osd.67 weight 3.636
        item osd.68 weight 3.636
        item osd.69 weight 3.636
}
host xg-cloud-ceph-8 {
        id -9           # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.70 weight 3.636
        item osd.71 weight 3.636
        item osd.72 weight 3.636
        item osd.73 weight 3.636
        item osd.74 weight 3.636
        item osd.75 weight 3.636
        item osd.76 weight 3.636
        item osd.77 weight 3.636
        item osd.78 weight 3.636
        item osd.79 weight 3.636
}
host xg-cloud-ceph-9 {
        id -10          # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.80 weight 3.636
        item osd.81 weight 3.636
        item osd.82 weight 3.636
        item osd.83 weight 3.636
        item osd.84 weight 3.636
        item osd.85 weight 3.636
        item osd.86 weight 3.636
        item osd.87 weight 3.636
        item osd.88 weight 3.636
        item osd.89 weight 3.636
}
host xg-cloud-ceph-10 {
        id -11          # do not change unnecessarily
        # weight 36.362
        alg straw
        hash 0  # rjenkins1
        item osd.90 weight 3.636
        item osd.91 weight 3.636
        item osd.92 weight 3.636
        item osd.93 weight 3.636
        item osd.94 weight 3.636
        item osd.95 weight 3.636
        item osd.96 weight 3.636
        item osd.97 weight 3.636
        item osd.98 weight 3.636
        item osd.99 weight 3.636
}
host xg-cloud-ceph-11 {
        id -12          # do not change unnecessarily
        # weight 1.668
        alg straw
        hash 0  # rjenkins1
        item osd.102 weight 0.417
        item osd.103 weight 0.417
        item osd.104 weight 0.417
        item osd.105 weight 0.417
}
host xg-cloud-ceph-12 {
        id -13          # do not change unnecessarily
        # weight 1.668
        alg straw
        hash 0  # rjenkins1
        item osd.106 weight 0.417
        item osd.107 weight 0.417
        item osd.108 weight 0.417
        item osd.109 weight 0.417
}
host xg-cloud-ceph-13 {
        id -14          # do not change unnecessarily
        # weight 1.668
        alg straw
        hash 0  # rjenkins1
        item osd.110 weight 0.417
        item osd.111 weight 0.417
        item osd.112 weight 0.417
        item osd.113 weight 0.417
}
root default {
        id -1           # do not change unnecessarily
        # weight 368.623
        alg straw
        hash 0  # rjenkins1
        item xg-cloud-ceph-1 weight 36.362
        item xg-cloud-ceph-2 weight 36.362
        item xg-cloud-ceph-3 weight 36.362
        item xg-cloud-ceph-4 weight 36.362
        item xg-cloud-ceph-5 weight 36.362
        item xg-cloud-ceph-6 weight 36.362
        item xg-cloud-ceph-7 weight 36.362
        item xg-cloud-ceph-8 weight 36.362
        item xg-cloud-ceph-9 weight 36.362
        item xg-cloud-ceph-10 weight 36.362
}
root ssd {
        id -15           # do not change unnecessarily
        # weight 368.623
        alg straw
        hash 0  # rjenkins1
        item xg-cloud-ceph-11 weight 1.668
        item xg-cloud-ceph-12 weight 1.668
        item xg-cloud-ceph-13 weight 1.668
}

# rules
rule replicated_ruleset {
        ruleset 0
        type replicated
        min_size 1
        max_size 10
        step take default
        step chooseleaf firstn 0 type host
        step emit
}
rule ssd_ruleset {
        ruleset 1
        type replicated
        min_size 1
        max_size 10
        step take ssd
        step chooseleaf firstn 0 type host
        step emit
}

# end crush map
```

新crush map重新编译：

```
crushtool -c crushmap.txt -o crushmapnew.map
```

导入集群：

```
ceph osd setcrushmap -i crushmapnew.map
```

验证配置(osd tree中有两个root）：

```
# ceph osd tree
ID  WEIGHT    TYPE NAME                 UP/DOWN REWEIGHT PRIMARY-AFFINITY 
-15   5.00400 root ssd                                                    
-12   1.66800     host xg-cloud-ceph-11                                   
102   0.41699         osd.102                up  1.00000          1.00000 
103   0.41699         osd.103                up  1.00000          1.00000 
104   0.41699         osd.104                up  1.00000          1.00000 
105   0.41699         osd.105                up  1.00000          1.00000 
-13   1.66800     host xg-cloud-ceph-12                                   
106   0.41699         osd.106                up  1.00000          1.00000 
107   0.41699         osd.107                up  1.00000          1.00000 
108   0.41699         osd.108                up  1.00000          1.00000 
109   0.41699         osd.109                up  1.00000          1.00000 
-14   1.66800     host xg-cloud-ceph-13                                   
110   0.41699         osd.110                up  1.00000          1.00000 
111   0.41699         osd.111                up  1.00000          1.00000 
112   0.41699         osd.112                up  1.00000          1.00000 
113   0.41699         osd.113                up  1.00000          1.00000 
 -1 363.62000 root default                                                
 -2  36.36200     host xg-cloud-ceph-1                                    
  1   3.63599         osd.1                  up  1.00000          1.00000 
  2   3.63599         osd.2                  up  1.00000          1.00000 
  3   3.63599         osd.3                  up  1.00000          1.00000 
  4   3.63599         osd.4                  up  1.00000          1.00000 
  5   3.63599         osd.5                  up  1.00000          1.00000 
  6   3.63599         osd.6                  up  1.00000          1.00000 
  7   3.63599         osd.7                  up  1.00000          1.00000 
  8   3.63599         osd.8                  up  1.00000          1.00000 
  9   3.63599         osd.9                  up  1.00000          1.00000 
  0   3.63599         osd.0                  up  1.00000          1.00000 
 -3  36.36200     host xg-cloud-ceph-2                                    
 10   3.63599         osd.10                 up  1.00000          1.00000 
 11   3.63599         osd.11                 up  1.00000          1.00000 
 12   3.63599         osd.12                 up  1.00000          1.00000 
 13   3.63599         osd.13                 up  1.00000          1.00000 
 14   3.63599         osd.14                 up  1.00000          1.00000 
 15   3.63599         osd.15                 up  1.00000          1.00000 
 16   3.63599         osd.16                 up  1.00000          1.00000 
 17   3.63599         osd.17                 up  1.00000          1.00000 
 18   3.63599         osd.18                 up  1.00000          1.00000 
 19   3.63599         osd.19                 up  1.00000          1.00000 
 -4  36.36200     host xg-cloud-ceph-3                                    
 20   3.63599         osd.20                 up  1.00000          1.00000 
 21   3.63599         osd.21                 up  1.00000          1.00000 
 22   3.63599         osd.22                 up  1.00000          1.00000 
 23   3.63599         osd.23                 up  1.00000          1.00000 
 24   3.63599         osd.24                 up  1.00000          1.00000 
 25   3.63599         osd.25                 up  1.00000          1.00000 
 26   3.63599         osd.26                 up  1.00000          1.00000 
 27   3.63599         osd.27                 up  1.00000          1.00000 
 28   3.63599         osd.28                 up  1.00000          1.00000 
 29   3.63599         osd.29                 up  1.00000          1.00000 
 -5  36.36200     host xg-cloud-ceph-4                                    
 30   3.63599         osd.30                 up  1.00000          1.00000 
 31   3.63599         osd.31                 up  1.00000          1.00000 
 32   3.63599         osd.32                 up  1.00000          1.00000 
 33   3.63599         osd.33                 up  1.00000          1.00000 
 34   3.63599         osd.34                 up  1.00000          1.00000 
 35   3.63599         osd.35                 up  1.00000          1.00000 
 36   3.63599         osd.36                 up  1.00000          1.00000 
 37   3.63599         osd.37                 up  1.00000          1.00000 
 38   3.63599         osd.38                 up  1.00000          1.00000 
 39   3.63599         osd.39                 up  1.00000          1.00000 
 -6  36.36200     host xg-cloud-ceph-5                                    
 40   3.63599         osd.40                 up  1.00000          1.00000 
 41   3.63599         osd.41                 up  1.00000          1.00000 
 42   3.63599         osd.42                 up  1.00000          1.00000 
 43   3.63599         osd.43                 up  1.00000          1.00000 
 44   3.63599         osd.44                 up  1.00000          1.00000 
 45   3.63599         osd.45                 up  1.00000          1.00000 
 46   3.63599         osd.46                 up  1.00000          1.00000 
 47   3.63599         osd.47                 up  1.00000          1.00000 
 48   3.63599         osd.48                 up  1.00000          1.00000 
 49   3.63599         osd.49                 up  1.00000          1.00000 
 -7  36.36200     host xg-cloud-ceph-6                                    
 50   3.63599         osd.50                 up  1.00000          1.00000 
 51   3.63599         osd.51                 up  1.00000          1.00000 
 52   3.63599         osd.52                 up  1.00000          1.00000 
 53   3.63599         osd.53                 up  1.00000          1.00000 
 54   3.63599         osd.54                 up  1.00000          1.00000 
 55   3.63599         osd.55                 up  1.00000          1.00000 
 56   3.63599         osd.56                 up  1.00000          1.00000 
 57   3.63599         osd.57                 up  1.00000          1.00000 
 58   3.63599         osd.58                 up  1.00000          1.00000 
 59   3.63599         osd.59                 up  1.00000          1.00000 
 -8  36.36200     host xg-cloud-ceph-7                                    
 60   3.63599         osd.60                 up  1.00000          1.00000 
 61   3.63599         osd.61                 up  1.00000          1.00000 
 62   3.63599         osd.62                 up  1.00000          1.00000 
 63   3.63599         osd.63                 up  1.00000          1.00000 
 64   3.63599         osd.64                 up  1.00000          1.00000 
 65   3.63599         osd.65                 up  1.00000          1.00000 
 66   3.63599         osd.66                 up  1.00000          1.00000 
 67   3.63599         osd.67                 up  1.00000          1.00000 
 68   3.63599         osd.68                 up  1.00000          1.00000 
 69   3.63599         osd.69                 up  1.00000          1.00000 
 -9  36.36200     host xg-cloud-ceph-8                                    
 70   3.63599         osd.70                 up  1.00000          1.00000 
 71   3.63599         osd.71                 up  1.00000          1.00000 
 72   3.63599         osd.72                 up  1.00000          1.00000 
 73   3.63599         osd.73                 up  1.00000          1.00000 
 74   3.63599         osd.74                 up  1.00000          1.00000 
 75   3.63599         osd.75                 up  1.00000          1.00000 
 76   3.63599         osd.76                 up  1.00000          1.00000 
 77   3.63599         osd.77                 up  1.00000          1.00000 
 78   3.63599         osd.78                 up  1.00000          1.00000 
 79   3.63599         osd.79                 up  1.00000          1.00000 
-10  36.36200     host xg-cloud-ceph-9                                    
 80   3.63599         osd.80                 up  1.00000          1.00000 
 81   3.63599         osd.81                 up  1.00000          1.00000 
 82   3.63599         osd.82                 up  1.00000          1.00000 
 83   3.63599         osd.83                 up  1.00000          1.00000 
 84   3.63599         osd.84                 up  1.00000          1.00000 
 85   3.63599         osd.85                 up  1.00000          1.00000 
 86   3.63599         osd.86                 up  1.00000          1.00000 
 87   3.63599         osd.87                 up  1.00000          1.00000 
 88   3.63599         osd.88                 up  1.00000          1.00000 
 89   3.63599         osd.89                 up  1.00000          1.00000 
-11  36.36200     host xg-cloud-ceph-10                                   
 90   3.63599         osd.90                 up  1.00000          1.00000 
 91   3.63599         osd.91                 up  1.00000          1.00000 
 92   3.63599         osd.92                 up  1.00000          1.00000 
 93   3.63599         osd.93                 up  1.00000          1.00000 
 94   3.63599         osd.94                 up  1.00000          1.00000 
 95   3.63599         osd.95                 up  1.00000          1.00000 
 96   3.63599         osd.96                 up  1.00000          1.00000 
 97   3.63599         osd.97                 up  1.00000          1.00000 
 98   3.63599         osd.98                 up  1.00000          1.00000 
 99   3.63599         osd.99                 up  1.00000          1.00000 
```

### 3.5 RGW部署
安装rgw（默认已经安装）

```
ceph-deploy install --rgw xg-cloud-cephrgw-1 xg-cloud-cephrgw-2 xg-cloud-cephrgw-3 --repo-url http://mirrors.aliyun.com/ceph/rpm-jewel/el7/

```

部署RGW：

```
$ ceph-deploy rgw create xg-cloud-cephrgw-1 xg-cloud-cephrgw-2 xg-cloud-cephrgw-3
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/ceph.eleme/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (1.5.36): /bin/ceph-deploy rgw create xg-cloud-cephrgw-1 xg-cloud-cephrgw-2 xg-cloud-cephrgw-3
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  rgw                           : [('xg-cloud-cephrgw-1', 'rgw.xg-cloud-cephrgw-1'), ('xg-cloud-cephrgw-2', 'rgw.xg-cloud-cephrgw-2'), ('xg-cloud-cephrgw-3', 'rgw.xg-cloud-cephrgw-3')]
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  subcommand                    : create
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0xddf128>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  func                          : <function rgw at 0xd63758>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.rgw][DEBUG ] Deploying rgw, cluster ceph hosts xg-cloud-cephrgw-1:rgw.xg-cloud-cephrgw-1 xg-cloud-cephrgw-2:rgw.xg-cloud-cephrgw-2 xg-cloud-cephrgw-3:rgw.xg-cloud-cephrgw-3
[xg-cloud-cephrgw-1][DEBUG ] connection detected need for sudo
[xg-cloud-cephrgw-1][DEBUG ] connected to host: xg-cloud-cephrgw-1 
[xg-cloud-cephrgw-1][DEBUG ] detect platform information from remote host
[xg-cloud-cephrgw-1][DEBUG ] detect machine type
[ceph_deploy.rgw][INFO  ] Distro info: CentOS Linux 7.1.1503 Core
[ceph_deploy.rgw][DEBUG ] remote host will use systemd
[ceph_deploy.rgw][DEBUG ] deploying rgw bootstrap to xg-cloud-cephrgw-1
[xg-cloud-cephrgw-1][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[xg-cloud-cephrgw-1][DEBUG ] create path recursively if it doesn't exist
[xg-cloud-cephrgw-1][INFO  ] Running command: sudo ceph --cluster ceph --name client.bootstrap-rgw --keyring /var/lib/ceph/bootstrap-rgw/ceph.keyring auth get-or-create client.rgw.xg-cloud-cephrgw-1 osd allow rwx mon allow rw -o /var/lib/ceph/radosgw/ceph-rgw.xg-cloud-cephrgw-1/keyring
[xg-cloud-cephrgw-1][INFO  ] Running command: sudo systemctl enable ceph-radosgw@rgw.xg-cloud-cephrgw-1
[xg-cloud-cephrgw-1][WARNIN] Failed to issue method call: No such file or directory
[xg-cloud-cephrgw-1][ERROR ] RuntimeError: command returned non-zero exit status: 1
[ceph_deploy.rgw][ERROR ] Failed to execute command: systemctl enable ceph-radosgw@rgw.xg-cloud-cephrgw-1
[xg-cloud-cephrgw-2][DEBUG ] connection detected need for sudo
[xg-cloud-cephrgw-2][DEBUG ] connected to host: xg-cloud-cephrgw-2 
[xg-cloud-cephrgw-2][DEBUG ] detect platform information from remote host
[xg-cloud-cephrgw-2][DEBUG ] detect machine type
[ceph_deploy.rgw][INFO  ] Distro info: CentOS Linux 7.1.1503 Core
[ceph_deploy.rgw][DEBUG ] remote host will use systemd
[ceph_deploy.rgw][DEBUG ] deploying rgw bootstrap to xg-cloud-cephrgw-2
[xg-cloud-cephrgw-2][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[xg-cloud-cephrgw-2][DEBUG ] create path recursively if it doesn't exist
[xg-cloud-cephrgw-2][INFO  ] Running command: sudo ceph --cluster ceph --name client.bootstrap-rgw --keyring /var/lib/ceph/bootstrap-rgw/ceph.keyring auth get-or-create client.rgw.xg-cloud-cephrgw-2 osd allow rwx mon allow rw -o /var/lib/ceph/radosgw/ceph-rgw.xg-cloud-cephrgw-2/keyring
[xg-cloud-cephrgw-2][INFO  ] Running command: sudo systemctl enable ceph-radosgw@rgw.xg-cloud-cephrgw-2
[xg-cloud-cephrgw-2][WARNIN] Failed to issue method call: No such file or directory
[xg-cloud-cephrgw-2][ERROR ] RuntimeError: command returned non-zero exit status: 1
[ceph_deploy.rgw][ERROR ] Failed to execute command: systemctl enable ceph-radosgw@rgw.xg-cloud-cephrgw-2
[xg-cloud-cephrgw-3][DEBUG ] connection detected need for sudo
[xg-cloud-cephrgw-3][DEBUG ] connected to host: xg-cloud-cephrgw-3 
[xg-cloud-cephrgw-3][DEBUG ] detect platform information from remote host
[xg-cloud-cephrgw-3][DEBUG ] detect machine type
[ceph_deploy.rgw][INFO  ] Distro info: CentOS Linux 7.1.1503 Core
[ceph_deploy.rgw][DEBUG ] remote host will use systemd
[ceph_deploy.rgw][DEBUG ] deploying rgw bootstrap to xg-cloud-cephrgw-3
[xg-cloud-cephrgw-3][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[xg-cloud-cephrgw-3][DEBUG ] create path recursively if it doesn't exist
[xg-cloud-cephrgw-3][INFO  ] Running command: sudo ceph --cluster ceph --name client.bootstrap-rgw --keyring /var/lib/ceph/bootstrap-rgw/ceph.keyring auth get-or-create client.rgw.xg-cloud-cephrgw-3 osd allow rwx mon allow rw -o /var/lib/ceph/radosgw/ceph-rgw.xg-cloud-cephrgw-3/keyring
[xg-cloud-cephrgw-3][INFO  ] Running command: sudo systemctl enable ceph-radosgw@rgw.xg-cloud-cephrgw-3
[xg-cloud-cephrgw-3][WARNIN] Failed to issue method call: No such file or directory
[xg-cloud-cephrgw-3][ERROR ] RuntimeError: command returned non-zero exit status: 1
[ceph_deploy.rgw][ERROR ] Failed to execute command: systemctl enable ceph-radosgw@rgw.xg-cloud-cephrgw-3
[ceph_deploy][ERROR ] GenericError: Failed to create 3 RGWs
```

解决，在对应节点创建systemd服务：

```
sudo cp /usr/lib/systemd/system/ceph-radosgw@.service /usr/lib/systemd/system/ceph-radosgw@rgw.xg-cloud-cephrgw-3.service
sudo cp /usr/lib/systemd/system/ceph-radosgw@.service /usr/lib/systemd/system/ceph-radosgw@rgw.xg-cloud-cephrgw-2.service
sudo cp /usr/lib/systemd/system/ceph-radosgw@.service /usr/lib/systemd/system/ceph-radosgw@rgw.xg-cloud-cephrgw-1.service

```

初始化rgw：
默认时default.rgw.meta、default.rgw.buckets.index、default.rgw.buckets.data均不存在，需要创建用户和bucket，上传文件后才会自动创建。

### 3.6 Pool修改
默认pool均处于SATA池中，并且pg数量较少，因此需要修改。
将default.rgw.meta、default.rgw.buckets.index修改为SSD池(crush_ruleset 1为SSD池，0为SATA池）：

```
ceph osd pool set default.rgw.buckets.index crush_ruleset 1
ceph osd pool set default.rgw.meta crush_ruleset 1
```

修改pg：
注：default.rgw.buckets.data不能一次性修改到8192，需要逐步修改（64-128-256-1024-2048-4096-6144-8192）。

```
ceph osd pool set default.rgw.buckets.index pg_num 256

```


## 四、集群容量信息
### 4.1 集群容量
目前仅SATA池用于数据存储，对外提供服务仅以SATA池为准。
目前SATA池raw空间为351T，最大设计使用空间为351*0.75=263T。考虑使用3副本，对业务可用空间为87T。

元数据信息存储的SSD池，raw空间为5100G，最大使用空间3400G（允许一个节点故障）。在对象数量为0.37亿时，使用空间为1.4G*12=17G，每亿对象大约占用空间为46G，仅考虑空间，当前集群可以容纳70亿左右对象。
