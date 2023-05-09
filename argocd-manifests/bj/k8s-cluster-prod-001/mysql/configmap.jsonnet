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
      MYSQL_EXPORTER_DATA_SOURCE: vars['mysql_exporter_data_source'],
      MYSQL_ROOT_PASSWORD: instance['mysql_root_password'],
      "my.cnf": if 'mysql_conf' in instance then instance['mysql_conf'] else vars['mysql_default_conf'],
    }
  }

  for instance in vars['instances']
]