    * [all](chapters/command/ceph-command-all.md)

# Ceph命令大全


## 一、ceph

### 1.1 认证相关

#### 1.1.1 创建User

方法一：

```
$ ceph auth add <entity> {<caps> [<caps>...]} 
``` 

例如：

```
$ ceph auth add client.cloud mon 'allow r' osd 'allow rw pool=test'
```

方法二：

创建或者获取用户。注意，如果已有用户，caps发生变化，会无效。

```
$ ceph auth get-or-create <entity> {<caps> [<caps>...]} [-o keyfile]
```

例如：

```
$ ceph auth get-or-create client.cloud mon 'allow r' osd 'allow rw pool=test' -o key
```

方法三：

仅返回用户Key.

```
$ ceph auth get-or-create <entity> {<caps> [<caps>...]} [-o keyfile]
```

#### 1.1.2 列出所有用户和caps

```
$ ceph auth list
```

#### 1.1.3 获取key/auth实例

```
# 仅返回key
$ ceph auth get-key <entity>
$ ceph print-key <entity>
$ ceph print_key <entity>

# 返回用户caps和key
$ ceph auth get <entity>
```

#### 1.1.4 删除用户

```
$ ceph auth del <entity>

# 执行失败
$ ceph auth rm <entity>   
```

#### 1.1.5 导入\导出用户

```
# EXPORT
$ ceph auth export <entity> [-o <outfile>]

# IMPORT 
$ ceph auth import -i <inputfile>
```

#### 1.1.6 修改caps

```
$ ceph auth caps <entity> <caps> [<caps>...]
```

### 1.2 Monitor相关

#### 1.2.1 Monitor状态查询

```
#详细
$ ceph mon_status

# 概述
$ ceph mon stat
```

#### 1.2.2 添加MON

```
$ ceph mon add <name> <IPaddr[:port]>
```

#### 1.2.3 移除MON

```
$ ceph mon remove <name>

$ ceph mon rm <name>
```

#### 1.2.4 精简MON存储空间

```
$ ceph mon compact
```

注：经过测试，在运行命令后，多个节点MON存储空间均有一定下降。

#### 1.2.5 获取monmap

```
# 经过格式化
$ ceph mon dump [<epoch-id>]

$ ceph mon getmap [<epoch-id>]
```

注：<epoch-id>是一个递增的整数，不加入该参数则获取最新的monmap。
可以用于在MON故障恢复后排查，查找历史版本的monmap。

#### 1.2.6 获取mon metadata信息

```
$ ceph mon metadata <id>
```

注：<id>通常为主机名。
返回的信息通常包含主机的CPU、内核、OS信息。

#### 1.2.7 scrub mon存储

```
$ ceph mon scrub
```

TODO：可能类似于pg的scrub。

#### 1.2.8 强制同步/清楚MON存储

```
$ ceph mon sync force {--yes-i-really-mean-it} {--i-know-what-i-am-doing}
```

注：暂不清楚用途。


### 1.3 File System相关

#### 1.3.1 列出所有fs

```
$ ceph fs ls
```

#### 1.3.2 获取fs信息

```
$ ceph fs get <fs_name>
```

#### 1.3.3 创建新fs

```
$ ceph fs new <fs_name> <metadata_pool> <data_pool>
```

#### 1.3.4 导出fs信息（epoch)

```
$ ceph fs dump [<epoch_id>]
```

注：<epoch_id>是一个递增的整数值。默认情况下，不加<epoch_id>获取最新版本的fs信息。

#### 1.3.5 设置fs flag

```
$ fs flag set <flag name> <flag val> [--yes-i-really-mean-it]
```

注:

目前可以设置的flag name为enable_multiple，开启了该参数（flag val设置为true)，意味着可以在一个Ceph集群中拥有多个fs。但是该特性目前处于试验状态，暂不推荐生产环境下使用。
默认情况下，在一个集群中仅支持单fs。

#### 1.3.6 为fs增加/移除data pool

增加data pool:

```
$ ceph fs add_data_pool <fs_name> <pool_name>
```

移除data pool:

```
$ ceph fs rm_data_pool <fs_name> <pool>
```

TODO:

需要增加测试，验证增加data pool的作用，是否可以实现快速扩容等（例如，增加的pool使用不同的crush ruleset）

##### 1.3.7 故障恢复----reset fs

```
$ ceph fs reset <fs_name> {--yes-i-really-mean-it}
```

注：故障恢复相关，需要研究与测试

#### 1.3.8 删除fs

```
$ ceph fs rm <fs_name> {--yes-i-really-mean-it}
```

#### 1.3.9 设置fs

```
$ ceph fs set <fs_name> max_mds|max_file_size|
  allow_new_snaps|inline_data|cluster_
  down|allow_multimds|allow_dirfrags
  <val> {<confirm>}
```

TODO:具体设置需要理解含义

#### 1.3.10 设置默认fs

```
$ ceph fs set_default <fs_name>
```

注：目前不清楚是否是多fs中设置默认fs。已经排除是恢复fs的默认设置。

#### 1.3.11 mds历史命令

以下命令已经被代替：

```
mds dump -> fs get
mds stop -> mds deactivate
mds set_max_mds -> fs set max_mds
mds set -> fs set
mds cluster_down -> fs set cluster_down
mds cluster_up -> fs set cluster_up
mds newfs -> fs new
mds add_data_pool -> fs add_data_pool
mds remove_data_pool -> fs remove_data_pool

```

#### 1.3.12 显示mds兼容性设置（compatibility settings）

```
$ ceph mds compat show
```

返回值有三个部分，其中compact/rocompat为空，incompat有内容。暂时不清楚三者区别。

#### 1.3.13 移除compat特性

```
$ ceph mds compat rm_compat <int[0-]>
```

TODO:暂不清楚作用，勿随意使用

#### 1.3.14 移除incompat特性

```
$ ceph compat rm_incompat <int[0-]>
```

TODO：暂不清楚作用，由于incompat有内容，勿轻易使用。

#### 1.3.15 停止某个MDS

```
$ ceph mds deactivate <>
```

TODO:暂时无法使用

#### 1.3.16 强制mds失效

```
$ ceph mds fail <mds_name>
```

注：mds_name一般为主机名。
测试：如果设置了ceph fs set <fs_name> cluster_down true，如果此时fail掉active的mds实例，那么standby的实例不会变为active，此时不存在active的mds实例。

#### 1.3.17 获取fsmap

```
$ ceph mds getmap <epoch_id>
```

返回值为二进制，无法阅读

#### 1.3.18 获取mds元数据

```
$ ceph mds metadata <mds_name>
```

返回mds系统、内核信息等。

#### 1.3.19 修复rank

```
$ ceph mds repaired <rank>
```

TODO:暂不清楚作用

#### 1.3.20 移除非active的mds

```
$ ceph mds rm <gid>
```

注：
gid可以从ceph fs dump中获取

```
Standby daemons:
 
383093: 10.10.10.28:6814/32226 'ceph-3' mds.-1.0 up:standby seq 1065
```

383093为节点gid

#### 1.3.21 移除failed的mds

```
$ ceph mds rmfailed <mdsid> --yes-i-really-mean-it
```

#### 1.3.22 设置MDS最大index

```
$ ceph mds set_max_mds <num>
```

