# 配置mysqld-exporter账号说明

- 官方镜像：https://hub.docker.com/r/prom/mysqld-exporter

- 创建监控账号：
```mysql
    CREATE USER 'mysqld_exporter'@'localhost' IDENTIFIED BY 'pJwtdho13jLipiyquxldnqialgrpkvl~';
    GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'mysqld_exporter'@'localhost';
    GRANT SELECT ON performance_schema.* TO 'mysqld_exporter'@'localhost';
    FLUSH PRIVILEGES;
    EXIT;
```