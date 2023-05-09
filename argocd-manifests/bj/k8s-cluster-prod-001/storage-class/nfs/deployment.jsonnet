local vars = import './vars.libsonnet';

[
  {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
      name: "%s-%s" % [vars['type'], instance['name']],
      namespace: vars['namespace'],
    },
    spec: {
      replicas: if 'replicas' in instance then instance['replicas'] else vars['replicas'],
      strategy: {type: "Recreate"},
      selector: {
        matchLabels: {
          app: "%s-%s" % [vars['type'], instance['name']],
        }
      },
      template: {
        metadata: {
          labels: {
            app: "%s-%s" % [vars['type'], instance['name']],
          }
        },
        spec: {
          serviceAccountName: "%s-%s" % [vars['type'], instance['name']],
          containers: [
            {
              name: "%s-%s" % [vars['type'], instance['name']],
              image: "%s:%s" % [vars['image'], vars['image_tag']],
              env: [
                {name: "PROVISIONER_NAME", value: "fuseim.pri/storageclass-%s-%s" % [vars['type'], instance['name']],},
                {name: "NFS_SERVER", value: instance['nfs_server']},
                {name: "NFS_PATH", value: instance['nfs_path']},
              ],
              imagePullPolicy: vars['image_pull_policy'],
              resources:{
                requests: {
                  cpu: if 'requests_cpu' in instance then instance['requests_cpu'] else vars['requests_cpu'],
                  memory: if 'requests_memory' in instance then instance['requests_memory'] else vars['requests_memory'],
                },
                limits: {
                  cpu: if 'limits_cpu' in instance then instance['limits_cpu'] else vars['limits_cpu'],
                  memory: if 'limits_memory' in instance then instance['limits_memory'] else vars['limits_memory'],
                },
              },
              volumeMounts: [
                {name: "nfs-client-root", mountPath: "/persistentvolumes"}
              ]
            }
          ],
          volumes: [
            {
              name: "nfs-client-root",
              nfs: {
                server: instance['nfs_server'],
                path: instance['nfs_path'],
              }
            }
          ]
        }
      }
    }
  }

  for instance in vars['instances']
]

