# 配置zabbix监控haproxy.md


## 参考文档
- https://www.zabbix.com/cn/integrations/haproxy#haproxy_http

## 说明
- 要求zabbix版本为5.0。
- 要求haproxy版本为1.8，所以需要安装haproxy18包，而非haproxy。
- 详细版本查看官方文档即可。

## 主机宏配置
- {$HAPROXY.STATS.PORT} = 5001
- {$HAPROXY.USERNAME} = freedom
- {$HAPROXY.PASSWORD} = freedom