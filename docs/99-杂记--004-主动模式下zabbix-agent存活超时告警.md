# 99-杂记--004-主动模式下zabbix-agent存活超时告警.md

## 说明
- zabbix-6.0-lts版本下，此模板"Linux by Zabbix agent active"中有个监控agent是否存活的触发器（Zabbix agent is not available），其检查周期为30m。

- 很多数据采集周期是一分钟，显然，这个存活检查时间太长了，需要调整成1分钟。

- 触发器原始值：`nodata(/Linux by Zabbix agent active/agent.ping,{$AGENT.NODATA_TIMEOUT})=1，这里面的宏{$AGENT.NODATA_TIMEOUT}`。

- 触发器调整后的值：`nodata(/Linux by Zabbix agent active/agent.ping,1m)=1`。

