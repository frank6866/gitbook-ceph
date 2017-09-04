# rados


列出所有的pool:

```
$ rados lspools
rbd
cephfs_data
cephfs_metadata
```


查看集群空间使用情况:

```
$ rados df
pool name                 KB      objects       clones     degraded      unfound           rd        rd KB           wr        wr KB
cephfs_data     380800880276     94270278            0        14108            0    571582261 290341154894   2864318094 4475129926776
cephfs_metadata        51919        28504            0           28            0     22382925    260490674     91157812    393230340
rbd              10819757349      2667363            0            4            0     17695478   1764066746     95173535  18961345038
  total used    1180265382228     96966145
  total avail   925249168572
  total space   2105514550800
```

可以看到,集群的总对象数是96966145,总使用空间是1180265382228,平均对象大小是1180031080452/96949317=12171KB

空间使用情况看起来不是很直观,如果不需要查看总对象数,可以使用ceph df命令,看起来更直观一点:

```
$ ceph df
GLOBAL:
    SIZE      AVAIL     RAW USED     %RAW USED
    1960T      861T        1098T         56.04
POOLS:
    NAME                ID     USED       %USED     MAX AVAIL     OBJECTS
    rbd                 0      10318G      1.54          166T      2667363
    cephfs_data         3        354T     54.25          166T     94253531
    cephfs_metadata     4      50683k         0          166T        28518
```


