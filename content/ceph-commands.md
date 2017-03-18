# 常用命令

列出所有池 ceph osd lspools
创建一个池 ceph osd pool create {pool-name} {pg-num}


查看资源使用情况
ceph df


查看所有的pool
rados lspools


查看pool中的对象
rbd list volumes



查看用户及权限
ceph auth list



ceph auth caps client.cinder-backup mon '' osd ''


allow class-read object_prefix rbd_children, allow rwx pool=backups, allow rx pool=images

删除权限,添加权限,测试


ceph auth caps client.cinder-backup mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=backups, allow rx pool=images'



