# 更换journal device
该步骤主要针对集群中OSD使用了独立的journal device（一般为SSD）。

更换journal disk的步骤如下: 

1.检查当前OSD节点所有OSD jorunal使用设备，确定更换journal影响的OSD。例如，查看某个OSD journal使用设备的过程如下：

```
# ls -al /var/lib/ceph/osd/ceph-0/journal
lrwxrwxrwx 1 ceph ceph 58 Dec 27 15:07 /var/lib/ceph/osd/ceph-0/journal -> /dev/disk/by-partuuid/28e46cec-d906-4edd-a04b-aeef1b4abce3

# ls -al /dev/disk/by-partuuid/28e46cec-d906-4edd-a04b-aeef1b4abce3
lrwxrwxrwx 1 root root 10 Dec 27 15:26 /dev/disk/by-partuuid/28e46cec-d906-4edd-a04b-aeef1b4abce3 -> ../../sdb1
```

2.设置集群为noout，停止受到影响的OSD进程：

```
# ceph osd set noout
# ceph osd down osd.{osd-num};systemctl stop ceph-osd@{osd-num}
```

3.刷新journal数据到数据盘：

```
# ceph-osd -i {osd-num} --flush-journal
```

4.更换journal disk

5.创建新journal 在新磁盘创建分区：

```
# sgdisk --new=0:0:+{journal_size} --change-name=0:'ceph journal' --partition-guid=0:{journal_uuid} --typecode=0:{journal_uuid} --mbrtogpt -- {journal_disk}

# partprobe
查找分区对应partuuid：
# ls -al /dev/disk/by-partuuid/
新分区使用partuuid软链接到OSD数据目录：
# ln -s /dev/disk/by-partuuid/{part-uuid} /var/lib/ceph/ceph-{osd-num}/journal
chown ceph: /var/lib/ceph/ceph-{osd-num}/journal
创建journal:
# ceph-osd -i {osd-num} --mkjournal
注：{journal_size}为journal大小，定义在ceph.conf中。{journal_uuid}为OSD数据目录下journal_uuid文件内容，例如/var/lib/ceph/osd/ceph-{osd-num}/journal_uuid
```

6. 启动OSD：

```
# systemctl start ceph-osd@{osd-num}
```
