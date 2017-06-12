# 添加rgw

首先进行安装前[准备工作](https://frank6866.gitbooks.io/ceph/content/chapters/ceph-deploy/ceph-install-prepare.html)

## 1.安装ceph相关的package

```
# ceph-deploy install ceph-1 ceph-2 ceph-3
```

如果目标结点上/etc/yum.repos.d/ceph.repo文件不存在,ceph-deploy install会在目标结点上创建/etc/yum.repos.d/ceph.repo文件。也可以自定义repo的地址:

```
# ceph-deploy install ceph-1 ceph-2 ceph-3  --repo-url http://mirrors.aliyun.com/ceph/rpm-jewel/el7/
```


## 2.安装rgw

```
# ceph-deploy rgw create ceph-1 ceph-2 ceph-3
```

