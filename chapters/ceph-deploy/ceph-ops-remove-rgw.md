# 移除RGW
本文参考同事的文档

1.停止radosgw服务

```
# systemctl stop ceph-radosgw@rgw.{hostname}
```

2.删除radosgw数据目录

```
# rm -rf /var/lib/ceph/radosgw/ceph-rgw.{hostname}
```

3.删除radosgw认证文件

```
# ceph auth del client.rgw.{hostname}
```
