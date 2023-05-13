local vars = import './vars.libsonnet';

[
  {
    apiVersion: "v1",
    kind: "ServiceAccount",
    metadata: {
      name: "%s-%s" % [vars['type'], instance['name']],
      namespace: vars['namespace'],
    }
  }

  for instance in vars['instances']
]