注：与多fs相关，目前不开启

#### 1.3.23 设置MDS状态
 
```
$ ceph mds set_stat <gid> <stat_id>
```

#### 1.3.24 显示mds状态

```
$ ceph mds stat
```

#### 1.3.25 设置mds配置

```
$ ceph tell 
```

#### 1.3.26 在线变更参数

```
$ ceph mds tell <who> <args> [<args>...]
```

TODO:未设置成功。

### 1.4 OSD相关

#### 1.4.1 OSD blacklist添加/删除

blacklist可以用于限制rbd/fs客户端使用。

```
$ ceph osd blacklist add ADDRESS[:source_port] [TIME]
$ ceph osd blacklist rm ADDRESS[:source_port]
```

注：默认不填写TIME，时间为3600s

限制rbd的现象：
rbd map时

```
rbd map test33
rbd: sysfs write failed
2017-02-14 11:18:36.295636 7f6cddefd700 -1 librbd::image::OpenRequest: failed to stat v2 image header: (108) Cannot send after transport endpoint shutdown
2017-02-14 11:18:36.295790 7f6cdd6fc700 -1 librbd::ImageState: failed to open image: (108) Cannot send after transport endpoint shutdown
rbd: error opening image test33: (108) Cannot send after transport endpoint shutdown
In some cases useful info is found in syslog - try "dmesg | tail" or so.
rbd: map failed: (108) Cannot send after transport endpoint shutdown
```

限制fs时，可以挂载文件系统，但是无法写入真实数据（写入数据成功报错，所有数据均为0字节）


#### 1.4.2 列出blacklist

```
$ ceph osd blacklist ls
```

#### 1.4.3 清除所有blacklist

```
$ ceph osd blacklist clear
```

#### 1.4.4 列出OSD blocked op数量

```
$ ceph osd blocked-by
```

注：在有blocked的情况下，该命令仍旧返回值为空，目前无效。

#### 1.4.5 创建OSD

```
$ ceph osd create {<uuid>} {<int[0-]>}
```

优先使用ceph-deploy创建OSD，除非有特殊需求。

#### 1.4.6 OSD deep-scrub/scrub

```
$ ceph osd deep-scrub osd.<num>
$ ceph osd scrub osd.<num>
```

对所有以某个OSD为primary的pg进行deep-scrub操作。

#### 1.4.7 显示OSD空间使用率

```
$ ceph osd df {plain|tree}
```

显示集群中所有OSD空间使用率情况，非仅当前节点。

#### 1.4.8 设置OSD为down

```
$ ceph osd down osd.<num>
```

注：osd down掉后，如果OSD进程还在，会迅速变为UP。

#### 1.4.9 导出OSD map概述

```
$ ceph osd dump
```

可读性较差

#### 1.4.10 erasure-code

ensure-code相关，暂不使用

```
$ ceph osd erasure-code-profile get <name>
$ ceph osd erasure-code-profile ls
$ ceph osd erasure-code-profile rm <name>
$ ceph osd erasure-code-profile set <name> {<profile> [<profile>...]}
```

#### 1.4.11 查找OSD位置

```
$ ceph osd find <num>
```

快速定位OSD位置的命令，比查看ceph osd tree效率高，直接返回OSD所在主机信息等。


#### 1.4.12 获取OSD map

```
$ ceph osd getmap {<int[0-]>}
```

返回值为二进制，无法查看。

```
$ ceph osd stat
```

返回OSD map的概述（OSD数量，in，up）

#### 1.4.13 获取/设置最大的OSD id

```
$ ceph osd getmaxosd
$ ceph osd setmaxosd
```

#### 1.4.14 设置OSD in/out cluser 

```
$ ceph osd in <num>
$ ceph osd out <num>
```

#### 1.4.15 设置OSD永久丢失

```
$ ceph osd lost <num> {--yes-i-really-mean-it}
```

永久丢失某个OSD，如果数据没有副本，可能会丢失数据。

#### 1.4.16 获取所有OSD ID

```
$ ceph osd ls
```

#### 1.4.17 获取所有pools

```
$ ceph osd lspools
```

#### 1.4.18 查找对象所在pg

```
$ ceph map <poolname> <objectname> --object-locator
```

根据对象名称、pool计算对象应该属于哪个pg，并不是执行了“查找”操作。

#### 1.4.19 获取OSD metadata信息

```
$ ceph osd metadata <num>
```

获取OSD元数据信息，除了包括OS、CPU、内存等，还包括后端文件系统等。

#### 1.4.20 集群OSD暂停/恢复服务

暂时整个集群中OSD读写:

```
$ ceph osd pause
```

恢复OSD读写：

```
$ ceph osd unpause
```

#### 1.4.21 输出OSD性能概述状态

```
$ ceph osd perf
```

#### 1.4.22 设置pg-temp

```
$ ceph osd pg-temp <pgid> {<id> [<id>...]} 

$ ceph osd primary-temp <pgid> <id>
```

注：pg-temp一般在acting set发生变化时，程序自动使用。一般该命令只有开发者使用。

#### 1.4.23 创建pool

```
$ ceph osd pool create <poolname> <pg_num> <pgp_num> {replicated|erasure} {<erasure_code_profile>} {<ruleset>} {<int>}
```

创建pool，常用命令，目前仅使用replicated。

#### 1.4.24 删除pool

```
$ ceph osd pool delete <poolname> <poolname> --yes-i-really-really-mean-it

$ ceph osd pool delete <poolname> <poolname> --yes-i-really-really-mean-it
```

#### 1.4.25 获取pool参数

```
$ osd pool get <poolname> size|min_size|crash_replay_interval|pg_num|pgp_num|crush_ruleset|hashpspool|nodelete|nopgchange|nosizechange|write_fadvise_dontneed|noscrub|nodeep-scrub|hit_set_type|hit_set_period|hit_set_count|hit_set_fpp|auid|target_max_objects|target_max_bytes|cache_target_dirty_ratio|cache_target_dirty_high_ratio|cache_target_full_ratio|cache_min_flush_age|cache_min_evict_age|erasure_code_profile|min_read_recency_for_promote|all|min_write_recency_for_promote|fast_read|hit_set_grade_decay_rate|hit_set_search_last_n|scrub_min_interval|scrub_max_interval|deep_scrub_interval|       
recovery_priority|recovery_op_priority|scrub_priority
```

快速获取所有命令：ceph osd pool get <poolname> all

#### 1.4.26 设置pool参数

```
$ osd pool set <poolname> size|min_size|crash_replay_interval|pg_num|pgp_num|crush_ruleset|hashpspool|nodelete|nopgchange|nosizechange|write_fadvise_dontneed|noscrub|nodeep-scrub|hit_set_type|hit_set_period|hit_set_count|hit_set_fpp|auid|target_max_objects|target_max_bytes|cache_target_dirty_ratio|cache_target_dirty_high_ratio|cache_target_full_ratio|cache_min_flush_age|cache_min_evict_age|erasure_code_profile|min_read_recency_for_promote|all|min_write_recency_for_promote|fast_read|hit_set_grade_decay_rate|hit_set_search_last_n|scrub_min_interval|scrub_max_interval|deep_scrub_interval|       
recovery_priority|recovery_op_priority|scrub_priority <val> {--yes-i-really-mean-it}
```

