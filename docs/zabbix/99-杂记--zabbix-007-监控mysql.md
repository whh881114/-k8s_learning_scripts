# 监控mysql

## 说明
- mysql监控笔记进度晚于haproxy，经过haproxy的折腾后，还是打算采用`MySQL by Zabbix agent`实现，优先选择带有`agent`的模板实现。

- 官方文档：https://www.zabbix.com/cn/integrations/mysql

- **文档中记录的密码使用mkpasswd生成随机密码，此外，此密码仅用于个人实验环境。**


## 配置过程
- 按照官方文档处理即可。

- `template_db_mysql.conf`下载地址（根据agent版本下载）：https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/db/mysql_agent/template_db_mysql.conf?at=refs%2Fheads%2Frelease%2F6.0

- mysql数据库监控用户名密码分别为："zbx_monitor"和"dr_rfrfYz*fa10xtU@s#wfzzplev_lqe"。


## 额外记录
- mysql5.7初始化密码。
    ```shell
    mysql> show databases;
    ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
    mysql> alter user 'root'@'localhost' identified by 'rhhy4rsyx4vvgpLjj<tvfrmojDxfdggw';
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> flush privileges;
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> quit
    Bye
    ```

- mysql5.7配置zabbix监控用户。
    ```shell
    mysql> CREATE USER 'zbx_monitor'@'%' IDENTIFIED BY 'dr_rfrfYz*fa10xtU@s#wfzzplev_lqe';
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> GRANT REPLICATION CLIENT,PROCESS,SHOW DATABASES,SHOW VIEW ON *.* TO 'zbx_monitor'@'%';
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> flush privileges;
    Query OK, 0 rows affected (0.00 sec)
    
    mysql> quit
    Bye
    ``