local vars = import './vars.libsonnet';


[
  local conf_1 = if 'conf' in instance then instance['conf'] else vars['default_conf'];
  local conf_2 = std.strReplace(conf_1, "[instance_name]", instance['name']);
  local conf   = std.strReplace(conf_2, "[namespace]", vars['namespace']);

  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: instance['name'],
      namespace: vars['namespace'],
    },
    data: {
      "zoo.cfg": conf,
    }
  }

  for instance in vars['instances']
]