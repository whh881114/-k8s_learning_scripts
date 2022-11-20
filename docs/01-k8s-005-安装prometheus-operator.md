# 01-k8s-005-安装prometheus-operator.md

### 安装步骤
```shell
cd kube-prometheus-0.10.0/manifests/setup
kubectl apply -f namespace.yaml
kubectl apply -f 0alertmanagerConfigCustomResourceDefinition.yaml
kubectl apply -f 0alertmanagerCustomResourceDefinition.yaml
kubectl apply -f 0podmonitorCustomResourceDefinition.yaml
kubectl apply -f 0probeCustomResourceDefinition.yaml
kubectl create -f 0prometheusCustomResourceDefinition.yaml
kubectl apply -f 0prometheusruleCustomResourceDefinition.yaml
kubectl apply -f 0servicemonitorCustomResourceDefinition.yaml
kubectl apply -f 0thanosrulerCustomResourceDefinition.yaml

cd ..
kubectl apply -f .

```

#### Dashboard导入
- dashboard：
    - 8878，JVM dashboard (for Prometheus Operator)
    - 11074，1 Node Exporter for Prometheus Dashboard EN 20201010
    - 14057，MySQL Exporter Quickstart and Dashboard