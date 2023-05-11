local vars = import './vars.libsonnet';


[
  local conf_1 = if 'mode' in instance && std.asciiLower(instance['mode']) == 'cluster' then
    if 'conf' in instance then instance['conf'] else vars['default_cluster_conf']
  else
    if 'conf' in instance then instance['conf'] else vars['default_standalone_conf'];

  local conf_2 = std.strReplace(conf_1, "[indiviual_redis_password]", instance['password']);
  local memory = if 'memory' in instance then instance['memory'] else vars['limits_memory'];
  local conf = std.strReplace(conf_2, "[indiviual_redis_memory]", memory);

  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "%s" % instance['name'],
      namespace: vars['namespace'],
    },
    data: {
      "redis.conf": conf,
    }
  }

  for instance in vars['instances']
]