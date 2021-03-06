# S3简介

地址: [https://aws.amazon.com/cn/s3/](https://aws.amazon.com/cn/s3/)

官网介绍如下:

> Amazon Simple Storage Service (Amazon S3) 是一种对象存储，它具有简单的 Web 服务接口，可用于在 Web 上的任何位置存储和检索任意数量的数据。它能够提供 99.999999999% 的持久性，并且可以在全球大规模传递数万亿对象。

**注意：官网介绍的11个9的表示的是数据的持久性，就是数据不会丢；并不表示数据会有11个9的可访问性。**



s3基本概念：

* access_key、secret_key：认证需要的密钥对，由Ceph管理人员提供，需要妥善保存。
* bucket：存储桶，类似于顶层容器的概念，在使用前需要创建，bucket名称在一个集群中唯一。
* perfix：前缀，类似于底层文件夹概念，可以用于区分同名对象。




## 对比

| 公司 | 产品| 数据持久性 | 月可靠性 | 年可靠性
|------|------|----|-----|-----
| AWS | S3(Simple Storage Service) | 99.999999999%(11个9) | 99.9% | 99.99%
| 阿里云 | OSS(Object Storage Service) | 99.9999999%(9个9) | 99.9%
| 腾讯云 | COS(Cloud Object Storage) | 99.999999999%(11个9) |




