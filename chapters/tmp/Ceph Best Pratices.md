# Ceph最佳实践

术语与符号说明：

- Monitor:代表Ceph Monitor。{mon-id}代表Monitor ID,在集群中一般为Monitor所在节点的主机名。
- OSD：代表Ceph OSD Daemon。{osd-num}代表OSD进程ID，在集群中以数值出现。
- radosgw：代表Ceph Object Gateway。
- 主机相关：{hostname}代表主机名，{devicename}代表设备名称。



## 一、Ceph常规操作手册

### 1.1 移除一个OSD

移除OSD会导致数据迁移（此时集群性能下降），并且可能导致集群空间达到full ratio（集群无法写入数据），需要考虑上述因素。
由于out osd和crush remove操作均会导致集群数据迁移，因此在官方步骤中进行优化。

1、在crush中设置OSD weight为0，等待迁移完成。
	
	ceph osd crush reweight osd.{osd-num} 0
	
2、从集群中设置OSD为out（如果OSD还处于in状态）：

	ceph osd out {osd-num}
	
3、停止OSD进程（如果进程还在运行）：

	systemctl stop ceph-osd@{osd-num}
	
4、从CRUSH map中移除osd：
	
	ceph osd crush remove osd.{osd-num}
	
5、删除osd认证key：

	ceph auth del osd.{osd-num}
	
6、从集群中移除集群：
	
	ceph osd rm {osd-num}
从集群中移除OSD后，在CRUSH map中该OSD会有一个“占位”。如果使用ceph osd create创建新的OSD时不指定OSD id，那么新OSD会使用旧的OSD id。

