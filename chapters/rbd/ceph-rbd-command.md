# rbd命令
通过rbd命令，我们可以创建、列出、查看或者移除块设备镜像，还可以克隆镜像、创建快照、查看快照、恢复快照等。

> 在ceph中，一个rbd设备称为image(镜像)

## 创建块设备
名为"rbd"的pool是Ceph中默认用来存放块设备的pool，使用rbd create命令默认会在rbd这个pool中创建块设备。  

```
# rbd create --size 512 frank6866
```

如果需要在指定的pool，比如pool-frank6866这个pool中创建块设备，可以使用pool名作为前缀

```
# rbd create --size 512 pool-frank6866/frank6866
```


> --size的单位是MBytes

## 列出块设备
名为"rbd"的pool是Ceph中默认用来存放块设备的pool，使用rbd ls命令默认会列出rbd这个pool中的块设备。  

```
# rbd ls
frank6866
```


查看pool-frank6866这个pool中的块设备:  

```
# rbd ls pool-frank6866
frank6866
```


## 查看块设备的详细信息
```
# rbd info pool-frank6866/frank6866
rbd image 'frank6866':
	size 512 MB in 128 objects
	order 22 (4096 kB objects)
	block_name_prefix: rbd_data.1ad6e2ae8944a
	format: 2
	features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
	flags:
```

* size: 512 MB in 128 objects，表示该块设备的大小是512MBytes，分布在128个objects中，RBD默认的块大小是4MBytes
* order: order 22 (4096 kB objects)，指定RBD在OSD中存储时的block size，block size的计算公式是1<<order(单位是bytes)，在本例中order=22，所有block size是1<<22bytes，也就是4096KBytes。order的默认值是22，RBD在OSD中默认的对象大小是4MBytes
* format: rbd image的格式，format1已经过期了。现在默认都是format2，被librbd和kernel3.11后面的版本支持
* block_name_prefix: 表示这个image在pool中的名称前缀，可以通过rados -p pool-frank6866 ls | grep rbd_data.1ad6e2ae8944a命令查看这个rbd image在rados中的所有object。但是要注意的是，刚创建的image，如果里面没有数据，不会在rados中创建object，只有写入数据时才会有。size字段中的objects数量表示的是最大的objects数量

## 调整块设备的大小
调大块设备的大小:  

```
# rbd resize --size 1024 pool-frank6866/frank6866
Resizing image: 100% complete...done.

# rbd info pool-frank6866/frank6866
rbd image 'frank6866':
	size 1024 MB in 256 objects
	order 22 (4096 kB objects)
	block_name_prefix: rbd_data.1ad6e2ae8944a
	format: 2
	features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
	flags:
```


减小块设备的大小:  

```
# rbd resize --size 256 pool-frank6866/frank6866 --allow-shrink
Resizing image: 100% complete...done.

# rbd info pool-frank6866/frank6866
rbd image 'frank6866':
	size 256 MB in 64 objects
	order 22 (4096 kB objects)
	block_name_prefix: rbd_data.1ad6e2ae8944a
	format: 2
	features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
	flags:
```	
	
## 删除块设备
```
# rbd rm pool-frank6866/frank6866
Removing image: 100% complete...done.

# rbd ls pool-frank6866
```


