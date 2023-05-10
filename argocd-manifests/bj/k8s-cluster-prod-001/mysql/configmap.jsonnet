local vars = import './vars.libsonnet';

[
  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "%s" % instance['name'],
      namespace: vars['namespace'],
    },
    data: {
      MYSQLD_EXPORTER_DATA_SOURCE: vars['mysqld_exporter_data_source'],
      MYSQL_ROOT_PASSWORD: instance['root_password'],
      "my.cnf": if 'conf' in instance then instance['conf'] else vars['default_conf'],
    }
  }

  for instance in vars['instances']
]