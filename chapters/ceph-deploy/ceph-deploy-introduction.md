# ceph-deploy简介
ceph-deploy是一个自动化部署ceph集群的工具，使用ceph-deploy我们可以很容易就部署一套ceph集群。  

ceph-deploy工具使用ssh连接ceph节点，执行相应的python脚本来完成任务，ceph-deploy是使用python开发的。

官网文档地址:  [http://docs.ceph.com/ceph-deploy/docs/#](http://docs.ceph.com/ceph-deploy/docs/#)

## 安装
### CentOS7
```
# pip install ceph-deploy
```

也可以使用yum安装，但先要配置ceph仓库。  


### macOS
```
➜  ~ pip install ceph-deploy

➜  ~ pip list | grep ceph-deploy
ceph-deploy (1.5.38)
```

