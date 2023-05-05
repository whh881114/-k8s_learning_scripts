# redis安装说明文档

### 准备工作
- 容器使用自定义配置文件，需要注意一点，配置文件中的daemonize需要设置为no，放在前台运行，如果以后台方式运行，
那么pod就没有任何进程在前台运行，那么pod就会一直处于CrashBackOff状态。

- 此实验中使用到了initContainers，初始化修改内核参数。

- 站在巨人肩膀上完成，https://segmentfault.com/a/1190000018405750。

- 在这里搭一个单机版及一个集群版。

## 1. 安装步骤
- 使用ansible生成redis实例yaml文件即可。
- 使用grafana监控redis数据：https://grafana.com/grafana/plugins/redis-datasource/。