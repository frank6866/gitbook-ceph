# 移除RGW

由于ceph-deploy为无状态服务，在确保前端LB有可用radosgw的情况下，可以直接移除某一个radosgw实例服务。 停止radosgw服务：

```
# systemctl stop ceph-radosgw@rgw.{hostname}
```

删除radosgw数据目录：

```
# rm -rf /var/lib/ceph/radosgw/ceph-rgw.{hostname}
```

删除radosgw认证文件：

```
# ceph auth del client.rgw.{hostname}
```

