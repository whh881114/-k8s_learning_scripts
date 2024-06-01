# 监控mysql-v2

## 说明
- 现阶段使用`zabbix-agent2`客户端，模板使用`MySQL by Zabbix agent 2`，此次数据库则使用了`MySQL8.0`。

- **文档中记录的密码使用mkpasswd生成随机密码，此外，此密码仅用于个人实验环境。**


## 配置过程
- 配置文件：/etc/zabbix/zabbix_agent2.d/plugins.d/mysql.conf
- 修改内容：
  ```shell
  Plugins.Mysql.Default.User=zbx_monitor
  Plugins.Mysql.Default.Password=kcUnlVbymw8lsgx7gyxkaifhzae>sg
  ```
- 特别说明：也可以在监控主机上配置宏，这样只适用于一台主机上跑单个MySQL实例，所以更倾向于修改配置文件，通用性更强。


## 额外记录
- mysql8.0 root是无密码的，所以需要使用以下命令修改：`ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'new_password';`。
