- 官方地址：https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/additional-scrape-config.md

```shell
cat > additional-scrape-configs.yaml << 'EOF'
# consul自动发现配置，检查注册中心中的consul服务名。
- job_name: consul-sd-vm-node-exporter
  consul_sd_configs:
    - server: node01.consul.freedom.org:8500 # 只能写一个地址
      services:
        - node-exporter # 根据注册的服务进行过滤。
  relabel_configs:
    - source_labels:
        - __meta_consul_node
      target_label: hostname
EOF

kubectl create secret generic prometheus-additional-scrape-configs --from-file=additional-scrape-configs.yaml --dry-run -oyaml > prometheus-additional-scrape-configs.yaml

kubectl apply -f prometheus-additional-scrape-configs.yaml -n monitoring

```

