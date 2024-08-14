# 安装kube-prometheus-stack


##  前言
- 之前使用的是kube-prometheus，提供很多开箱即用的功能，非常适合萌新上手。但是，涉及到大规模集群时，收集的数据越来越多，
  要涉及到很多自定义配置时，那么就不太适合了。此外，目前官方更新的进展也很慢了，写此文档时，kube-prometheus最后的release时间是
  2024/09/06（v0.13.0），与现在（2024/08/12）相差近11个月。

- **安装kube-prometheus-stack时，先把helm chart文件中涉及到的镜像全部push到本地镜像库，否则安装时就会报错。**

- **第一阶段**：
  - 思路：
      - 不用开启prometheus的thanos sidecar容器。
      - 部署prometheus/alertmanager/grafana均为一个实例，并且开启持久化。
  - 细节：
    - 各个监控对象是否存活。
        - kubeDns.enabled=false，默认情况下使用的是CoreDns。
          - serviceMonitor/monitoring/kube-prometheus-stack-kube-controller-manager/0 (3/3 up)
            - 修改对象：所有master节点。
            - 配置文件`/etc/kubernetes/manifests/kube-controller-manager.yaml`，将`--bind-address=127.0.0.1`修改为`--bind-address=0.0.0.0`。
          
          - serviceMonitor/monitoring/kube-prometheus-stack-kube-etcd/0 (3/3 up)
            - 修改对象：所有master节点。
            - 配置文件`/etc/kubernetes/manifests/etcd.yaml`，将`--listen-metrics-urls=http://127.0.0.1:2381`修改为`--listen-metrics-urls=http://0.0.0.0:2381`。   
            
          - serviceMonitor/monitoring/kube-prometheus-stack-kube-scheduler/0 (3/3 up)
            - 修改对象：所有master节点。
            - 配置文件`/etc/kubernetes/manifests/kube-scheduler.yaml`，，将`--bind-address=127.0.0.1`修改为`--bind-address=0.0.0.0`。  
            
          - serviceMonitor/monitoring/kube-prometheus-stack-kube-proxy/0 (6/6 up)
            - 修改对象：集群配置文件kube-proxy.kube-system。
            - 将配置文件中的`metricsBindAddress: ""`修改为`metricsBindAddress: "0.0.0.0:10249"`。
            - 重启daemonset，`kubectl rollout restart daemonset kube-proxy -n kube-system`。  
            
    - 验证持久化：删除kube-prometheus-stack，`helm uninstall kube-prometheus-stack -n monitoring`，查看pvc是否存在即可。

- **第二阶段**：
  - 思路：
    - 在第一阶段的基础上，对prometheus配置thanos sidecar容器。



## 安装结果
```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "release \"kube-prometheus-stack\" uninstalled",
            "NAME: kube-prometheus-stack",
            "LAST DEPLOYED: Mon Aug 12 11:19:13 2024",
            "NAMESPACE: monitoring",
            "STATUS: deployed",
            "REVISION: 1",
            "NOTES:",
            "kube-prometheus-stack has been installed. Check its status by running:",
            "  kubectl --namespace monitoring get pods -l \"release=kube-prometheus-stack\"",
            "",
            "Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator."
        ],
        []
    ]
}
```

```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "release \"thanos\" uninstalled",
            "NAME: thanos",
            "LAST DEPLOYED: Tue Aug 13 11:46:48 2024",
            "NAMESPACE: monitoring",
            "STATUS: deployed",
            "REVISION: 1",
            "TEST SUITE: None",
            "NOTES:",
            "CHART NAME: thanos",
            "CHART VERSION: 15.7.19",
            "APP VERSION: 0.36.0",
            "",
            "** Please be patient while the chart is being deployed **",
            "",
            "Thanos chart was deployed enabling the following components:",
            "- Thanos Query",
            "- Thanos Compactor",
            "- Thanos Ruler",
            "- Thanos Store Gateway",
            "",
            "Thanos Query can be accessed through following DNS name from within your cluster:",
            "",
            "    thanos-query.monitoring.svc.cluster.local (port 9090)",
            "",
            "To access Thanos Query from outside the cluster execute the following commands:",
            "",
            "1. Get the Thanos Query URL and associate Thanos Query hostname to your cluster external IP:",
            "",
            "   export CLUSTER_IP=$(minikube ip) # On Minikube. Use: `kubectl cluster-info` on others K8s clusters",
            "   echo \"Thanos Query URL: https://query-http-thanos.idc-ingress-nginx.roywong.top/\"",
            "   echo \"$CLUSTER_IP  query-http-thanos.idc-ingress-nginx.roywong.top\" | sudo tee -a /etc/hosts",
            "",
            "2. Open a browser and access Thanos Query using the obtained URL.",
            "",
            "WARNING: There are \"resources\" sections in the chart not set. Using \"resourcesPreset\" is not recommended for production. For production installations, please set the following values according to your workload needs:",
            "  - compactor.resources",
            "  - query.resources",
            "  - queryFrontend.resources",
            "  - ruler.resources",
            "  - storegateway.resources",
            "+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/",
            "",
            "⚠ SECURITY WARNING: Original containers have been substituted. This Helm chart was designed, tested, and validated on multiple platforms using a specific set of Bitnami and Tanzu Application Catalog containers. Substituting other containers is likely to cause degraded security and performance, broken chart features, and missing environment variables.",
            "",
            "Substituted images detected:",
            "  - docker.io/docker.io/bitnami/thanos:0.36.0-debian-12-r1"
        ],
        []
    ]
}
```