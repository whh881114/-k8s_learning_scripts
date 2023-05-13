local vars = import './vars.libsonnet';

[
  {
    apiVersion: "rbac.authorization.k8s.io/v1",
    kind: "ClusterRoleBinding",
    metadata: {
      name: "%s-%s" % [vars['type'], instance['name']],
      namespace: vars['namespace'],
    },
    subjects: [{kind: ServiceAccount, name: name, namespace: vars['namespace']}],
    roleRef: {
      kind: "ClusterRole",
      name: name,
      apiGroup: "rbac.authorization.k8s.io"
    }
  }

  for instance in vars['instances']
]