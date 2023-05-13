local vars = import './vars.libsonnet';

[
  {
    apiVersion: "storage.k8s.io/v1",
    kind: "StorageClass",
    metadata: {
      name: "%s-%s" % [vars['type'], instance['name']],
      namespace: vars['namespace'],
    },
    provisioner: "fuseim.pri/storageclass-%s-%s" % [vars['type'], instance['name']],
  }

  for instance in vars['instances']
]