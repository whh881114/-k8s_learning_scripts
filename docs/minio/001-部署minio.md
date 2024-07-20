# 部署minio


## 参考资料
- https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-multi-node-multi-drive.html


## 重点细节
- 报错处理，主机名需要规规范化命名，其磁盘所挂载的目录也同样需要规范化。需要去掉主机名里面的"0"，同时主机名需要能解析到。
```shell
FATAL Unable to prepare the list of endpoints:
Invalid ellipsis format in (http://minio-{01..04}.freedom.org:9000/data{00..01}),
Ellipsis range must be provided in format {N...M} where N and M are positive integers,
M must be greater than N,  with an allowed minimum range of 4.
```

- minio强烈建议使用xfs格式化磁盘，另外，磁盘不需要分区，直接使用mkfs.xfs进行格式化，方便磁盘扩容。
