# 监控redis

## 说明
- zabbix新版本支持模板挺丰富的，此时使用官方模板`Redis by Zabbix agent 2`即可。

- 官方文档：https://www.zabbix.com/cn/integrations/redis

- **文档中记录的密码使用mkpasswd生成随机密码，此外，此密码仅用于个人实验环境。**


## 配置过程
- 监控主机上要安装`zabbix-agent2`软件包，`zabbix-agent`和`zabbix-agent2`可以共存在一台主机上，需要配置不同的监听端口，其他配置项根据实际情况修改。

- `zabbix-agent2`在当前环境下使用的是`10150`端口。

- 由于`zabbix-agent2`没有使用默认端口`10050`，所以监控redis时，需要单独创建一台主机，客户端监听的端口要改为`10150`。
  ![zabbix-6.0-lts-创建redis监控主机.png](../images/zabbix/zabbix-6.0-lts-创建redis监控主机.png)


## redis配置密码说明
- 模板中默认没有配置密码，说明如下。
  ![zabbix-6.0-lts--Redis-by-Zabbix-agent-2.png](../images/zabbix/zabbix-6.0-lts--Redis-by-Zabbix-agent-2.png)

- 当redis配置了密码认证后，需要修改`/etc/zabbix/zabbix_agent2.d/plugins.d/redis.conf`文件，配置`Plugins.Redis.Default.Password`即可。


## 单主机多redis实例情况
- 参考资料
    - https://www.zabbix.com/forum/zabbix-suggestions-and-feedback/389050-discussion-thread-for-official-zabbix-template-redis
    - https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/src/go/plugins/redis?at=refs%2Fheads%2Frelease%2F6.0

- redis运行在6379和6380端口实例，配置文件`/etc/zabbix/zabbix_agent2.d/plugins.d/redis.conf`增加以下内容。
  ```shell
  # 监控默认端口6379配置认证
  Plugins.Redis.Default.Uri=tcp://localhost:6379
  Plugins.Redis.Default.Password=wisbqBfudddfccx%8gcgegv8tqxtpoNe
  
  # 监控运行在端口6380的redis配置认证
  Plugins.Redis.Sessions.Redis6380.Uri=tcp://localhost:6380
  Plugins.Redis.Sessions.Redis6380.Password=qm2zfKahHnu3mhwawxqns>tncajgaceu
  ```

- zabbix上增加6380监控实例步骤，重点配置宏`{$REDIS.CONN.URI}`的值为**Redis6380**。
  ![zabbix-6.0-lts-创建redis监控主机6380-1.png](../images/zabbix/zabbix-6.0-lts-创建redis监控主机6380-1.png)
  ![zabbix-6.0-lts-创建redis监控主机6380-2.png](../images/zabbix/zabbix-6.0-lts-创建redis监控主机6380-2.png)
