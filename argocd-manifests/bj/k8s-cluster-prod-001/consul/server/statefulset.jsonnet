local vars = import '../vars.libsonnet';

local env = [{name: "TZ", value: "Asia/Shanghai"},
             {name: "HOSTIP", valueFrom: {fieldRef: {fieldPath: "status.hostIP"}}},
             {name: "PODIP", valueFrom: {fieldRef: {fieldPath: "status.podIP"}}},
             {name: "NAMESPACE", valueFrom: {fieldRef: {fieldPath: "metadata.namespace"}}},];



local ports = vars['server_container_ports'];

local args_retry_join = [
  "-retry-join=%s" % x for x in vars['server_args_retry_json']
];

local args_retry_join_wan = [
  "-retry-join-wan=%s" % x for x in vars['server_agrs_retry_json_wan']
];

local args_partial = ["agent",
              "-server",
              "-bootstrap-expect=%d" % vars['server_replicas'],
              "-ui",
              "-data-dir=/consul/data",
              "-log-level=debug",
              "-log-json",
              "-bind=0.0.0.0",
              "-datacenter=%s" % vars['datacenter'],
              "-advertise=$(PODIP)",
              "-domain=cluster.local",
              "-disable-host-node-id"];

local args = args_partial + args_retry_join + args_retry_join_wan;



{
   apiVersion: "apps/v1",
   kind: "StatefulSet",
   metadata: {
     name: "consul-server",
     namespace: vars['namespace'],
   },
   spec: {
     serviceName: "consul-server",
     selector: {
       matchLabels: {
         app: "consul-server",
       }
     },
     replicas: vars['server_replicas'],
     tamplate: {
       metadata: {
         labels: { app: "consul-server", }
       },
       spec: {
         terminationGracePeriodSeconds: 10,
         containers: [{
           name: "consul-server",
           image: "%s:%s" % [vars['image'], vars['image_tag']],
           env: env,
           args: args,
           ports: ports,
           imagePullPolicy: vars['image_pull_policy'],
           resources:{
             requests: {
               cpu: vars['server_requests_cpu'],
               memory: vars['server_requests_memory'],
             },
             limits: {
               cpu: vars['server_limits_cpu'],
               memory: vars['server_limits_memory'],
             },
           },
           volumeMounts: [{
             name: "consul-server-data",
             mountPath: "/consul/data",
           }],
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
         }]
       }
     }
   },
     volumeClaimTemplates: [{
       metadata: {
         name: "consul-server-data",
         annotations: {
           "volume.beta.kubernetes.io/storage-class": vars['server_storage_class']
         },
       spec: {
         accessModes: ["ReadWriteOnce"],
         resources: {
           requests: {storage: vars['server_data_capcity']}
         }
       }
     }
   }]
 }
