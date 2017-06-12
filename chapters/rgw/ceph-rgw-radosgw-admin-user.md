# 用户管理
> 注意: radosgw-admin命令用户不能列出所有的用户

## 创建用户
创建一个id为frank6866的用户

```
# radosgw-admin user create --uid=frank6866 --display-name=frank6866
{
    "user_id": "frank6866",
    "display_name": "frank6866",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "frank6866",
            "access_key": "xxx",
            "secret_key": "xxx"
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


## 查看用户信息
查看id为frank6866的用户信息  

```
# radosgw-admin user info --uid=frank6866
{
    "user_id": "frank6866",
    "display_name": "frank6866",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "frank6866",
            "access_key": "xxx",
            "secret_key": "xxx"
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


## suspend用户
suspend id为frank6866的用户

```
# radosgw-admin user suspend --uid=frank6866
{
    "user_id": "frank6866",
    "display_name": "frank6866",
    "email": "",
    "suspended": 1,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "frank6866",
            "access_key": "xxx",
            "secret_key": "xxx"
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

suspend用户后，用户的suspended字段会变为1

## enable用户
用户创建后默认处于enabled状态，在suspend用户后，可以重新enable用户

```
# radosgw-admin user enable --uid=frank6866
{
    "user_id": "frank6866",
    "display_name": "frank6866",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "frank6866",
            "access_key": "xxx",
            "secret_key": "xxx"
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

## 用户配额管理
### 设置配置
设置用户frank6866的最大使用空间为10G

```
# radosgw-admin quota set --quota-scope=user --uid=frank6866 --max-size=10G
# radosgw-admin user info --uid=frank6866
{
    "user_id": "frank6866",
    "display_name": "frank6866",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "frank6866",
            "access_key": "xxx",
            "secret_key": "xxx"
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
        "max_size_kb": 10485760,
        "max_objects": -1
    },
    "temp_url_keys": []
}
```

### 启用配额
设置配额后，默认并没有启用，需要启用配额:  

```
# radosgw-admin quota enable --quota-scope=user --uid=frank6866
# radosgw-admin user info --uid=frank6866
{
    "user_id": "frank6866",
    "display_name": "frank6866",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "frank6866",
            "access_key": "xxx",
            "secret_key": "xxx"
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
        "enabled": true,
        "max_size_kb": 10485760,
        "max_objects": -1
    },
    "temp_url_keys": []
}
```


## 删除用户
删除id为frank6866的用户

```
# radosgw-admin user rm --uid=frank6866
```

