# 重置zabbix管理员密码


## 说明
- **文档中记录的密码使用mkpasswd生成随机密码，此外，此密码仅用于个人实验环境。**
- 针对zabbix-5.0-lts版本。


## 配置说明
- 自定义密码：`htpasswd -bnBC 10 "" "<NEW_PASSWORD>" | tr -d ":"`。
- 进入mysql，修改密码：
  ```shell
  use zabbix;
  update users set passwd="NEW_PASSWORD" where userid=1;
  flush privileges;
  quit;
  ```