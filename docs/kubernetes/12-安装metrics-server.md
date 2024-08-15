# 安装metrics-server


## 参考资料
- https://github.com/kubernetes-sigs/metrics-server
- https://blog.csdn.net/weilaozongge/article/details/139267389


## 前言
安装完kubernetes-dashboard后，其管理界面不显示pod的cpu/mem使用情况，此时，需要安装metrics-server即可解决。


## 安装
- 如果没有相对应的helm chart release的话，可以使用以下命令获取。
  ```shell
  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
  helm search repo metrics-server
  helm fetch metrics-server/metrics-server --version=3.12.1
  ```

- values.yaml中需要修改启动参数，原因：Kubelet certificate needs to be signed by cluster Certificate Authority
  (or disable certificate validation by passing --kubelet-insecure-tls to Metrics Server)
  ```yaml
  defaultArgs:
    - --cert-dir=/tmp
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --kubelet-use-node-status-port
    - --metric-resolution=15s
    - --kubelet-insecure-tls
  ```

- 结果。
```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "release \"metrics-server\" uninstalled",
            "NAME: metrics-server",
            "LAST DEPLOYED: Thu Aug 15 10:51:08 2024",
            "NAMESPACE: kube-system",
            "STATUS: deployed",
            "REVISION: 1",
            "TEST SUITE: None",
            "NOTES:",
            "***********************************************************************",
            "* Metrics Server                                                      *",
            "***********************************************************************",
            "  Chart version: 3.12.1",
            "  App version:   0.7.1",
            "  Image tag:     harbor.idc.roywong.top/registry.k8s.io/metrics-server/metrics-server:0.7.1",
            "***********************************************************************"
        ],
        []
    ]
}
```