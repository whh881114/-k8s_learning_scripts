# 监控elastic-8


## 说明
- 使用官方模板`Elasticsearch Cluster by HTTP`即可。

- **文档中记录的密码使用mkpasswd生成随机密码，此外，此密码仅用于个人实验环境。**


## 配置说明
- 根据模板配置宏即可，特别说明，elasticsearch开启x-pack功能，通信协议为`https`，所以需要配置三个宏即可。
  - {$ELASTICSEARCH.SCHEME}
  - {$ELASTICSEARCH.USERNAME}
  - {$ELASTICSEARCH.PASSWORD}