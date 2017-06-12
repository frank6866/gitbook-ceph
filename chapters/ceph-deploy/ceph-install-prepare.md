# 安装前准备工作
在使用ceph-deploy部署ceph集群前，有如下checklist:  

1. 确保ntp服务器已开启，并且各个节点上时间是同步的(参考[ntp配置](https://frank6866.gitbooks.io/linux/content/chapters/software/linux-ntp.html)和[ntp配置注意事项](https://frank6866.gitbooks.io/linux/content/chapters/exception/linux-exception-ntp.html))
2. 每个节点之间，支持通过主机名互相访问(通过注册DNS或者编辑/etc/hosts文件，**建议放到DNS中**)
3. 每个节点上都需要创建一个具有sudo权限的用户，配置ceph-deploy节点可以通过这个用户免密码登录到各个结点上
4. 确保各个节点的防火墙服务已关闭
5. 确保各个节点的selinux服务已关闭

在上面的准备工作中，都是需要在么个节点上一个个去做的，可以通过ansible脚本来完成。可以使用我写的role [https://galaxy.ansible.com/frank6866/ceph-prepare/](https://galaxy.ansible.com/frank6866/ceph-prepare/)

## ssh端口配置

ceph-deploy没有配置ssh端口的配置,可以在ceph-deploy结点上通过修改.ssh/config文件配置ssh端口


~/.ssh/config

```
Host ceph-1
        Port 2345
```


