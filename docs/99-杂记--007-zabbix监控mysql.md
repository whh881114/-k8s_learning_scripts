# 99-杂记--007-zabbix监控mysql.md

## 说明
- mysql监控笔记进度晚于haproxy，经过haproxy的折腾后，还是打算采用`MySQL by Zabbix agent`实现，优先选择带有`agent`的模板实现。

- 官方文档：https://www.zabbix.com/cn/integrations/mysql


## 配置过程
- 按照官方文档处理即可。

- `template_db_mysql.conf`下载地址（根据agent版本下载）：https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/db/mysql_agent/template_db_mysql.conf?at=refs%2Fheads%2Frelease%2F6.0

- mysql数据库监控用户名密码分别为："zbx_monitor"和"dr_rfrfYz*fa10xtU@s#wfzzplev_lqe"。