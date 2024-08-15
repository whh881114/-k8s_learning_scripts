# 安装loki


## 前言
- https://grafana.com/docs/loki/latest/setup/install/helm/
- https://grafana.com/docs/loki/latest/setup/install/helm/concepts/
- https://grafana.com/docs/loki/latest/setup/install/helm/install-scalable/
- https://grafana.com/docs/loki/latest/get-started/deployment-modes/


## 部署
- 使用helm安装loki。

- 部署模式为`Simple Scalable`，默认模式。

- **对象存储的密钥对，均为假的，另外，*.idc.roywong.top使用到的证书使用let's encrypt签发。**

- **第一阶段：**
  - 思路：
      - 先保证能正常安装即可。loki的参数配置文件values.yaml内容挺多的，所以想要一次性修改好配置文件，其实是挺有难度的，
        所以安装时报错，要放松心态，这些都是因为某此参数没有正确配置导致，所以需要仔细看报错内容，然后再修改。
        ```shell
          global.image.registry: harbor.idc.roywong.top

          loki.auth_enabled: false
          
          loki.storage.bucketNames.chunks: kubernetes-loki-chunks
          loki.storage.bucketNames.ruler: kubernetes-loki-ruler
          loki.storage.bucketNames.admin: kubernetes-loki-admin
          loki.storage.s3.endpoint: minio-s3.idc.roywong.top
          loki.storage.s3.secretAccessKey: uppflsfdavutdnjgkkDuc3pjggavdlhlnsxW9vbc
          loki.storage.s3.accessKeyId: zftKko84rusihbZotbmi
          
          loki.schemaConfig.configs:
            - from: 2024-04-01
              store: tsdb
              object_store: s3
              schema: v13
              index:
                prefix: index_
                period: 24h

          memcached.image.repository: harbor.idc.roywong.top/docker.io/memcached
          memcached.image.tag: 1.6.23-alpine

          
          write.persistence.size: 10Gi
          write.persistence.storageClass: infra
          write.affinity: {}
          
          read.affinity: {}
          
          backend.persistence.size: 10Gi
          backend.persistence.storageClass: infra
          backend.affinity: {}
          
          sidecar.image.repository: harbor.idc.roywong.top/docker.io/kiwigrid/k8s-sidecar
          sidecar.image.tag: 1.24.3
          
          memcachedExporter.image.repository: harbor.idc.roywong.top/docker.io/prom/memcached-exporter
          memcachedExporter.image.tag: v0.14.2
        ```

## 配置文件
```yaml
auth_enabled: false
chunk_store_config:
  chunk_cache_config:
    background:
      writeback_buffer: 500000
      writeback_goroutines: 1
      writeback_size_limit: 500MB
    default_validity: 0s
    memcached:
      batch_size: 4
      parallelism: 5
    memcached_client:
      addresses: dnssrvnoa+_memcached-client._tcp.loki-chunks-cache.grafana.svc
      consistent_hash: true
      max_idle_conns: 72
      timeout: 2000ms
common:
  compactor_address: 'http://loki-backend:3100'
  path_prefix: /var/loki
  replication_factor: 3
  storage:
    s3:
      access_key_id: zftKko84rusihbZotbmi
      bucketnames: kubernetes-loki-chunks
      endpoint: minio-s3.idc.roywong.top
      insecure: false
      s3forcepathstyle: true
      secret_access_key: uppflsfdavutdnjgkkDuc3pjggavdlhlnsxW9vbc
frontend:
  scheduler_address: ""
  tail_proxy_url: ""
frontend_worker:
  scheduler_address: ""
index_gateway:
  mode: simple
limits_config:
  max_cache_freshness_per_query: 10m
  query_timeout: 300s
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  split_queries_by_interval: 15m
  volume_enabled: true
memberlist:
  join_members:
  - loki-memberlist
pattern_ingester:
  enabled: false
query_range:
  align_queries_with_step: true
  cache_results: true
  results_cache:
    cache:
      background:
        writeback_buffer: 500000
        writeback_goroutines: 1
        writeback_size_limit: 500MB
      default_validity: 12h
      memcached_client:
        addresses: dnssrvnoa+_memcached-client._tcp.loki-results-cache.grafana.svc
        consistent_hash: true
        timeout: 500ms
        update_interval: 1m
ruler:
  storage:
    s3:
      access_key_id: zftKko84rusihbZotbmi
      bucketnames: kubernetes-loki-ruler
      endpoint: minio-s3.idc.roywong.top
      insecure: false
      s3forcepathstyle: true
      secret_access_key: uppflsfdavutdnjgkkDuc3pjggavdlhlnsxW9vbc
    type: s3
runtime_config:
  file: /etc/loki/runtime-config/runtime-config.yaml
schema_config:
  configs:
  - from: "2024-04-01"
    index:
      period: 24h
      prefix: index_
    object_store: s3
    schema: v13
    store: tsdb
server:
  grpc_listen_port: 9095
  http_listen_port: 3100
  http_server_read_timeout: 600s
  http_server_write_timeout: 600s
storage_config:
  boltdb_shipper:
    index_gateway_client:
      server_address: dns+loki-backend-headless.grafana.svc.cluster.local:9095
  hedging:
    at: 250ms
    max_per_second: 20
    up_to: 3
  tsdb_shipper:
    index_gateway_client:
      server_address: dns+loki-backend-headless.grafana.svc.cluster.local:9095
tracing:
  enabled: false
```


