local global_vars = import '../global_vars.libsonnet';
local vars = import 'vars.libsonnet';

local http_port_number = 8080;

[
  {
    apiVersion: "networking.k8s.io/v1",
    kind: "Ingress",
    metadata: {
      name: instance['name'],
      namespace: vars['namespace'],
      annotations: {
        "kubernetes.io/ingress.class": "nginx",
        "nginx.ingress.kubernetes.io/proxy-body-size": "200m",
      }
    },
    spec: {
      rules: [{
        host: if 'ingress' in instance then instance['ingress'] else "%s.%s.%s" % [instance['name'], vars['namespace'], global_vars['domain_name']],
        http: {
          paths: [{
            path: "/",
            pathType: "ImplementationSpecific",
            backend: {
              service: {
                name: instance['name'],
                port: {number: http_port_number}
              }
            }
          }]
        }
      }]
    }
  }

  for instance in vars['instances']
]