7、(可选）如果磁盘被替换了，可以通过 添加OSD 章节进行添加操作。

### 1.2 添加一个OSD

1、列出节点上磁盘
	
	ceph-deploy disk list {hostname}
	
2、清理磁盘

	ceph-deploy disk zap {hostname}:{devicename}

执行清理的时候，会将该磁盘分区删除，磁盘上所有文件会丢失。

3、使用create命令创建OSD
a. 如果journal和数据盘在一个磁盘上：
	
	ceph-deploy osd create {hostname}:{devicename}
	
该命令会在磁盘上创建两个分区，第一个分区为OSD的journal，另外一个分区格式化成文件系统供Ceph存储数据。
b. 如果journal在额外的磁盘（通常为SSD）上：

	ceph-deploy osd create {hostname}:{devicename}:{journaldevice}
	

c、如果需要替换Ceph OSD节点上的一个磁盘，这时可能会使用和旧的磁盘一样的journal分区，使用下面的步骤：

（1）找出OSD使用的journal设备(软连接到/var/lib/ceph/osd/ceph-{osd-num}/journal），例如：

```
# ls -al /var/lib/ceph/osd/ceph-1/journal
lrwxrwxrwx 1 ceph ceph 58 Dec 27 15:12 /var/lib/ceph/osd/ceph-1/journal -> /dev/disk/by-partuuid/a08f8b01-d087-4d9c-961d-fa17ee1492b1
```

（2）使用章节 1.1 移除一个OSD 进行移除操作。

（3）使用指定的分区创建新OSD：
	
（4）使用新journal创建OSD：
	
	ceph-deploy osd create {hostname}:{devicename}:{journaldevice}
	
{journaldevice}为原先OSD journal使用的by-partuuid位置。

注意：尽量避免同时添加多个OSD，因为添加OSD时会进行backfill和recovery操作，影响集群性能。另外，可以在添加OSD时指定一个较小的weight，逐渐增加：
	
	ceph osd crush reweight osd.{osd-num} {weight-num}

4、 检查集群OSD数量和数据迁移情况

### 1.3 更换journal device

该步骤针对集群中OSD使用了独立的journal device（一般为SSD），更换journal disk的步骤。

1、检查当前OSD节点所有OSD jorunal使用设备，确定更换journal影响的OSD。例如，查看某个OSD journal使用设备的过程如下：

```
# ls -al /var/lib/ceph/osd/ceph-0/journal
lrwxrwxrwx 1 ceph ceph 58 Dec 27 15:07 /var/lib/ceph/osd/ceph-0/journal -> /dev/disk/by-partuuid/28e46cec-d906-4edd-a04b-aeef1b4abce3

# ls -al /dev/disk/by-partuuid/28e46cec-d906-4edd-a04b-aeef1b4abce3
lrwxrwxrwx 1 root root 10 Dec 27 15:26 /dev/disk/by-partuuid/28e46cec-d906-4edd-a04b-aeef1b4abce3 -> ../../sdb1
```

2、设置集群为noout，停止受到影响的OSD进程：

	ceph osd set noout
	ceph osd down osd.{osd-num};systemctl stop ceph-osd@{osd-num}
	
3、刷新journal数据到数据盘：
	
	ceph-osd -i {osd-num} --flush-journal

4、更换journal disk。

5、创建新journal
在新磁盘创建分区：

```
# sgdisk --new=0:0:+{journal_size} --change-name=0:'ceph journal' --partition-guid=0:{journal_uuid} --typecode=0:{journal_uuid} --mbrtogpt -- {journal_disk}

# partprobe
```

查找分区对应partuuid：

```
# ls -al /dev/disk/by-partuuid/
```

新分区使用partuuid软链接到OSD数据目录：

```
# ln -s /dev/disk/by-partuuid/{part-uuid} /var/lib/ceph/ceph-{osd-num}/journal
chown ceph: /var/lib/ceph/ceph-{osd-num}/journal
```

创建journal:

```
# ceph-osd -i {osd-num} --mkjournal
```

注：{journal_size}为journal大小，定义在ceph.conf中。{journal_uuid}为OSD数据目录下journal_uuid文件内容，例如/var/lib/ceph/osd/ceph-{osd-num}/journal_uuid

6、 启动OSD：
	
	systemctl start ceph-osd@{osd-num}

### 1.4 从健康运行的集群中移除Ceph Monitor

这个步骤将会移除一个ceph-mon。如果这个操作后集群中仅剩余两个,Monitor，为了达到法定人数，你需要添加或者再移除一个Monitor。

1、停止Monitor进程：

	systemctl stop ceph-mon@{mon-id}

2、 从集群中移除Monitor：

	ceph mon remove {mon-id}

3、将集群中所有节点（包含提供服务的client）的配置文件中（mon_initial_members/mon_host），移除Monitor。

4、（可选）备份被删除monitor节点数据后，删除原数据。

注意：这是一个非常危险的操作，需要谨慎进行。

### 1.5 从关闭的集群移除Monitor

这个步骤可以从一个异常状态的集群移除Monitor。例如，一个三节点的集群相继出现两个Monitor故障，导致无法连接Monitor。

1、查找到仍旧存活的Monitor节点

	ceph mon dump
	ssh <monitor_hostname}
注：某些情况下，ceph mon由于未达到法定人数而不能运行，可以通过查看进程的方式找到剩余存活的Monitor。

2、停止Monitor进程，并且解压一个monmap文件：
	
	systemctl stop ceph-mon@{mon-id}
	ceph-mon -i {mon-id} --extract-monmap /tmp/monmap
	
3、移除没有存活的Monitor
	
	monmaptool <map_path> --rm {mon-id}
	
注：<map_path>为上一步骤中导出的位置/tmp/monmap。

4、将新的monmap导入存活的Monitor节点：
	
	ceph-mon -i {mon-id} --inject-monmap <map_path>
	
5、启动存活的Monitor节点验证后，验证集群状态。
	
### 1.6 添加Monitor

使用ceph-deploy进行添加Monitor操作。
待添加的节点需要进行节点准备（参考章节 1.x )。

	ceph-deploy mon add {hostname}

将配置文件更新到所有节点：
	
	ceph-deploy --overwrite-conf config push {hostname1} {hostname2} ...

注意：待添加的节点需要进行节点准备（参考章节 1.x )。


### 1.7 添加radosgw

使用ceph-deploy进程添加radosgw操作。
在节点准备完毕后，使用ceph-deploy进行安装rgw操作：
	
	ceph-deploy rgw create {hostname}

### 1.8 移除radosgw

由于ceph-deploy为无状态服务，在确保前端LB有可用radosgw的情况下，可以直接移除某一个radosgw实例服务。
停止radosgw服务：
	
	systemctl stop ceph-radosgw@rgw.{hostname}

删除radosgw数据目录：
	
	rm -rf /var/lib/ceph/radosgw/ceph-rgw.{hostname}
	
删除radosgw认证文件：
	
	ceph auth del client.rgw.{hostname}


### 1.9 节点准备

