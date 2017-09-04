# 集群空间使用
ceph df命令可以查询集群空间使用情况

```
# ceph df
GLOBAL:
    SIZE      AVAIL     RAW USED     %RAW USED
    8016G     7317G         698G          8.72
POOLS:
    NAME                             ID      USED       %USED     MAX AVAIL     OBJECTS
    rbd                              0        3917M      0.14         2668G        1870
    volumes                          369       124G      4.46         2668G       33127
    images                           370     82023M      2.91         2668G       10307
    vms                              371          0         0         2668G           2
    backups                          372      2048M      0.07         2668G         516
......
```

GLOBAL区域表示整体的空间使用情况:    

* SIZE: 表示集群中所有OSD总空间大小
* AVAIL: 表示可以使用的空间大小
* RAW USED: 表示已用空间大小
* %RAW USED: 表示已用空间百分比


POOLS区域表示某个pool的空间使用情况  

* NAME: pool名称
* ID: pool id
* USED: 已用空间大小
* %USED: 已用空间百分比
* MAX AVAIL: 最大可用空间大小
* OBJECTS: 这个pool中对象的个数


> 注意: pool里面的已有空间是业务上的空间,也就是一个副本的空间;将业务上空间乘以副本数,和RAW USED是相等的。RAW USED是集群物理上已近使用的空间。


