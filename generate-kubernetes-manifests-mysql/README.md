# 配置mysqld-exporter账号说明

- 官方镜像：https://hub.docker.com/r/prom/mysqld-exporter

- 创建监控账号：
```mysql
    CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'XXXXXXXX';
    GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'localhost';
    GRANT SELECT ON performance_schema.* TO 'exporter'@'localhost';
```
