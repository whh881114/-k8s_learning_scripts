local vars = import '../vars.libsonnet';

local env = [{name: "TZ", value: "Asia/Shanghai"},
             {name: "HOSTIP", valueFrom: {fieldRef: {fieldPath: "status.hostIP"}}},
             {name: "HOSTNAME", valueFrom: {fieldRef: {fieldPath: "spec.nodeName"}}},
             {name: "NAMESPACE", valueFrom: {fieldRef: {fieldPath: "metadata.namespace"}}},];

local ports = vars['agent_container_ports'];


local args_retry_join = [
  "-retry-join=%s" % x for x in vars['server_args_retry_json']
];

local args_partial = [
  "agent",
  "-config-dir=/consul/config",
  "-log-level=debug",
  "-log-json",
  "-bind=0.0.0.0",
  "-client=0.0.0.0",
  "-advertise=$(HOSTIP)",
  "-disable-host-node-id",
  "-datacenter=%s" % vars['datacenter'],
  "-node=$(HOSTNAME)",
];

local args = args_partial + args_retry_join;


{
apiVersion: "apps/v1",
kind: "DaemonSet",
metadata: {
  name: "consul-agent",
  namespace: vars['namespace'],
  labels: {app: "consul-agent"},
  },
spec: {
  selector: {
    matchLabels: {app: "consul-agent"}
  },
  template: {
    metadata: {
      name: "consul-agent",
      labels: {app: "consul-agent"},
    },
    spec: {
      initContainers: [{
        name: "use-coredns",
        image: "harbor.freedom.org/docker.io/busybox:1.31.1",
        command: [ "sh", "-c", "echo 'nameserver %s' > /etc/resolv.conf" % vars['coredns_ip']],
      }],
      containers:[{
        name: "consul-agent",
        image: "%s:%s" % [vars['image'], vars['image_tag']],
        env: env,
        args: args,
        ports: ports,
        imagePullPolicy: vars['image_pull_policy'],
        resources:{
          requests: {
            cpu: vars['agent_requests_cpu'],
            memory: vars['agent_requests_memory'],
          },
          limits: {
            cpu: vars['agent_limits_cpu'],
            memory: vars['agent_limits_memory'],
          },
       },
        readinessProbe: {
          httpGet: {
            port: 8500,
            path: "/",
            scheme: "HTTP",
          },
          initialDelaySeconds: 10,
          periodSeconds: 5,
          timeoutSeconds: 60,
        },
        livenessProbe:{
          httpGet: {
            port: 8500,
            path: "/",
            scheme: "HTTP",
          },
          initialDelaySeconds: 10,
          periodSeconds: 5,
          timeoutSeconds: 60,
        },
        volumeMounts: [{
          name: "config",
          mountPath: "/consul/config/agent.json",
          subPath: "agent.json",
        }],
      }],
      hostNetwork: true,
      volumes: [{
          name: "config",
          configMap: { name: "consul-agent-config"},
      }]
    }
  }
}
}