# 配置zabbix监控haproxy.md

## 参考文档
- https://www.zabbix.com/cn/integrations/haproxy#haproxy_http

## 说明
- `HAProxy by HTTP`模板官方测试的是1.8。此模板不兼容haproxy-1.5.18版本，因为自动发现规则不生效。
- 使用rh-haproxy18替换haproxy。
