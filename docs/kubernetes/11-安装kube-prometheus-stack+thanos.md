# 安装kube-prometheus-stack+thanos


## 参考资料
- https://prometheus.io/
- https://thanos.io/
- https://huisebug.github.io/2023/06/28/kube-prometheus-thanos/


##  前言
- 之前使用的是kube-prometheus，提供很多开箱即用的功能，非常适合萌新上手。但是，涉及到大规模集群时，收集的数据越来越多，
  要涉及到很多自定义配置时，那么就不太适合了。此外，目前官方更新的进展也很慢了，写此文档时，kube-prometheus最后的release时间是
  2024/09/06（v0.13.0），与现在（2024/08/12）相差近11个月。

- **安装kube-prometheus-stack时，先把helm chart文件中涉及到的镜像全部push到本地镜像库，否则安装时就会报错。**

- **第一阶段：**
  - 思路：
      - 不用开启prometheus的thanos sidecar容器。
      - 部署prometheus/alertmanager/grafana均为一个实例，并且开启持久化。
  - 细节：
    - 各个监控对象是否存活。
        - kubeDns.enabled=false，默认情况下使用的是CoreDns。
          - serviceMonitor/monitoring/kube-prometheus-stack-kube-controller-manager/0 (3/3 up)
            - 修改对象：所有master节点。
            - 配置文件`/etc/kubernetes/manifests/kube-controller-manager.yaml`，将`--bind-address=127.0.0.1`修改为
              `--bind-address=0.0.0.0`。
          
          - serviceMonitor/monitoring/kube-prometheus-stack-kube-etcd/0 (3/3 up)
            - 修改对象：所有master节点。
            - 配置文件`/etc/kubernetes/manifests/etcd.yaml`，将`--listen-metrics-urls=http://127.0.0.1:2381`修改为
              `--listen-metrics-urls=http://0.0.0.0:2381`。   
            
          - serviceMonitor/monitoring/kube-prometheus-stack-kube-scheduler/0 (3/3 up)
            - 修改对象：所有master节点。
            - 配置文件`/etc/kubernetes/manifests/kube-scheduler.yaml`，，将`--bind-address=127.0.0.1`修改为
              `--bind-address=0.0.0.0`。  
            
          - serviceMonitor/monitoring/kube-prometheus-stack-kube-proxy/0 (6/6 up)
            - 修改对象：集群配置文件kube-proxy.kube-system。
            - 将配置文件中的`metricsBindAddress: ""`修改为`metricsBindAddress: "0.0.0.0:10249"`。
            - 重启daemonset，`kubectl rollout restart daemonset kube-proxy -n kube-system`。  
            
    - 验证持久化：删除kube-prometheus-stack，`helm uninstall kube-prometheus-stack -n monitoring`，查看pvc是否存在即可。

- **第二阶段：**
  - 思路：
    - 在第一阶段的基础上，对prometheus配置thanos sidecar容器。thanos会将prometheus本地的监控数据写入到cos中，并不提供其他功能。
  - 验证：
    - 配置prometheusSpec.retention为2h，本地只保留2小时数据，所以查询时只会有2小时的数据。
    - 配置prometheusSpec.thanos为如下值。
      ```yaml
        objectStorageConfig:
        secret:
          type: S3
          config:
            bucket: "[[ s3_bucket ]]"
            endpoint: "[[ s3_endpoint ]]"
            access_key: "[[ s3_access_key ]]"
            secret_key: "[[ s3_secret_key ]]"
      # BlockDuration controls the size of TSDB blocks produced by Prometheus.
      # The default value is 2h to match the upstream Prometheus defaults.
      blockSize: 1h
      ```
    - 在minio上查看最近两次上传的文件间隔即可验证配置是否成功。

