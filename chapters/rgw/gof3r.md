2、gof3r
获取
通过url下载后，添加执行权限（chmod +x），放置到/usr/sbin目录下，即可直接使用。
 http://s3-c4-1.elenet.me/publictools/gof3r     （生产网络，办公室无法访问）
配置
gof3r通过读取环境变量的方式进行配置，环境变量如下：
export AWS_ACCESS_KEY_ID=access_key
export AWS_SECRET_ACCESS_KEY=secret_key
export AWS_REGION=default
基本操作：
上传本地文件：
gof3r cp gof3r --no-ssl --endpoint=s3-c4-1.elenet.me  s3://mysql0426/prefx/key localfile
stream上传：
<stream source> | gof3r put --no-ssl --endpoint=s3-c4-1.elenet.me -b bucketname -k /ssss
下载（-p指定本地路径，如果未指定，会输出到stdout）：
gof3r get --no-ssl --endpoint=s3-c4-1.elenet.me -b mysql0426 -k sss -p path

应用：DB备份

qpress地址：http://repo.percona.com/release/6/RPMS/x86_64/qpress-11-1.el6.x86_64.rpm

完全备份：
/usr/bin/innobackupex --defaults-file=/var/lib/mysql/3324/my.cnf --host=10.200.0.15 --port=3324 --user=tmp_yym --password=tmp_yym --no-lock --safe-slave-backup --throttle=400 --parallel=8 --stream=xbstream --compress --compress-threads=16 /tmp | s3cmd put - s3://mysql170428/app/full_backup
下载完全备份：
s3cmd get s3://mysql170428/app/full_backup LOCAL_PATH
解包：
xbstream -x <  LOCAL_PATH -C TARGET_PATH
解压缩qp文件（需要qpress）
cd TARGET_PATH
for i in $(find -name "*.qp"); do qpress -vd $i $(dirname ${i}) && rm -f $i; done
即可进行恢复。

复制本地文件：
s3cmd sync LOCAL_PATH s3://mysql170428/app/bin_log/      （必须以/结束）
复制文件到本地：
s3cmd sync s3://mysql170428/app/bin_log LOCAL_PATH     （S3 URL结束时不能有/）







