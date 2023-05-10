local vars = import './vars.libsonnet';

local mysqld_exporter_container = {
  name: "mysqld-exporter",
  image: "harbor.freedom.org/prometheus-operator/mysqld-exporter:v0.14.0",
  imagePullPolicy: "IfNotPresent",
  env: [
    { name: "DATA_SOURCE_NAME", valueFrom: { configMapKeyRef: { name: "mysqld_exporter", key: "DATA_SOURCE_NAME" } } }
  ],
  port: [
    { name: "metrics", containerPort: 9104 }
  ]
};


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
          containers: [ mysqld_exporter_container,
            {
              name: instance[ 'name' ],
              image: if 'image' in instance && 'image_tag' in instance then "%s:%s" % [ instance[ 'image' ], instance[ 'image_tag' ] ]
                       else "%s:%s" % [ vars[ 'image' ], vars[ 'image_tag' ] ],
              env: [
                { name: "TZ", value: "Asia/Shanghai" },
                { name: "MYSQL_ROOT_PASSWORD", valueFrom: { configMapKeyRef: { name: instance[ 'name' ], key: "MYSQL_ROOT_PASSWORD" } } },
              ],
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
                { name: "conf", mountPath: "/etc/mysql/conf.d", readOnly: "true" },
                { name: "data", mountPath: "/var/lib/mysql" },
              ],
            },
          ],
          volumes: [
            { name: "conf", configMap: { name: instance[ 'name' ] } },
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
