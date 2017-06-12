# 添加monitor

使用ceph-deploy进行添加Monitor操作

```
# ceph-deploy mon add {hostname}
```

将配置文件更新到所有节点：

```
# ceph-deploy --overwrite-conf config push {hostname1} {hostname2} ...
```

