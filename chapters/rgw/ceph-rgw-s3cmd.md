# s3cmd
s3cmd是一个管理s3中对象的命令行工具，除了可以管理s3中的对象，还可以管理兼容s3接口的存储，比如Ceph rgw。

## 安装
### CentOS7
```
# pip install s3cmd
```


### macOS
```
brew install s3cmd
```

## 配置
生成配置文件，存储到rgw-26.cfg文件中

```
# s3cmd --configure -c ~/.s3cfg
```

~/.s3cfg文件需要修改的地方有两个

```
host_base = 10.10.10.10:7480
host_bucket = 10.10.10.10:7480/%(bucket)s
```


## 使用

### 创建bucket
创建一个名为b-frank6866的bucket

```
# s3cmd mb s3://b-frank6866
Bucket 's3://b-frank6866/' created
```

### 列出bucket

```
# s3cmd ls
16:11  s3://b-frank6866
```

### 上传对象
```
# s3cmd put /tmp/test.txt s3://b-frank6866
upload: '/tmp/test.txt' -> 's3://b-frank6866/test.txt'  [1 of 1]
 5 of 5   100% in    0s   121.90 B/s  done
```

> 上传时，使用-P选项可以将对象的权限为public

```
# s3cmd put -P /tmp/test.txt s3://b-frank6866
```

### 查看bucket中的对象
```
# s3cmd ls s3://b-frank6866
16:22         5   s3://b-frank6866/test.txt
```

输出的单位是Byte，s3://后面和之后的/之间是bucket的名称，最后面是对象的名称。  


### 查看bucket中对象大小
以byte为单位查看对象的大小

```
# s3cmd du s3://test_lifecycle
2902467869 5 objects s3://test_lifecycle/
```

以容易阅读的方式查看对象大小，注意会去尾，大小不大是误差较大

```
# s3cmd du -H s3://test_lifecycle
2G       5 objects s3://test_lifecycle/
```


### 下载对象
```
# s3cmd get s3://b-frank6866/test.txt /tmp/test2.txt
```


### 删除对象
```
s3cmd del s3://bucket/object
```

### 批量上传文件
```
s3cmd put ./*.txt s3://b-frank6866
```

### 上传目录
```
s3cmd sync LOCAL_DIR s3://bucket[/prefix]
```

### 下载目录
```
s3cmd sync s3://bucket[/prefix] LOCAL_DIR
```

### 删除bucket
```
s3cmd rb s3://bucketname
```