TODO:需要了解参数意义

#### 1.4.27 设置/获取pool配额

设置pool配额：

```
$ ceph osd pool set-quota <poolname> max_objects|max_bytes <val>
```

例如，达到对象数量限制后，返回错误会提示：

```
$ rados put -p test a8 a
2017-02-14 16:19:33.707527 7feca9a01a40  0 client.444654.objecter  FULL, paused modify 0x7fecab85c2c0 tid 0
```

获取pool配额：

```
$ ceph osd pool get-quota <poolname>
```

#### 1.4.28 列出所有pool

```
$ ceph osd pool ls {detail}
```

#### 1.4.29 pool创建/删除快照

```
$ ceph osd pool mksnap <poolname> <snap>

$ ceph osd pool rmsnap <poolname> <snap>
```

#### 1.4.30 重命名pool

```
$ ceph osd pool rename <poolname> <poolname>
```

#### 1.4.31 获取pool状态

```
$ ceph pool stats {<poolname>}
```

获取全部/指定pool状态。
目前返回值正常情况下都是nothing is going on。

#### 1.4.32 调整OSD上pg选择为primary的比例

通常情况下，一个pg会对应3个OSD，其中会有一个OSD作为primary，其他OSD作为secondary。
使用该命令可以调整某个OSD上pg选择他作为primay的数量/比例。

```
$ ceph osd primary-affinity osd.<num> <float[0.0-1.0]> 
```

注：需要设置配合使用。

```
mon osd allow primary affinity = true
```

