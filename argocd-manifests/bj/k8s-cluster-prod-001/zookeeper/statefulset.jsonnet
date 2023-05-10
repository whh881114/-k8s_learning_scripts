local vars = import './vars.libsonnet';

// 改写command参数，启动服务前生成myid文件。
local command = ["sh", "-c", "/root/myid.sh && zkServer.sh start-foreground"];

[
  {
    apiVersion: "apps/v1",
    kind: "StatefulSet",
    metadata: {
      name: instance[ 'name' ],
      namespace: vars[ 'namespace' ],
      labels: { app: instance[ 'name' ] },
    },
    spec: {
      serviceName: instance[ 'name' ],
      replicas: if 'replicas' in instance then instance[ 'replicas' ] else vars[ 'replicas' ],
      selector: { matchLabels: { app: instance[ 'name' ] } },
      template: {
        metadata: {
          labels: { app: instance[ 'name' ] },
        },
        spec: {
          containers: [
            {
              name: instance[ 'name' ],
              image: if 'image' in instance && 'image_tag' in instance then "%s:%s" % [ instance[ 'image' ], instance[ 'image_tag' ] ]
                       else "%s:%s" % [ vars[ 'image' ], vars[ 'image_tag' ] ],
              env: [
                { name: "TZ", value: "Asia/Shanghai" },
              ],
              command: command,
              ports: vars['container_ports'],
              resources: {
                requests: {
                  cpu: if 'requests_cpu' in instance then instance[ 'requests_cpu' ] else vars[ 'requests_cpu' ],
                  memory: if 'requests_memory' in instance then instance[ 'requests_memory' ] else vars[ 'requests_memory' ],
                },
                limits: {
                  cpu: if 'limits_cpu' in instance then instance[ 'limits_cpu' ] else vars[ 'limits_cpu' ],
                  memory: if 'limits_memory' in instance then instance[ 'limits_memory' ] else vars[ 'limits_memory' ],
                },
              },
              volumeMounts: [
                { name: "conf", mountPath: "/conf", readOnly: "true" },
                { name: "data", mountPath: "/data" },
                { name: "script", mountPath: "/root" },
              ],
            },
          ],
          volumes: [
            { name: "conf", configMap: { name: instance[ 'name' ] } },
            { name: "script", configMap: { name: "myid" } },
          ]
        },
        volumeClaimTemplates: [
          {
            metadata: {
              name: "data",
              annotations: {
                "volume.beta.kubernetes.io/storage-class": if 'storage_class' in instance then instance[ 'storage_class' ] else vars[ 'storage_class' ]
              },
            },
            spec: {
              accessModes: [ "ReadWriteOnce" ],
              resources: { requests: { storage: if 'storage_class_capacity' in instance then instance[ 'storage_class_capacity' ] else vars[ 'storage_class_capacity' ] } }
            }
          }
        ]
      }
    }
  }

  for instance in vars['instances']
]