## 安装结果
```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "namespace/grafana created",
            "NAME: loki",
            "LAST DEPLOYED: Thu Aug  1 11:59:29 2024",
            "NAMESPACE: grafana",
            "STATUS: deployed",
            "REVISION: 1",
            "NOTES:",
            "***********************************************************************",
            " Welcome to Grafana Loki",
            " Chart version: 6.7.3",
            " Chart Name: loki",
            " Loki version: 3.1.0",
            "***********************************************************************",
            "",
            "** Please be patient while the chart is being deployed **",
            "",
            "Tip:",
            "",
            "  Watch the deployment status using the command: kubectl get pods -w --namespace grafana",
            "",
            "If pods are taking too long to schedule make sure pod affinity can be fulfilled in the current cluster.",
            "",
            "***********************************************************************",
            "Installed components:",
            "***********************************************************************",
            "* gateway",
            "* read",
            "* write",
            "* backend",
            "",
            "",
            "***********************************************************************",
            "Sending logs to Loki",
            "***********************************************************************",
            "",
            "Loki has been configured with a gateway (nginx) to support reads and writes from a single component.",
            "",
            "You can send logs from inside the cluster using the cluster DNS:",
            "",
            "http://loki-gateway.grafana.svc.cluster.local/loki/api/v1/push",
            "",
            "You can test to send data from outside the cluster by port-forwarding the gateway to your local machine:",
            "",
            "  kubectl port-forward --namespace grafana svc/loki-gateway 3100:80 &",
            "",
            "And then using http://127.0.0.1:3100/loki/api/v1/push URL as shown below:",
            "",
            "```",
            "curl -H \"Content-Type: application/json\" -XPOST -s \"http://127.0.0.1:3100/loki/api/v1/push\"  \\",
            "--data-raw \"{\\\"streams\\\": [{\\\"stream\\\": {\\\"job\\\": \\\"test\\\"}, \\\"values\\\": [[\\\"$(date +%s)000000000\\\", \\\"fizzbuzz\\\"]]}]}\"",
            "```",
            "",
            "Then verify that Loki did received the data using the following command:",
            "",
            "```",
            "curl \"http://127.0.0.1:3100/loki/api/v1/query_range\" --data-urlencode 'query={job=\"test\"}' | jq .data.result",
            "```",
            "",
            "***********************************************************************",
            "Connecting Grafana to Loki",
            "***********************************************************************",
            "",
            "If Grafana operates within the cluster, you'll set up a new Loki datasource by utilizing the following URL:",
            "",
            "http://loki-gateway.grafana.svc.cluster.local/"
        ],
        []
    ]
}
```