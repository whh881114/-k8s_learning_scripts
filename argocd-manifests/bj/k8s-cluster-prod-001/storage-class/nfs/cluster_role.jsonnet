local vars = import './vars.libsonnet';

[
  {
    apiVersion: "rbac.authorization.k8s.io/v1",
    kind: "ClusterRole",
    metadata: {
      name: "%s-%s" % [vars['type'], instance['name']],
      namespace: vars['namespace'],
    },
    rules: [{apiGroups: [""], resources: ["persistentvolumes"], verbs: ["get", "list", "watch", "create", "delete"]},
      {apiGroups: [""], resources: ["persistentvolumeclaims"], verbs: ["get", "list", "watch", "update"]},
      {apiGroups: ["storage.k8s.io"], resources: ["storageclasses"], verbs: ["get", "list", "watch"]},
      {apiGroups: [""], resources: ["events"], verbs: ["list", "watch", "create", "update", "patch"]},
      {apiGroups: [""], resources: ["endpoints"], verbs: ["create", "delete", "get", "list", "watch", "patch", "update"]},
    ]
  }

  for instance in vars['instances']
]