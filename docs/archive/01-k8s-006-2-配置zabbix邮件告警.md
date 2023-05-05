# 配置zabbix邮件告警


## 参考文档
- https://jingyan.baidu.com/article/77b8dc7fffb07d2075eab62b.html
- https://blog.csdn.net/weixin_30852419/article/details/95364044
- https://www.cnblogs.com/qinxu/p/9838778.html
- https://www.cnblogs.com/5444de/p/13158484.html

## 邮件客户端配置（可忽略）
- 系统为CentOS-7-x86_64，需要安装postfix, sendmail和mailx。
- 修改/etc/mail.rc配置文件，在文件中添加以下内容，其中smtp-auth-password为"邮箱授权码"，使用个人邮箱时不需要配置证书。
    ```shell
    set from=roy_wong_20210324@163.com
    set smtp=smtp://smtp.163.com
    set smtp-auth-user=roy_wong_20210324@163.com
    set smtp-auth-password=XXXXXX
    set smtp-auth=login
    ```
- 测试：echo "zabbix test mail" |mail -s "zabbix" roy_wong_20210324@163.com


## 意外收获--zabbix自带邮件告警
- 在zabbix-5.0-lts中，可以直接在告警媒介中配置即可，密码使用邮箱授权码即可。
- mail告警媒介。
  ![mail告警媒介](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--%E9%82%AE%E4%BB%B6%E5%91%8A%E8%AD%A601.png)
- mail告警配置细节。
  ![mail告警配置细节](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--%E9%82%AE%E4%BB%B6%E5%91%8A%E8%AD%A602.png)


## 配置Admin用户告警媒介
- 配置Admin用户告警媒介步骤一。
  ![配置Admin用户告警媒介步骤一](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--配置Admin用户告警媒介01.png)
- 配置Admin用户告警媒介步骤二。
  ![配置Admin用户告警媒介步骤二](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--配置Admin用户告警媒介02.png)
- 配置Admin用户告警媒介步骤三。
  ![配置Admin用户告警媒介步骤三](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--配置Admin用户告警媒介03.png)


## 配置动作
- 配置动作
    - ![动作01](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--配置触发器动作01.png)
    - ![动作02](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--配置触发器动作02.png)
    - ![动作03](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--配置触发器动作03.png)
    - ![动作04](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--配置触发器动作04.png)
    - ![动作05](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--配置触发器动作05.png)

- 故障发生主题：
  ```
  【故障发生】故障程度：{TRIGGER.STATUS} --  服务器：{HOSTNAME1}-{HOST.IP1} -- 故障名称：{TRIGGER.NAME}
  ```
- 故障恢复主题：
  ```
  【故障恢复】故障程度：{TRIGGER.STATUS} --  服务器：{HOSTNAME1}-{HOST.IP1} -- 故障名称：{TRIGGER.NAME}
  ```
- 故障发生/恢复内容：
  ```
  告警主机：{HOSTNAME1} {HOST.IP1}
  告警时间：{EVENT.DATE} {EVENT.TIME}
  告警等级：{TRIGGER.SEVERITY}
  告警信息：{TRIGGER.NAME}
  告警项目：{TRIGGER.KEY1}
  问题详情：{ITEM.NAME}:{ITEM.VALUE}
  当前状态：{TRIGGER.STATUS}:{ITEM.VALUE1}
  事件ID：{EVENT.ID}
  ```

## 告警测试结果
- 告警结果。
  ![邮件告警结果](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/zabbix-5.0-lts--邮件告警测试结果.png)