以下部分均以CentOS 7为例进行介绍。

1、安装与配置ntp，确保节点间时间同步（非常重要）。

2、创建ceph-deploy用户（目前均为ceph.eleme），允许免密码sudo权限。

3、建立ceph-deploy节点与新节点免密ssh连接。

4、节点网络准备：确认节点使用静态IP，防火墙关闭。




## 二、 Tuning

Ceph集群在部署完毕后，可以对集群进行配置进行修改。由于部分修改可能对集群性能造成较大影响，所有的变更都应该进行评审和严格的测试。

### 2.1 使用ceph-deploy进行配置推送	

使用ceph-deploy可以将已经修改过的配置推送到节点：
	
	ceph-deploy --overwrite-conf config push {hostname1} {hostname2} {hostname3}
	
或：
	
	ceph-deploy --overwrite-conf config push hostname{1,2,3}
	
### 2.2 变更

#### 2.2.1 在配置文件中变更
	
所有在配置文件中变更的部分，只有在服务启动的时候会读取。因此，修改配置文件后，需要重启指定服务。

#### 2.2.2 通过Monitor进行在线变更

变更可以通过在线注入到Monitor来变更到节点。例如，
	
	ceph tell osd.20 injectargs --debug-osd 20
	
#### 2.2.3 通过admin socket在线变更

当Monitor不可达或者出于方便的目的时，可以使用admin socket进行变更。

	ceph --admin-daemon 
	
注意： 通过在线的方式提交的变更，在进程重启后都无法生效。如果需要持久化变更，需要将变更写入到配置文件中。
仅有部分配置可以通过在线的方式变更，如果变更时提示“unchangeble"，表明该配置只能通过变更配置文件的方式进行更改。


## 三、故障排查工具

### 3.1 Ceph集群整体健康状态

为了获取到Ceph集群整体健康状态，可以使用以下命令：

简单状态：

	ceph -s

带有额外信息和debug信息的健康状态：

	ceph health detail

报告配置和运行状态和计数器：

	ceph report

### 3.2 日志


### 3.3 Monitor失效



## 四、故障排查实例

### 4.1 节点OSD/Monitor由于权限问题无法启动

（1）故障现象：

启动节点中Monitor/OSD服务时，服务无法启动，Ceph日志无明显提示，查看系统日志有以下提示：

```
Dec 30 11:24:05 sh-office-ceph-1 systemd: Starting Ceph cluster monitor daemon...
Dec 30 11:24:05 sh-office-ceph-1 systemd: Started Ceph cluster monitor daemon.
Dec 30 11:24:05 sh-office-ceph-1 ceph-mon: warning: unable to create /var/run/ceph: (13) Permission denied
Dec 30 11:24:05 sh-office-ceph-1 ceph-mon: stat(/var/lib/ceph/mon/ceph-sh-office-ceph-1) (13) Permission denied
Dec 30 11:24:05 sh-office-ceph-1 ceph-mon: error accessing monitor data directory at '/var/lib/ceph/mon/ceph-sh-office-ceph-1': (13) Permission denied
Dec 30 11:24:05 sh-office-ceph-1 systemd: ceph-mon@sh-office-ceph-1.service: main process exited, code=exited, status=1/FAILURE
```

（2）故障分析：

Ceph Monitor/OSD在启动过程中需要对目录中的文件进行创建/修改，启动过程中提示对
/var/lib/ceph或者/var/run/ceph目录权限存在文件，可以尝试使用非root尝试进入目录。检查发现非root用户无法cd进入上述目录。
使用root逐级查看目录权限，与正常其他服务器进行对比，发现/var目录权限存在问题：
	
```
# ls -ald /var/
drwxrw-rw-. 21 root root 4096 Nov 15 17:10 /var/
```

目前无x权限，导致非root用户无法进入目录。

（3）故障解决

将/var目录权限修改为744,重新启动服务：

```
systemctl reset-failed ceph-mon@{hostname}
systemctl start ceph-mon@{hostname}

```

检查服务启动，正常加入集群。

（4）解决思路

如果遇到某一个节点所有Ceph相关服务无法启动的情况下，可以首先检查操作系统日志，查看启动失败原因。如果是权限问题，可以通过非root账户尝试进入目录和创建文件操作，如果出现问题， 逐级检查目录权限，直至找到出现问题的目录。

说明：文档基于Ceph Jewel版本