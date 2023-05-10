local vars = import './vars.libsonnet';
local data_source_name = "exporter:pJwtdho13jLipiyquxldnqialgrpkvl~@(localhost:3306)/";

[
  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "mysqld_exporter",
      namespace: vars['namespace'],
    },
    data: {
      DATA_SOURCE_NAME: data_source_name,
    }
  }
]

// 配置mysqld_exporter用户监控
// CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'pJwtdho13jLipiyquxldnqialgrpkvl~';
// GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
// FLUSH PRIVILEGES;
// EXIT