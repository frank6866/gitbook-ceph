# osd/pool/pg


pool是存储在ceph中对象的逻辑组，pool由pg(placement group)组成。

在创建pool的时候，我们需要提供pool中pg的数量和对象的副本数。


pool会将某个对象按照副本数分布在多个osd上，保证数据的可靠性。


* ceph集群可以有多个pool
* 每个pool有多个pg，pg数量在pool创建的时候指定好
* 一个pg包含多个对象
* pg分布在多个osd上面。第一个映射的osd是primary osd，后面的是secondary osd
* 很多pg映射到一个osd


# pg
pg(placement group)对客户单来说是不可见的，但在ceph集群中扮演着一个非常重要的角色；pg是Ceph执行re-balance时的基本单位。

为什么要引入pg这个概念？  
为了达到EB级别的存储容量，Ceph集群可能需要数千个OSD。Ceph客户端将对象存储在pool中，pool是集群中对象逻辑的集合，OSD是ceph中物理的集合，一般一个OSD对应一块物理磁盘；pool并不属于某个特定的OSD。存储在某个pool中的对象的个数很容易达到百万甚至千万的级别。对于一个系统来说，如果一个pool就有百万甚至千万的对象，这个系统很难追踪或维护所有对象的状态并且系统的性能还很好。在Ceph中，将对象归类到PG中，然后将PG映射到OSD上，来保证高效平衡每个OSD的容量。  

**在对象数量比较多时，跟踪pool中每一个对象的位置开销很大。**为了高效地跟踪对象的位置，Ceph将一个pool分为多个PG；先将对象分到PG中，然后再将PG放到primary OSD上。如果一个OSD挂了，Ceph会将存放在这个OSD上的所有PG移动或复制到别的地方





