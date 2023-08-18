# elastic-001-elasticsearch配置用户名密码


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
  - `xpack.security.http.ssl`配置项`enabled`配置为`true`，增加通信安全，访问时需要使用https协议，否则为http协议。
  - 配置片断。
    ```yaml
    xpack.security.enabled: true
    xpack.security.http.ssl:
      enabled: true
      keystore.path: certs/http.p12
    ```

## 结果
