local vars = import '../vars.libsonnet';

{
  apiVersion: "v1",
  kind: "ConfigMap",
  metadata: {
    name: "consul-agent-config",
    namespace: vars['namespace'],
  },
  data: {
    "agent.json": |||
      {
        "services": [
          {
              "name": "consul-agent",
              "port": 8500,
              "tags": [
                  "consul-agent"
              ]
          },
          {
              "name": "node-exporter",
              "port": 9100,
              "tags": [
                  "node-exporter"
              ]
          }
        ]
      }
    |||
  }
}