# 配置zabbix监控haproxy.md

## 说明
- 使用监控模板：`Template DB MySQL by Zabbix agent`。

## 部署说明
- 使用官方说明即可。
- mysql配置文件：https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/db/mysql_agent

```shell
Requirements for template operation:
1.Install Zabbix agent and MySQL client.
2.Copy template_db_mysql.conf into folder with Zabbix agent configuration (/etc/zabbix/zabbix_agentd.d/ by default). Don't forget to restart zabbix-agent. 
3.Create MySQL user for monitoring. For example:
CREATE USER 'zbx_monitor'@'%' IDENTIFIED BY '<password>';
GRANT REPLICATION CLIENT,PROCESS,SHOW DATABASES,SHOW VIEW ON *.* TO 'zbx_monitor'@'%';
For more information read the MySQL documentation https://dev.mysql.com/doc/refman/8.0/en/grant.html , please. 
4.Create .my.cnf in home directory of Zabbix agent for Linux (/var/lib/zabbix by default ) or my.cnf in c:\ for Windows. For example:
[client]
user='zbx_monitor'
password='<password>'


You can discuss this template or leave feedback on our forum https://www.zabbix.com/forum/zabbix-suggestions-and-feedback/384189-discussion-thread-for-official-zabbix-template-db-mysql

Template tooling version used: 0.38
```