- **第三阶段：**
  - 思路：
    - 恢复第二阶段的配置。
    - 安装thanos，启用compactor，query，query-frontend和storegateway组件即可，各组件只启用一个副本。
  - 验证：
    ```shell
    [root@master-1.k8s.freedom.org ~ 22:33]# 17> kubectl get pods -o wide -n monitoring
    NAME                                                        READY   STATUS    RESTARTS   AGE     IP             NODE                       NOMINATED NODE   READINESS GATES
    alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0          9h      10.251.5.116   worker-3.k8s.freedom.org   <none>           <none>
    kube-prometheus-stack-grafana-0                             3/3     Running   0          9h      10.251.3.181   worker-1.k8s.freedom.org   <none>           <none>
    kube-prometheus-stack-kube-state-metrics-5f7476447c-tcf65   1/1     Running   0          9h      10.251.3.223   worker-1.k8s.freedom.org   <none>           <none>
    kube-prometheus-stack-operator-8577db88d6-kkv65             1/1     Running   0          9h      10.251.3.87    worker-1.k8s.freedom.org   <none>           <none>
    kube-prometheus-stack-prometheus-node-exporter-5hn4f        1/1     Running   0          9h      10.255.1.12    master-1.k8s.freedom.org   <none>           <none>
    kube-prometheus-stack-prometheus-node-exporter-6xvgs        1/1     Running   0          9h      10.255.1.26    worker-3.k8s.freedom.org   <none>           <none>
    kube-prometheus-stack-prometheus-node-exporter-7drqz        1/1     Running   0          9h      10.255.1.22    master-2.k8s.freedom.org   <none>           <none>
    kube-prometheus-stack-prometheus-node-exporter-hnssl        1/1     Running   0          9h      10.255.1.25    worker-2.k8s.freedom.org   <none>           <none>
    kube-prometheus-stack-prometheus-node-exporter-vcf8m        1/1     Running   0          9h      10.255.1.23    master-3.k8s.freedom.org   <none>           <none>
    kube-prometheus-stack-prometheus-node-exporter-znd4v        1/1     Running   0          9h      10.255.1.24    worker-1.k8s.freedom.org   <none>           <none>
    prometheus-kube-prometheus-stack-prometheus-0               3/3     Running   0          9h      10.251.5.140   worker-3.k8s.freedom.org   <none>           <none>
    thanos-compactor-7cc778786d-tfz87                           1/1     Running   0          2m45s   10.251.3.226   worker-1.k8s.freedom.org   <none>           <none>
    thanos-query-5dd68ffbfd-4hdg7                               1/1     Running   0          2m45s   10.251.3.193   worker-1.k8s.freedom.org   <none>           <none>
    thanos-query-frontend-cdfb698d4-4hqrq                       1/1     Running   0          2m45s   10.251.3.1     worker-1.k8s.freedom.org   <none>           <none>
    thanos-ruler-0                                              1/1     Running   0          2m45s   10.251.3.253   worker-1.k8s.freedom.org   <none>           <none>
    thanos-storegateway-0                                       1/1     Running   0          2m45s   10.251.3.50    worker-1.k8s.freedom.org   <none>           <none>
    [root@master-1.k8s.freedom.org ~ 22:34]# 18>
    ```

## Thanos sidecar模式下各组件介绍
- sidecard
  - 和prometheus部署在一起，定期将prometheus的数据上传到对象存储中。

- query
  - 与prometheus管理界面相同功能，实现对多个prometheus进行聚合，同样是使用thnaos容器镜像，指定参数为query，并且指定endpoint使用
    grpc协议向底层组件(边车thanos-sidecar,存储thanos-store）获取数据。
  - 可以对监控数据自动去重。

- queryFrontend
  - 当查询的数据规模较大的时候，对query组件也会有很大的压力，queryFrontend组件来提升查询性能，queryFrontend组件连接对象是query。

- compactor
  - 将云存储中的数据进行压缩和下采样和保留。
  - 管理对象存储中的数据（管理、压缩、删除等）。

- store
  - sidecar将prometheus数据上传到了对象存储，需要进行查询就需要经过store的处理提供给query进行查询。
  - 并且store提供了缓存，加快查询速度的功能。

- ruler
  - 连接对象是query，经过query组件定期地获取指标数据，主要是prometheus的记录规则（record）和报警（alert）规则，
    其本身不会抓取metrics接口数据。
  - 可将记录规则（record）上传到对象存储中 。
  - 可连接alertmanager服务统一将告警信息发送至alertmanager。 
  - 建议：避免alertmanager服务告警过于复杂，报警(alert)规则还是由各kubernetes集群prometheus进行处理。




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