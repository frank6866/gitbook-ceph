# weight和reweight

在ceph osd df命令中，有weight和reweight两个字段:  

```
# ceph osd df
ID WEIGHT  REWEIGHT SIZE  USE    AVAIL %USE  VAR  PGS
 3 0.86909  1.00000  889G 78631M  813G  8.63 0.99 329
 4 0.86909  0.98000  889G 81207M  810G  8.91 1.02 333
 5 0.86909  1.00000  889G 78747M  813G  8.64 0.99 346
......
```

weight和磁盘容量有关系，比如1T磁盘的weight值是1，只和磁盘容量有关系，不会因为磁盘可用空间减少而减少。

reweight的目的是，当集群规模较小时，CRUSH算法的均衡性可能不会很好，可以通过设置osd的reweight来达到数据均衡的目的。

reweight是一个0-1之间的值，命令格式如下:  

```
# osd reweight osd-id <float[0.0-1.0]>
```

比如，将id为1的osd的reweight设置为0.9

```
# ceph osd reweight 1 0.9
```