参考文档：[Ceph Primary Affinity](http://cephnotes.ksperis.com/blog/2014/08/20/ceph-primary-affinity)


#### 1.4.33 修复osd

```
# ceph osd repair osd.<num>
```

TODO：应该是跟inconsistent或者其他异常状态的pg相关，咱无场景可以验证。

#### 1.4.34 调整OSD权重

```
$ ceph osd reweight <num> <float[0.0-1.0]>
```

目前不太直接常用的命令：

```
$ ceph osd reweight-by-pg {<int>} {<float>} {<int>} {<poolname> [<poolname>...]}
$ ceph osd reweight-by-utilization {<int>} {<float>} {<int>} {--no-increasing}

$ ceph osd test-reweight-by-pg {<int>} {<float>} {<int>} {<poolname> [<poolname>...]}
$ ceph osd test-reweight-by-utilization {<int>} {<float>} {<int>} {--no-increasing}
```

常用于集群中发生某个OSD的存储空间比其他OSD多很多，出现了near full的场景。
与ceph osd crush reweight区别是，该命令的范围是0-1的浮点值，crush weight一般是以TB为单位的任意值。该命令是临时调整，crush weight是持久性调整。

以下引用的解释：

> “ceph osd crush reweight” sets the CRUSH weight of the OSD. This
weight is an arbitrary value (generally the size of the disk in TB or
something) and controls how much data the system tries to allocate to
the OSD.

> “ceph osd reweight” sets an override weight on the OSD. This value is
in the range 0 to 1, and forces CRUSH to re-place (1-weight) of the
data that would otherwise live on this drive. It does *not* change the
weights assigned to the buckets above the OSD, and is a corrective
measure in case the normal CRUSH distribution isn’t working out quite
right. (For instance, if one of your OSDs is at 90% and the others are
at 50%, you could reduce this weight to try and compensate for it.)

#### 1.3.35 删除OSD

```
$ ceph osd rm <num>
```

#### 1.3.36 设置/取消OSD参数

```
$ ceph osd set full|pause|noup|nodown|noout|noin|nobackfill|norebalance|norecover|noscrub|nodeep-scrub|notieragent|sortbitwise|require_jewel_osds

$ ceph osd unset full|pause|noup|nodown|noout|noin|nobackfill|norebalance|norecover|noscrub|nodeep-scrub|notieragent|sortbitwise
```

TODO:需要了解各参数的含义

#### 1.3.37 Cache Tier相关（暂不使用）

```
$ ceph osd tier add <poolname> <poolname> {--force-nonempty}
$ ceph osd tier add-cache <poolname> <poolname> <int[0-]>
$ ceph osd tier cache-mode <poolname> none|writeback|forward|readonly|readforward|proxy|readproxy {--yes-i-really-mean-it}
$ ceph osd tier remove <poolname> <poolname>
$ ceph osd tier remove-overlay <poolname>
$ ceph osd tier rm <poolname> <poolname> 
$ ceph osd tier rm-overlay <poolname>
$ ceph osd tier set-overlay <poolname> <poolname>
```

暂不使用。

#### 1.3.38 显示基础pg在OSD分布情况

```
$ ceph osd utilization
```

返回集群中平均每个OSD的pg数量、OSD上最少/最多pg的情况。

#### 1.3.39 获取OSD tree

```
$ ceph osd tree
```

#### 1.3.40 获取/导入crush map

```
# 导出二进制文件
$ ceph osd getcrushmap -o outfile

# 导出可读模式
$ ceph osd dump

# 导出bucket和item为tree视图
$ ceph osd crush tree
```

二进制文件转换：

```
# 二进制->文本
$ crushtool -d {compiled-crushmap-filename} -o {decompiled-crushmap-filename}

# 文本->二进制
$ crushtool -c {decompiled-crush-map-filename} -o {compiled-crush-map-filename}
```


```
$ ceph osd setcrushmap -i infile
```

#### 1.3.41 crush map添加/移除 OSD&bucket

创建

```
# 创建OSD
# location示范：host=xxxxx
$ ceph osd crush add osd.<num> <weight> <location>

# 创建bucket（这里指的是osd的容器，一般最低级为host）
# types
type 0 osd
type 1 host
type 2 chassis
type 3 rack
type 4 row
type 5 pdu
type 6 pod
type 7 room
type 8 datacenter
type 9 region
type 10 root

$ ceph osd crush add-bucket <name> <type>

```

移除

```
$ ceph osd crush remove <name>
$ ceph osd crush rm <name>
```

#### 1.3.42 位置调整

OSD位置(weight)调整

```
$ ceph osd crush create-or-remove osd.<num> <weight> <location>

$ ceph osd crush set osd.<num> <weight> <location>
```

bucket位置调整

```
$ ceph osd move <name> <location>

# 同样可以实现，但是官方文档均未使用，建议使用osd crush move
$ ceph osd link <name> <location>

# 可以将某个bucekt从上一级取消
$ ceph osd unlink <name>
```

#### 1.3.43 重命名crush map中bucket

```
$ ceph osd crush rename-bucket <srcname> <dstname>
```

#### 1.3.44 修改weight

```
# 修改某个bucket的weight
$ ceph crush reweight <name> <weight>

# 重新计算所有weight，当手动修改了weight后，如果存在问题，可以使用该命令重新生成
$ ceph osd crush reweight-all

# 修个某个节点下的weight
$ ceph osd crush reweight-subtree 
```

#### 1.3.45 列出/导出所有的crush rule 

```
$ ceph crush rule list
$ ceph crush rule ls

# 导出
$ ceph crush rule dump {<name>}
```

#### 1.3.46 创建/删除crush rule set

```
$ ceph osd crush rule create-simple <name> <root> {bucket-type} {firstn|indep} 
```

注：bucket-type一般为host。

```
# 创建erasure coded rule（一般不使用）
$ ceph osd crush rule create-erasure <name> {<profile>}     
```

删除：

```
$ ceph osd crush rule rm <name>
```

#### 1.3.47 获取/设置straw_calc_version

straw_calc_version有两种选择1、0，在F版本引入。0代表旧版本，在计算内部weight时可能存在问题；1版本已经修复。目前该配置不需要修改，无用命令。

```
$ ceph osd crush get-tunable straw_calc_version
$ ceph osd crush set-tunable straw_calc_version <0|1>
```

#### 1.3.48 获取/修改tunables

随着版本的变化，crush算法也可能得到改进。改进后，需要客户端/服务器端同时使用新的机制。使用tunable可以来使用新的特性。


```
$ ceph osd crush show-tunables 

$ osd crush tunables legacy|argonaut|bobtail|firefly|hammer|jewel|optimal|default
```

### 1.4 pg相关

#### 1.4.1 列出pg

可以根据不同的条件列出不同状态的pg。

全部状态如下：

```
{active|clean|down|replay|splitting|scrubbing|scrubq|degraded|inconsistent|peering|repair|recovering|backfill_wait|incomplete|stale|remapped|deep_scrub|backfill|backfill_toofull|recovery_wait|undersized|activating|peered [active|clean|down|replay|splitting|scrubbing|scrubq|degraded|inconsistent|peering|repair|recovering|backfill_wait|incomplete|stale|remapped|deep_scrub|backfill|backfill_toofull|recovery_wait|undersized|activating|peered...]}
```

```
# 列出所有/指定pool的pg
$ ceph pg ls [<pool_id>] [status]

# 列出指定OSD上的pg
$ ceph pg ls-by-osd <osd.id> [status]

# 列出指定pool的pg
$ ceph pg ls-by-pool <pool-name> [status]

# 列出osd上作为primary的pg
$ ceph pg ls-by-primary osd.<num> [status]
```

#### 1.4.2 导出pg-map

以下命令导出的pg-map,比1.4.1中列出的项目内容要多，例如pg map版本信息等。

```
$ ceph pg dump {all|summary|sum|delta|pools|osds|pgs|pgs_brief [all|summary|sum|delta|pools|osds|pgs|pgs_brief...]}

# 导出json格式
$ pg dump_json {all|summary|sum|pools|osds|pgs [all|summary|sum|pools|osds|pgs...]}

# 导出pg pool
$ ceph pg dump_pools_json

# 导出stack状态pg
$ ceph pg dump_stuck {inactive|unclean|stale|undersized|degraded [inactive|unclean|stale|undersized|degraded...]} {<int>}

# 导出二进制pg map到文件
$ ceph pg getmap -o

```

#### 1.4.3 对pg进行操作

```
# scrub pg
$ ceph pg scrub <pgid>

# deep-scrub pg
$ ceph pg deep-scrub <pgid>

# 修复pg，需要具体的场景实践
$ ceph pg repair <pgid>

# 设置pg full/nearfull ratio。如果在配置文件中设置了mon_osd_full_ratio/mon_osd_nearfull_ratio，最终也是对pg的ratio进行设置。
$ ceph pg set_full_ratio <float[0.0-1.0]>
$ ceph pg set_nearfull_ratio <float[0.0-1.0]>

# 强制创建pg。对现有pg执行，会导致现有pg对象被清空，并且pg一直处于creating状态，谨慎使用
$ ceph pg force_create_pg <pgid>

# 暂不清楚作用
$ pg send_pg_creates
```

#### 1.4.4 查询pg所在OSD

```
$ ceph pg map <pgid>
```

#### 1.4.5 查询pg详细信息

```
# 查询pg详细信息
$ ceph pg <pgid> query
```

#### 1.4.6 显示pg整体状态

```
$ ceph pg stat
```

返回各种状态pg计数。


#### 1.4.7 显示pg debug信息

```
$ ceph pg debug unfound_objects_exist|degraded_pgs_exist
```

暂不清楚具体作用。


### 1.5 集群相关

#### 1.5.1 集群整体健康状态

```
$ ceph health {detail}
```

#### 1.5.2 显示集群fsid

```
$ ceph fsid
```

返回UUID。

#### 1.5.3 显示集群空间状态

```
$ ceph df {detail}
```

加入detail后，会额外显示配额等信息

#### 1.5.4 列出集群中所有节点

```
$ ceph node ls {all|osd|mon|mds}
```

#### 1.5.5 显示集群状态

```
# 状态概述，包括健康、monmap、osdmap等。
$ ceph status

# 详细信息
$ ceph report {<tags> [<tags>...]}
```

#### 1.5.6 在线修改配置

```
$ ceph tell <name (type.id)> <args> [<args>...]
$ ceph injectargs <injected_args> [<injected_args>...]
```

#### 1.5.7 内存问题排查

```
$ ceph heap dump|start_profiler|stop_profiler|release|stats 
```

针对使用tcmalloc的应用，具体参考 [memory profiling](http://docs.ceph.com/docs/master/rados/troubleshooting/memory-profiling/)

#### 1.5.8 config-key相关

```
$ ceph config-key del <key>
$ ceph config-key exists <key>
$ ceph config-key get <key>
$ ceph config-key list
$ ceph config-key put <key> {<val>}
$ ceph config-key rm <key>
```

TODO:咱不清楚作用。

#### 1.6 MON相关

#### 1.6.1 显示MON版本

```
$ ceph version
```

返回为MON版本信息

#### 1.6.2 添加/移除MON

```
$ ceph mon add <name> <IPaddr[:port]>

$ ceph mon remove <name>
$ ceph mon rm <name>
```

谨慎添加/删除操作

#### 1.6.3 获取monmap

```
# 获取详细信息
$ ceph mon dump [<epoch_id>]

# 获取简单信息（用处较小）
$ ceph mon getmap [<epoch_id>]
```

#### 1.6.4 获取mon metadata信息

```
$ ceph mon metadata <id>
```

#### 1.6.5 获取mon状态

```
# 概述
$ ceph mon stat

# 详细
$ ceph mon_status
```

#### 1.6.6 操作mon

```
# 压缩mon存储，实际测试会减少mon的占用空间
$ ceph mon compact

# scrub操作，校验
$ ceph mon scrub

# 发送到mon日志，可以用于标识
$ ceph log <logtext>

# 强制同步/清理mon存储，危险
$ ceph mon sync force {--yes-i-really-mean-it} {--i-know-what-i-am-doing}
```

#### 1.6.7 quorum相关

```
# 获取quorum状态
$ ceph quorum_status

# 将当前节点加入/取消quorum，会导致leader重新选举，谨慎操作。
$ ceph quorum enter|exit
```

注意：
每个节点会有一个rank值，rank值最小的是当前mon的leader。其他mon角色为peon。


## 二、rados

### 2.1 Pool相关

#### 2.1.1 列出所有pool

```
$ rados lspools
```

#### 2.1.2 创建pool

```
$ rados mkpool <pool-name> [<auid>[ <crush_ruleset>]]
```

备注：auid是ceph用户内部ID，使用ceph auth export 可以得到。

#### 2.1.3 复制Pool中对象

```
$ rados cppool <pool-name> <dest-pool>
```

注：会复制实际内容，占用空间较大。目标Pool必须预先创建

#### 2.1.4 删除Pool

会删除pool以及所有对象，谨慎使用。

```
$ rados rmpool <pool-name> [<pool-name> --yes-i-really-really-mean-it]
```

#### 2.1.5 清除Pool中所有对象

谨慎使用，会删除pool中所有对象。

```
$ rados purge <pool-name> --yes-i-really-really-mean-it
```

#### 2.1.6 显示pool使用情况

显示每个pool和总体使用情况

```
$ rados df
```

#### 2.1.7 显示pool中对象

```
$ rados ls -p <pool-name>
```

#### 2.1.8 修改pool auid

```
$ rados chown <auid>
```

### 2.2 Pool快照相关

备注：快照目前是以pool级别做的，做了快照后，以对象为力度操作。

#### 2.2.1 列出pool所有快照信息

```
$ rados lssnap -p <pool-name>
```

#### 2.2.2 创建pool快照

```
$ rados mksnap <snap-name> -p <pool-name>
```

#### 2.2.3 删除pool快照

```
$ rados rmsnap <snap-name> -p <pool-name>
```

### 2.3 Object相关

#### 2.3.1 获取object

```
$ rados get -p <pool-name> <object-name> <outfile>
```

#### 2.3.2 存放object

```
$ rados put -p <pool-name> <object-name> <infile> [--object-locator=<string>]
```

备注：如果指定了--object-locator，对于使用相同locator的对象，都会存放在同一个pg中。在计算对象映射到pg时，仅以locator来进行映射。

#### 2.3.3 截短object

例如，一个对象大小为900，可以截短成500。

```
$ rados truncate -p <pool-name> <object-name> length
```

#### 2.3.4 创建空对象

```
$ rados create -p <pool-name> <obj-name> 
```

#### 2.3.5 删除对象

```
$ rados rm <obj-name> ...[--force-full] 
```

TODO：目前不清楚 --force-full用途

#### 2.3.6 复制对象

```
$ rados cp -p <pool-name> <obj-name> [target-obj]
```

#### 2.3.7 clonedata对象

```
$ rados clonedata -p <pool-name> <src-obj> <dst-obj> --object-locator=<string>
```

备注：使用时必须指定--object-locator，说明该命令只能限制在一个pg内进行复制。



#### 2.3.8 设置对象xattr

```
$ rados setxattr -p <pool-name> <obj-name> attr val
```

#### 2.3.9 列出所有xattr属性

```
$ rados listxattr -p <pool-name> <obj-name>
```

#### 2.3.10 获取对象xattr值

```
$ rados getxattr -p <pool-name> <obj-name> attr
```

#### 2.3.11 删除对象xattr

```
$ rados rmxattr -p <pool-name> <obj-name> attr
```

#### 2.3.12 查询对象状态

返回对象mtime，size信息。

```
$ rados stat -p <pool-name> <obj-name>
```

#### 2.3.13 mapext

TODO: 暂不清楚作用

```
$ rados mapext -p <pool-name> <obj-name>
```

#### 2.3.14 列出对象快照

```
$ rados listsnaps -p <pool-name> <obj-name>
```

#### 2.3.15 回滚对象快照

```
$ rados rollback -p <pool-name> <obj-name> <snap-name>
```

#### 2.3.16 性能测试

```
$ rados bench -p <pool-name> <seconds> write|seq|rand [-t concurrent_operations] [--no-cleanup] [--run-name run_name]
```

#### 2.3.17 性能测试对象清理

```
$ rados cleanup -p <pool-name> [--run-name run_name] [--prefix prefix]
```

#### 2.3.18 集群压力测试

```
$ rados load-gen [options]
```

测试参数：

```
--num-objects           初始生成测试用的对象数，默认 200
--min-object-size       测试对象的最小大小，默认 1KB，单位byte 
--max-object-size       测试对象的最大大小，默认 5GB，单位byte
--min-op-len            压测IO的最小大小，默认 1KB，单位byte
--max-op-len            压测IO的最大大小，默认 2MB，单位byte
--max-ops               一次提交的最大IO数，相当于iodepth
--target-throughput     一次提交IO的历史累计吞吐量上限，默认 5MB/s，单位B/s
--max-backlog           一次提交IO的吞吐量上限，默认10MB/s，单位B/s
--read-percent          读写混合中读的比例，默认80，范围[0, 100]
--run-length            运行的时间，默认60s，单位秒
```

#### 2.3.19 列出omapkeys

```
$ rados listomapkeys -p <pool-name> <obj-name>
```

备注：目前只在index对象中list出结果。

#### 2.3.20 列出omap值

```
$ rados listomapvals -p <pool-name> <obj-name>
```

#### 2.3.21 获取omap key值

```
$ rados getomapval -p <pool-name> <obj-name> <key> [outfile]
```

#### 2.3.22 设置omap key

```
$ rados setomapval -p <pool-name> <obj-name> <key> <val>
```

#### 2.3.23 删除omap key

```
$ rados rmomapkey -p <pool-name> <obj-name> <key>
```

#### 2.3.24 获取omap header

```
$ rados getomapheader -p <pool-name> <obj-name> [file]
```

#### 2.3.25 设置omap header

```
$ rados setomapheader <obj-name> <val>
```

#### 2.3.26 转换tmap为omap

TODO

#### 2.3.27 watch

```
$ rados watch -p <pool-name> <obj_name>
```

watch是一个“监听”，可以接受到同一个对象notify的消息。

#### 2.3.28 notidy

发送消息给对象watch的一方：

```
$ rados notify -p <pool_name> <obj_name> <message>
```

#### 2.3.39 列出对象所有watcher

```
$ rados listwatchers -p <pool_name> <obj_name>
```

#### 2.3.40 set-alloc-hint

TODO

### 2.4 IMPOER & EXPORT

#### 2.4.1 将pool内容导出到文件

```
$ rados export -p <pool-name> <outfile>
```

#### 2.4.2 导入对象到pool

```
$ rados import -p [--dry-run] [--no-overwrite] <infile>
```

### 2.5 ADVISORY LOCKS

TODO:

### 2.6 SCRUB&REPAIR

#### 2.6.1 列出不完成的pg

```
$ rados list-inconsistent-pg <pool>
```

#### 2.6.2 列出pg中不完成的对象

```
$ rados list-inconsistent-obj <pgid>
```

#### 2.6.3 列出pg中不完成的snap信息

```
$ rados list-inconsistent-snapset <pgid> 
```

### 2.7 CACHE POOL相关

TODO：暂时不使用




## 三、rbd

### 3.1 基础操作

#### 3.1.1 创建块设备镜像

```
$ rbd create <image-name> --size <megabytes> --pool <pool-name>  [--image-format 1|2] [--image-feature  <feature>]
```

#### 3.1.2 列出pool中镜像

```
$ rbd ls -p <pool-name>
```

#### 3.1.3 获取镜像信息

```
$ rbd info -p <pool-name> <image-name>
```

返回包括大小、版本、特性等信息。

#### 3.1.4 修改镜像大小

```
$ rbd resize --size <size> -p <pool-name> <images-name>
```

注：一般只允许调整大。

#### 3.1.5 删除镜像

```
$ 	rbd rm {image-name} -p {pool-name}
```

#### 3.1.6 镜像使用kernel映射到块

```
# map
$ rbd map {image-name} -p {pool-name}

# 查看map情况
$ rbd showmapped

# 取消映射
$ rbd unmap {image-name} -p {pool-name}
```

注意：默认情况下，创建的image版本是2，支持layering, exclusive-lock, object-map, fast-diff, deep-flatten特性。但是CentOS 7 3.10的内核仅支持layering特性，map时会失败。

可以使用以下解决方案：

创建image时仅开启layering特性

```
$ rbd create <image-name> --size <megabytes> --pool <pool-name>  --image-format 2 --image-feature  layering
```

或者禁用现有镜像的除了layering特性。

#### 3.1.7 启用/禁用镜像特性

```
$ rbd feature enable <pool-name>/<image-name> <feature-name>
$ rbd feature disable <pool-name>/<image-name> <feature-name>
```

所有特性：layering, exclusive-lock, object-map, fast-diff, deep-flatten

注意：如果开启了fast-diff/object-map特性，需要重建object map：

```
$ rbd object-map rebuild <pool-name>/<image-name>
```

另：deep-flatten只能在创建时指定。现有镜像只能进行disable操作。

#### 3.1.8 查看镜像以及其快照空间使用情况

```
$ rbd du <poolname>/<image-name>
```

获取镜像预分配空间（总空间）以及实际使用空间。

#### 3.1.9 镜像元数据使用

为镜像设置key-value元数据对，无特殊格式要求。

```
# 设置
$ rbd image-meta set <pool-name>/<image-name> <key> <value>

# 列出所有meta
$ rbd image-meta list  <pool-name>/<image-name>

# 获取meta值
$ rbd image-meta get <pool-name>/<image-name> <key>

# 删除meta
$ rbd image-mata remove <pool-name>/<image-name> <key>
```

#### 3.1.10 重命名镜像

```
$ rbd rename <pool-name>/<image-name> <pool-name>/<image-name>
```

注：只能在同一个pool中。

#### 3.1.11 复制镜像

```
$ rbd cp <pool-name>/<image-name> <pool-name>/<image-name>
```

可以跨pool。

### 3.2 镜像快照

#### 3.2.1 创建镜像快照

```
$ rbd --pool {pool-name} snap create --snap {snap-name} {image-name}
$ rbd snap create {pool-name}/{image-name}@{snap-name}
```

#### 3.2.2 列出镜像的所有快照

```
$ rbd --pool {pool-name} snap ls {image-name}
$ rbd snap ls {pool-name}/{image-name}
```

#### 3.2.3 回滚快照

```
$ rbd snap rollback {pool-name}/{image-name}@{snap-name}
$ rbd --pool {pool-name} snap rollback --snap {snap-name} {image-name}
```

注：回滚操作会从快照重写镜像，需要花费的实际跟镜像大小关联。建议从快照创建clone一个新的镜像，推荐方式。
已经挂载的rbd设备，在回滚后可能会发现变更还在。

#### 3.2.4 删除快照

```
# 删除单个快照
$ rbd --pool <pool-name> snap rm --snap <snap-name> <image-name>
$ rbd snap rm <pool-name-/<image-name>@<snap-name>

# 删除镜像所有快照
$ rbd --pool {pool-name} snap purge {image-name}
$ rbd snap purge {pool-name}/{image-name}
```
注：如果有使用快照clone了新镜像，那么在删除前需要flatten操作。

#### 3.2.5 重命名快照

```
$ rbd snap rename <pool-name>/<image-name>@<original-snapshot-name> <pool-name>/<image-name>@<new-snapshot-name>
```

#### 3.2.6 保护快照

在从快照clone之前，必须要对快照进行保护，防止删除。

```
$ rbd --pool {pool-name} snap protect --image {image-name} --snap {snapshot-name}
$ rbd snap protect {pool-name}/{image-name}@{snapshot-name}
```

#### 3.2.7 克隆快照

可以跨pool进行，操作的快照必须是被保护的。

```
$ rbd --pool {pool-name} --image {parent-image} --snap {snap-name} --dest-pool {pool-name} --dest {child-image}
$ rbd clone {pool-name}/{parent-image}@{snap-name} {pool-name}/{child-image-name}
```

#### 3.2.8 列出快照克隆镜像

找出以某个快照clone的所有镜像

```
$ rbd --pool {pool-name} children --image {image-name} --snap {snap-name}
$ rbd children {pool-name}/{image-name}@{snapshot-name}
```

#### 3.2.9 Flattening Cloned Images

填充克隆的快照，将快照填充到镜像中，并且解除镜像和快照的关系。

```
$ rbd --pool <pool-name> flatten --image <image-name>
$ rbd flatten <pool-name>/<image-name>
```

注：会使用更多的空间，测试中快照仅占用了5M左右，克隆镜像未修改，占用0。填充后，克隆镜像变为与镜像大小一致。

#### 3.2.10 取消快照保护

```
$ rbd --pool {pool-name} snap unprotect --image {image-name} --snap {snapshot-name}
$ rbd snap unprotect {pool-name}/{image-name}@{snapshot-name}
```

#### 3.2.11 查看快照差异

```
$ rbd diff {pool-name}/{image-name}@{snapshot-name}
```

#### 3.2.12 导出/导入镜像&diff

```
# 导出镜像/快照到文件
$ rbd export {pool-name}/{image-name}[@{snapshot-name}] {path}

# 导出快照与上一个快照/镜像的区别
$ rbd export-diff  {pool-name}/{image-name}@{snapshot-name} {path}

# 导入镜像
$ rbd import --dest-pool {pool-name} --dest {image-name}  {path}
$ 

# 导出diff（快照）
$ rbd import-diff --pool {pool-name} --image {image-name} {path}
```

### 3.3 rbd mirror相关

TODO，暂时不使用。

## 四、radosgw-admin

使用格式：

```
usage: radosgw-admin <cmd> [options...]
```

### 4.1 用户管理

两种用户：

 - User：S3接口使用
 - Subuser：Swift接口使用。一个Subuser与一个user对应。

 这里仅以S3接口为例。
 
 总体命令：
 
 ```
 radosgw-admin user <create|modify|info|rm|suspend|enable|check|stats> <--uid={id}> [other-options]
 ```
 
#### 4.1.1 多租户
 
 创建一个用户: testx$tester
 
 ```
 $ radosgw-admin --tenant testx --uid tester --display-name "Test User" --access_key TESTER --secret test123 user create
{
    "user_id": "testx$tester",
    "display_name": "Test User",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "testx$tester",
            "access_key": "TESTER",
            "secret_key": "test123"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "max_size_kb": -1,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "max_size_kb": -1,
        "max_objects": -1
    },
    "temp_url_keys": []
}
 ```
 
 
 
#### 4.1.2 创建用户
 
 ```
 # radosgw-admin user create --uid=<id> \
[--key-type=<type>] [--gen-access-key|--access-key=<key>]\
[--gen-secret | --secret=<key>] \
[--email=<email>] --display-name=<name>
 ```
 
#### 4.1.3 获取用户信息
 
 ```
 # radosgw-admin user info --uid=<uid>
 ```
 
#### 4.1.4 修改用户信息
 
 例如，修改某个用户的显示名称：
 
 ```
 # radosgw-admin user modify --uid=<uid> --display-name="XXXXX"
 ```
 
#### 4.1.5 启用和暂停用户
 
 用户创建完毕后，默认为启用状态（enabled)。可以使用以下命令暂停使用：
 
 ```
 # radosgw-admin user suspend --uid=<uid>
 ```
 
 再次启用用户：
 
 ```
 # radosgw-admin user enable --uid=<uid>
 ```
 
#### 4.1.6 移除用户
 
 ```
 # radosgw-admin user rm --uid=<uid> [--purge-keys] [--purge-data]
 ```
 
  - Purge Keys：删除UID对应所有keys
  - Purge Data：删除UID对应所有数据
 
 
#### 4.1.7 创建和移除key
 
 创建key：
 
 ```
 # radosgw-admin key create --uid=<uid> --key-type=s3 --gen-access-key|--access-key=<key> --gen-secret|--secret=<key>
 ```
  
 移除key：
 
 ```
 # radosgw-admin key rm --uid=<uid? --key-type=s3 --access-key=<key>
 ```
  
#### 4.1.8 添加管理能力
 
 Ceph支持通过REST接口执行管理功能，默认情况下，用户是不具备访问这些API的权限。可以使用以下命令授予用户可以执行管理功能的权限：
 
 ```
 # radosgw-admin caps add --uid={uid} --caps={caps}
 
 // 示范
 # --caps="[users|buckets|metadata|usage|zone]=[*|read|write|read, write]"
 ```
 
 移除管理权限：
 
 ```
 # radosgw-admin caps remove --uid={uid} --caps={caps}
 ```
 
### 4.2 bucket&object

管理Bucket信息。

#### 4.2.1 列出所有Bucekt

 ```
 # radosgw-admin buckets list
 ```

#### 4.2.2 link/unlink

更换bucket的owner（可以实现用户A访问用户B的bucekt，但此时用户B无法访问）：

```
 # radosgw-admin bucket link --bucket=<bucket> --bucket-id=<id> --uid=<uid>
```

取消link（恢复原先的bucekt owner）：

```
 # radosgw-admin bucket unlink --bucket=<bucket> --bucket-id=<id> --uid=<uid>
```

#### 4.2.3 bucket信息

获取Bucekt信息：

```
 # radosgw-admin bucket stats --bucket=<bucket>
```
 
#### 4.2.4 删除bucekt
 
 删除Bucket,如果bucket中对象不为空，需要--purge-objects参数：
 
 ```
  # radosgw-admin bucekt rm --bucket=<bucket> [--purge-objects]
 ```
 
#### 4.2.5 bucket check
 
 todo
 
#### 4.2.6 删除object
 
 ```
 # radosgw-admin object rm --bucket=<bucket> --object=<object>
 ```
 
#### 4.2.7 unlink object
 
 todo 操作失败
 
 ```
 # radosgw-admin object unlink --bucket=test111 --object='2'
 ```
 
#### 4.2.8 objects expire
 
 TODO
 
 
 
### 4.3 配额管理

#### 4.3.1 用户设置配额
 
```
 # radosgw-admin quota set --quota-scope=user --uid=<uid> [--max-objects=<num objects>] [--max-size=<max size>]
```

注意：如果设置的限制为负数，意思为无限制。设置完毕后不会生效。

#### 4.3.2 开启和禁用用户配额

在设置用户配额后，需要开启：

```
$ radosgw-admin quota enable --quota-scope=user --uid=<uid>
```

开启完毕后，如果达到限制客户端会提示：

```
S3ResponseError: 403 Forbidden
```
 
如果已经达到限制，现有数据不会做删除。

禁用配额：

```
$ radosgw-admin quota disable --quota-scope=user --uid=<uid>
```


#### 4.3.3 设置Bucket配额

为某个bucket设置配额：

```
$ radosgw-admin quota set --quota-scope=bucket --bucket=<bucket> [--max-objects=<num objects>] [--max-size=<max size]
```

为用户设置bucekt设置配额：

```
radosgw-admin quota set --quota-scope=bucket --uid=<uid> [--max-objects=<num objects>] [--max-size=<max size]
```

#### 4.3.4 开启/禁用Bucket配额

为bucekt开启配额限制：

```
$ radosgw-admin quota enable --quota-scope=bucket --bucket=<bucket>
```

为用户开启bucket配额限制：

```
$ radosgw-admin quota enable --quota-scope=bucket --uid=<uid>
```

备注：实际测试中，发现配额设置不准确。例如开启了用户bucket配额，创建一个新Bucekt，实际上传的对象数量可以超过限制（限制为20，实际传输了49后无法上传）


#### 4.3.4 获取配额设置

获取用户配额设置:

```
$ radosgw-admin user info --uid=<uid>
```

获取bucket配额：

```
$ radosgw-admin bucket stats --bucket=<bucket>
```

#### 4.3.5 配额更新

配额更新：

```
$ radosgw-admin user stats --uid=<uid> --sync-stats
```

备注：官方注释更新后需要手动触发更新，实际测试结果会自动更新

#### 4.3.6 获取配额使用状态

查询用户配额使用状态：

```
$ radosgw-admin user stats --uid=<uid>
```


### 4.4 Usage&Log相关

用于显示rgw记录的用户操作。

注意：
默认情况下，Usage和Log信息并未记录，以下命令可能会返回空值或无法找到。
开启方式：
在rgw配置文件中加入以下配置（需要重启）

```
rgw_enable_usage_log=true
rgw_enable_ops_log=true
```

#### 4.4.1 显示Usage信息

```
$ radosgw-admin usage show [--uid=<uid>] [--start-date=<date>] [--end-date=<date>]
```

其中，
	- 开始时间：--start-date，需要显示开始的时间，格式: yyyy-mm-dd [HH:MM:SS],例如，2017-02-05、2017-02-05 14:00:00
	- 结束时间：--end-date，需要显示结束的时间，格式: yyyy-mm-dd [HH:MM:SS],例如，2017-02-06、2017-02-06 16:00:00

另：官方文档显示，时间的筛选是基于小时。

#### 4.4.2 删除Usage

使用较为频繁时，usgae log会占用较多空间，可以使用trim对于某个用户或者所有用户对usage进行清理。

```
$ radosgw-admin usage trim [--uid=<uid>] [--start-date=<date>] [--end-date=<date>]
```

#### 4.4.3 显示所有Log对象

```
$ radosgw-admin log list
```

#### 4.4.4 获取指定log
获取bucket下某个小时内详细的操作记录，包含任意一个操作的详细信息。
由于记录信息过于详细，非必须不开启该日志。


```
$ radosgw-admin log show --bucket=<bucket> --bucket-id=<id>  --date=<date>
```

其中，date格式为yyyy-mm-dd-hh，例如2017-02-06-14

#### 4.4.5 删除指定log

```
$ radosgw-admin log show --bucket=<bucket> --bucket-id=<id>  --date=<date>
```


从zonegroup中移除非local的zone（适用于muilt site中，移除非local的zone，例如另外一个集群故障。区别于zone delete只能移除local的zone）：

```
$ radosgw-admin zonegroup remove --zone-id=${zone-id}
```

移除一个local的zone：

```
$ radosgw-admin zone delete --zone-id=${zone-id}
```

### 4.5 Metadata相关

#### 4.5.1 获取metadata列表

```
$ radosgw-admin metadata list
```

返回值为list，一般有bucket、bucket.instance、user三个值。

#### 4.5.2 获取metadata数据

获取用户元数据：

```
$ radosgw-admin metadata get user:<uid>
```

获取bucket元数据：

```
$ radosgw-admin metadata get bucket:<bucket>

$ radosgw-admin metadata get bucket.instance:<bucket>:<id>
```


#### 4.5.3 设置metadata

未测试

```
$ radosgw-admin metadata put xxxx < jsonfile.json
```

#### 4.5.4 删除metadata

未测试

```
$ radosgw-admin metadata rm xxx
```

#### 4.5.5 列出metadata log

记录了所有metadata变化相关的日志，包括用户创建/删除，bucket创建/删除等。

```
$ radosgw-admin mdlog list
```

#### 4.5.6 删除指定mdlog

TODO:暂时未执行成功

```
$ radosgw-admin mdlog trim 
```

#### 4.5.7 mdlog状态

TODO:意义不明确

```
$ radosgw-admin mdlog status
```


### 4.6 Realm&Period相关（muiltsite)

Realm是zonegroup的容器，可以将zonegroup放置在多个集群中。

#### 4.6.1 Realm创建

```
$ radosgw-admin realm create --rgw-realm=<realm> [--default]
```

--default等同于执行创建后再执行radosgw-admin realm default。

#### 4.6.2 Realm删除

```
$ radosgw-admin realm delete --rgw-realm=<realm>
```

#### 4.6.3 获取Realm信息

```
$ radosgw-admin realm get [--rgw-realm=<realm>]
```

如果不指定--rgw-realm，获取的信息为默认realm信息。
信息包含realm的id、名称、当前period和epoch

获取默认realm id：

```
$ radosgw-admin realm get_default
```

#### 4.6.4 列出realm信息

列出所有realm信息：

```
$ radosgw-admin realm list
```

列出所有realm对应period：

```
$ radosgw-admin realm list-periods
```

#### 4.6.5 重命名realm

```
$ radosgw-admin realm rename --rgw-realm=<realm>  --realm-new-name=<realm new name>
```

#### 4.6.6 设置realm

```
$ radosgw-admin realm set --rgw-realm=<realm>--infile=jsonfile
```


####  4.6.7 设置默认realm

```
$ radosgw-admin realm default --rgw-realm=<realm>
```

#### 4.6.8 删除realm中zonegroup
TODO

```
$ 
```

#### 4.6.9 远程获取realm

```
$ radosgw-admin realm pull --url=<url> --access_key=<key> --secret=<key>
```

其中,--url后接另外一个ceph集群的radosgw endoint。

#### 4.6.10 准备新period

暂不清楚作用,官方将会在10.2.6移除。

```
$ radosgw-admin period prepare
```

#### 4.6.11 删除period

```
$ radosgw-admin period delete --period=<id> 
```

#### 4.6.12 获取period

```
$ radosgw-admin period get --period=<id> 
```

#### 4.6.13 获取当前period ID

```
$ radosgw-admin period get-current
```

#### 4.6.14 获取period

在建立muilt site过程中，需要在secondary zone所在集群获取period信息：

```
$ radosgw-admin realm pull --url=<url>
--access-key=<key> --secret=<key>
```

#### 4.6.15 推送period

将period推送到节点

```
$ radosgw-admin period push --url=<url> --access-key=<key> --secret=<key>
```

#### 4.6.16 列出所有period

```
$ radosgw-admin period list
```

#### 4.6.17 更新period

```
$ radosgw-admin period update [--commit] [--rgw-zone=<zone>]
```

如果未执行update后未加入--commit，需要单独执行period commit子命令。


### 4.7 Zonegroup&Zone相关

#### 4.7.1 创建zonegroup

```
$ radosgw-admin zonegroup create --rgw-realm=<realm> --rgw-zonegroup=<zonegroup> [--endpoints=<list>] [--master] [--default]
```

其中，--endpoints后指定zonegroup的radosgw endpoint，--master表示是否是master zonegroup（该zonegroup进行所有系统全局性操作，必须），--default指定realm中默认的zonegroup（radogw-admin zonegroup default）。

#### 4.7.2 默认zonegroup

```
$ radosgw-admin zonegroup default --rgw-realm=<realm> --rgw-zonegroup=<zonegroup>
```

#### 4.7.3 获取zonegroup信息

```
$ radosgw-admin zonegroup get --rgw-zonegroup=<zonegroup>
```

#### 4.7.4 删除zonegroup

```
$ radosgw-admin zonegroup delete --rgw-zonegroup=<zonegroup>
```

#### 4.7.5 修改zonegroup信息

方式一：

```
$ radosgw-admin zonegroup modify --rgw-zonegroup=<zonegroup> [--endpoints=<urls>]...
```

方式二（通过提交json配置文件修改）：

```
$ radosgw-admin zonegroup set --rgw-zonegroup=<zonegroup> --infile=jsonfile
```


#### 4.7.6 移除zonegroup中的zone

TODO，可以用于移除非local的zone：

```
$ radosgw-admin zonegroup remove
```

#### 4.7.7 重命名zonegroup

```
$ radosgw-admin zonegroup rename --rgw-zonegroup=<zonegroup> --zonegroup-new-name=<zonegroup>
```

#### 4.7.8 列出所有zonegroup

列出集群中所有的zonegroup，非realm级别：

```
$ radosgw-admin zonegroup list
```

#### 4.7.9 获取zonegroup-map

官方解释关于zonegroup-map：一个保存着整个系统映射关系的配置结构，例如那个zonegroup是master，不同zonegroup之间的关系，以及配置（例如存储策略）

```
$ radosgw-admin zonegroupmap get
```

#### 4.7.10 设置zonegroup-map

```
$ radosgw-admin zonegroup-map set --infile=jsonfile
```

#### 4.7.11 创建zone

```
$ radosgw-admin zone create --rgw-zonegroup=<zonegroup> --rgw-zone=<zone> [--endpoints=<urls>] [--master] [--default]
```

#### 4.7.12 删除zone

注意：只能删除local zone

```
$ radosgw-admin zone delete --rgw-zonegroup=<zonegroup> --rgw-zone=<zone> 
```

#### 4.7.13 获取zone信息

```
$ radosgw-admin zone get --rgw-zonegroup=<zonegroup> --rgw-zone=<zone>
```

#### 4.7.14 修改zone信息

方式一：

```
$ radosgw-admin zone modify --rgw-zone=<zone> ...
```

方式二：

```
$ radosgw-admin zone set --rgw-zonegroup=<zonegroup> --rgw-zone=<zone> --infile=jsonfile
```

#### 4.7.14 列出所有zone

列出集群中所有的zone：

```
$ radosgw-admin zone list
```

#### 4.7.15 重命名zone

```
$ radosgw-admin zone rename --rgw-zone=<zone> --zone-new-name=<zone>
```


### 4.8 gc相关

在进行删除、覆盖对象操作时，这些对象都需要进行删除操作，由垃圾回收线程进行周期性批量删除。

#### 4.8.1 列出待gc任务

```
$ radosgw-admin gc list
```

备注：如果不加入--include-all，仅会列出超时未回收的任务。

#### 4.8.2 手动进行gc任务

```
$ radosgw-admin gc process
```
