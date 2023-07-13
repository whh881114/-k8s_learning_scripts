# 配置zabbix监控haproxy.md

## 参考文档
- https://www.zabbix.com/cn/integrations/haproxy#haproxy_http


## 说明
- `HAProxy by HTTP`模板官方测试版本是1.8，在测试1.8版本时，结果发现系统判断haproxy服务没有启动。此外，此模板不兼容haproxy-1.5.18版本，因为自动发现规则不生效。

- `HAProxy by Zabbix agent`模板测试1.8通过，1.5不通过。

- 最终使用模板`HAProxy by Zabbix agent`。


## 备注
- 在使用模板`HAProxy by Zabbix agent`监控时，没有配置用户名密码认证。这个问题不大，毕竟配置的管理界面只能看，如果要保护，则可以用防火墙实现。

- 配置过程按模板说明步骤配置即可。