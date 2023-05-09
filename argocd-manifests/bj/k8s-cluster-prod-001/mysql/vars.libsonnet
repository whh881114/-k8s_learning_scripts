local other_mysql_conf = |||
  Here is the customized configuration content, adjusting to other mysql instances.
|||;

{
  namespace: "mysql",
  image: "harbor.freedom.org/docker.io/mysql",
  image_tag: "5.7.29",
  image_pull_policy: "IfNotPresent",

  replicas: 1,
  requests_cpu: "100m",
  requests_memory: "128Mi",
  limits_cpu: "4000m",
  limits_memory: "8192Mi",

  container_ports: [
    {name: "mysql", containerPort: 3306},
    {name: "metrics", containerPort: 9104},
  ],

  // mysql的root密码必须要每个实例都定义。
  instances: [{name: "zabbix", mysql_root_password: "kz2zv&eoynpneQbyeowebyu0beGxkgvy"}],

  // mysql部署时，要安装mysql_exporter，定义的用户名和密码就唯一。
  mysql_exporter_data_source: "mysqld_exporter:pJwtdho13jLipiyquxldnqialgrpkvl~@(localhost:3306)/",

  // windows下，当使用|||声明跨行内容时，如果碰上空行，需要补充空格。
  // 但是，保存后就默认去掉了空格，所以方便点的方法，使用#来对齐。
  mysql_default_conf: |||
    # For advice on how to change settings please see
    # http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html
    #
    [mysqld]
    #
    # Remove leading # and set to the amount of RAM for the most important data
    # cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
    # innodb_buffer_pool_size = 128M
    #
    # Remove leading # to turn on a very important data integrity option: logging
    # changes to the binary log between backups.
    # log_bin
    #
    # Remove leading # to set options mainly useful for reporting servers.
    # The server defaults are faster for transactions and fast SELECTs.
    # Adjust sizes as needed, experiment to find the optimal values.
    # join_buffer_size = 128M
    # sort_buffer_size = 2M
    # read_rnd_buffer_size = 2M
    datadir=/var/lib/mysql
    socket=/var/lib/mysql/mysql.sock
    #
    #
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    #
    #
    log-error=/var/lib/mysql/mysqld.log
    pid-file=/var/lib/mysql/mysqld.pid
    #
    #
    # Roy Wong added those lines. 2020-01-09
    character_set_server = utf8mb4
    collation_server = utf8mb4_unicode_ci
    #
    #
    server-id = 1
    log-bin = /var/lib/mysql/mysql-bin
    binlog-format = ROW
    expire_logs_days = 15
    lower_case_table_names = 1
    sql_mode = NO_ENGINE_SUBSTITUTION
    #
    #
    [mysql]
    default_character_set = utf8
    #
    #
    [client]
    default_character_set = utf8
  |||,
}