# 安装kube-prometheus-stack

##  前言
- 之前使用的是kube-prometheus，提供很多开箱即用的功能，非常适合萌新上手。但是，涉及到大规模集群时，收集的数据越来越多，
  要涉及到很多自定义配置时，那么就不太适合了。此外，目前官方更新的进展也很慢了，写此文档时，kube-prometheus最后的release时间是
  2024/09/06（v0.13.0），与现在（2024/08/12）相差近11个月。
- 安装kube-prometheus-stack时，先把helm chart文件中涉及到的镜像全部push到本地镜像库，否则安装时就会报错。

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