# rgw简介
rgw是rados gateway的简称，是ceph基于librados提供的对象存储服务。

常见概念:  

* AccessKey: 长度为20的字符串，用来标识client的身份
* SecretKey: 长度为40的字符串，用来签名。
* Region: 区域，用来表示位置，不如北美、中国
* Bucket: 存储对象的容器，Bucket中只能存储object，不能存储bucket
* object: 对象，存储的基本单元
* key: object的名称



