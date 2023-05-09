local vars = import '../vars.libsonnet';

{
  apiVersion: "networking.k8s.io/v1",
  kind: "Ingress",
  metadata: {
    name: "consul-server",
    namespace: vars['namespace'],
    annotations: {
      "kubernetes.io/ingress.class": "nginx"
    }
  },
  spec: {
    rules: [{
      host: vars['server_ingress'],
      http: {
        paths: [{
          path: "/",
          pathType: "ImplementationSpecific",
          backend: {
            service: {
              name: "consul-server",
              port: {number: 8500}
            }
          }
        }]
      }
    }]
  }
}
