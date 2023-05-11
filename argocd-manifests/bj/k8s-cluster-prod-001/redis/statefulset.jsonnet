local vars = import './vars.libsonnet';

local init_containers = [
  {
    name: "sysctl",
    image: "harbor.freedom.org/docker.io/busybox:1.31.1",
    command: ["sysctl"],
    args: ["-w", "net.core.somaxconn=65535"],
    securityContext: {privileged: "true"},
  },
  {
    name: "disable-transparent-hugepage",
    image: "harbor.freedom.org/docker.io/busybox:1.31.1",
    command: ["sh", "-c", "echo never > /host-sys/kernel/mm/transparent_hugepage/enabled"],
    securityContext: {privileged: "true"},
    volumeMounts: [{name: "host-sys", mountPath: "/host-sys"}]
  },
];


[
  if ! ('mode' in instance)  || std.asciiLower(instance['mode']) == 'standalone' then
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
          initContainers: init_containers,
          containers: [
            {
              name: instance[ 'name' ],
              image: if 'image' in instance && 'image_tag' in instance then "%s:%s" % [ instance[ 'image' ], instance[ 'image_tag' ] ]
                       else "%s:%s" % [ vars[ 'image' ], vars[ 'image_tag' ] ],
              env: [
                { name: "TZ", value: "Asia/Shanghai" },
              ],
              ports: vars['container_ports_standalone'],
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
                { name: "conf", mountPath: "/usr/local/etc/redis/", readOnly: "true" },
                { name: "data", mountPath: "/data" },
              ],
            },
          ],
          volumes: [
            { name: "conf", configMap: { name: instance[ 'name' ] } },
            { name: "host-sys", hostPath: { path: "/sys" }},
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
  else
    if 'mode' in instance && std.asciiLower(instance['mode']) == 'cluster' then
    [
      {
        apiVersion: "apps/v1",
        kind: "StatefulSet",
        metadata: {
          name: "%s-%d" % [instance['name'], num],
          namespace: vars[ 'namespace' ],
          labels: { app: "%s-%d" % [instance['name'], num]},
        },
        spec: {
          serviceName: "%s-%d" % [instance['name'], num],
          replicas: if 'disable' in instance && instance['disable'] then 0 else 1,
          selector: { matchLabels: { app: "%s-%d" % [instance['name'], num] }},
          template: {
            metadata: {
              labels: { app: "%s-%d" % [instance['name'], num] },
            },
            spec: {
              initContainers: init_containers,
              containers: [
                {
                  name: instance[ 'name' ],
                  image: if 'image' in instance && 'image_tag' in instance then "%s:%s" % [ instance[ 'image' ], instance[ 'image_tag' ] ]
                           else "%s:%s" % [ vars[ 'image' ], vars[ 'image_tag' ] ],
                  env: [
                    { name: "TZ", value: "Asia/Shanghai" },
                  ],
                  ports: vars['container_ports_cluster'],
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
                    { name: "conf", mountPath: "/usr/local/etc/redis/", readOnly: "true" },
                    { name: "data", mountPath: "/data" },
                  ],
                },
              ],
              volumes: [
                { name: "conf", configMap: { name: instance[ 'name' ] } },
                { name: "host-sys", hostPath: { path: "/sys" }},
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
      for num in std.range(1, instance['replicas'])
    ]
    else {}


  for instance in vars['instances']
]
