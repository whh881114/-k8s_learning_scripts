# 99-杂记--007-zabbix监控mysql.md

## 说明
- 以zabbix-6.0-lts版本中查看到有`MySQL by ODBC`模板，想着监控下zabbix-server的mysql，因为使用ODBC方式来监控是很方便的，但是，此功能需要编译源码，指定编译命令。
    - https://www.zabbix.com/documentation/6.0/en/manual/config/templates_out_of_the_box/odbc_checks
    - https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/db/mysql_odbc/README.md?at=refs%2Fheads%2Frelease%2F6.0
    - https://www.zabbix.com/documentation/6.0/en/manual/config/items/itemtypes/odbc_checks?hl=ODBC%2Cmonitoring


## 配置过程


