# elastic-004-elasticsearch配置用户名密码


## 说明
- elastic版本为`8.9.0`。

- **文档中记录的密码使用mkpasswd生成随机密码，此外，此密码仅用于个人实验环境。**

## 安装后提示信息
  ```shell
  --------------------------- Security autoconfiguration information ------------------------------
  
  Authentication and authorization are enabled.
  TLS for the transport and HTTP layers is enabled and configured.
  
  The generated password for the elastic built-in superuser is : oioeXz6r7fpDxc8t4ELh
  
  If this node should join an existing cluster, you can reconfigure this with
  '/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <token-here>'
  after creating an enrollment token on your existing cluster.
  
  You can complete the following actions at any time:
  
  Reset the password of the elastic built-in superuser with 
  '/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic'.
  
  Generate an enrollment token for Kibana instances with 
   '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana'.
  
  Generate an enrollment token for Elasticsearch nodes with 
  '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node'.
  
  -------------------------------------------------------------------------------------------------
  ```

## 配置文件说明
- 配置文件，`/etc/elasticsearch/elasticsearch.yml`。
  - `xpack.security.enabled: true`，必须是开启状态才能配置用户名和密码。
  - `xpack.security.http.ssl`配置项`enabled`要配置为`true`。参考官方文档，地址：https://www.elastic.co/guide/en/elasticsearch/reference/8.9/security-settings.html。
  - 当启用了认证后，必须是https协议，当前为个人环境，只有自签名证书，所以导致kibana无法与elasticsearch通信，所以不再配置用户认证了。
    ```shell
    {"service":{"node":{"roles":["background_tasks","ui"]}},"ecs":{"version":"8.6.1"},"@timestamp":"2023-08-23T23:07:05.585+08:00","message":"Unable to retrieve version information from Elasticsearch nodes. self signed certificate in certificate chain","log":{"level":"ERROR","logger":"elasticsearch-service"},"process":{"pid":6081},"trace":{"id":"9578d06da3a66c908e961a5e53d0ba3e"},"transaction":{"id":"c731f671773e2394"}}
    ```
  - 所以在当前环境下，禁用security。

## 配置用户名和密码（参考）
- 重置超级管理员密码。
- 查看elasticsearch内置角色(`curl -X GET -u elastic:gLplU23GiqFU7eSlVo-q http://localhost:9200/_security/role`)，查询各种内置账号角色，其角色名和内置账号名一致。
- 创建以下角色用户：
  ```shell
  service elasticsearch restart
  cd /usr/share/elasticsearch/bin
  echo -e "y\n{{ elastic_password }}\n{{ elastic_password }}\n" | ./elasticsearch-reset-password --username elastic --interactive
  echo -e "y\n{{ elastic_kibana_password }}\n{{ elastic_kibana_password }}\n" | ./elasticsearch-reset-password --username kibana_system --interactive
  ./elasticsearch-users useradd "{{ elastic_beats_username }}" --password "{{ elastic_beats_password }}" -r "beats_admin"
  ./elasticsearch-users useradd "{{ elastic_monitor_username }}" --password "{{ elastic_monitor_password }}" -r "monitoring_user"
  ```
