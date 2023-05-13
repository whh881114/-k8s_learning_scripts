local vars = import './vars.libsonnet';

[
  {
    apiVersion: "monitoring.coreos.com/v1",
    kind: "PodMonitor",
    metadata: {
      name: instance['name'],
      namespace: vars['namespace'],
      labels: {app: instance['name']},
    },
    spec: {
      namespaceSelector: {matchNames: [vars['namespace']]},
      selector: {matchLabels: {app: instance['name']}},
      podMetricsEndpoints: [
        {
          relabelings: [
            {
              sourceLabels: ["__meta_kubernetes_pod_container_name"],
              regex: "mysqld-exporter",
              action: "keep",
            }
          ]
        }
      ]
    }
  }
  for instance in vars['instances']
]