# 安装网络插件Cilium

### 前言
- https://docs.cilium.io
- https://github.com/cilium/cilium-cli


## 安装
- 操作系统使用的是RockyLinux-9.3，所以不需要更新内核版本，暂时没有涉及额外的配置。
  - https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-cilium

- 初始化kubernetes集群时，指定了`--pod-network-cidr`，但是这个在只能算是声明，
  真正能决定pod运行的网段，是由cni插件来决定，所以安装cilium也要指定pod运行的网段，这个参数是`clusterPoolIPv4PodCIDRList`。
  - https://docs.cilium.io/en/stable/network/concepts/ipam/cluster-pool/#expanding-the-cluster-pool
  - https://docs.cilium.io/en/stable/network/kubernetes/ipam-cluster-pool/#crd-backed-by-cilium-cluster-pool-ipam

```shell
cilium install \
       --set ipam.mode=kubernetes \
       --set k8s.requireIPv4PodCIDR=true \
       --set clusterPoolIPv4PodCIDRList=10.251.0.0/16
```
```shell
[root@master-1.k8s.freedom.org ~ 15:42]# 4> cilium status
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    disabled (using embedded mode)
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

Deployment             cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
DaemonSet              cilium             Desired: 6, Ready: 6/6, Available: 6/6
Containers:            cilium             Running: 6
                       cilium-operator    Running: 1
Cluster Pods:          37/37 managed by Cilium
Helm chart version:    
Image versions         cilium             quay.io/cilium/cilium:v1.15.6@sha256:6aa840986a3a9722cd967ef63248d675a87add7e1704740902d5d3162f0c0def: 6
                       cilium-operator    quay.io/cilium/operator-generic:v1.15.6@sha256:5789f0935eef96ad571e4f5565a8800d3a8fbb05265cf6909300cd82fd513c3d: 1
[root@master-1.k8s.freedom.org ~ 15:46]# 5> 
```

## 集群状态
```shell
[root@master-1.k8s.freedom.org ~ 15:54]# 2> kubectl get nodes -o wide
NAME                       STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                      KERNEL-VERSION                CONTAINER-RUNTIME
master-1.k8s.freedom.org   Ready    control-plane   28h   v1.30.3   10.255.1.12   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
master-2.k8s.freedom.org   Ready    control-plane   28h   v1.30.3   10.255.1.22   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
master-3.k8s.freedom.org   Ready    control-plane   28h   v1.30.3   10.255.1.23   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
worker-1.k8s.freedom.org   Ready    <none>          28h   v1.30.3   10.255.1.24   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
worker-2.k8s.freedom.org   Ready    <none>          28h   v1.30.3   10.255.1.25   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
worker-3.k8s.freedom.org   Ready    <none>          28h   v1.30.3   10.255.1.26   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
[root@master-1.k8s.freedom.org ~ 15:54]# 3> 
```

## 验证POD地址
```shell
[root@master-1.k8s.freedom.org ~ 16:06]# 8> kubectl get pods -A -o wide | grep coredns
kube-system       coredns-55b9c9ffdf-8qmhs                                 1/1     Running   0               28h     10.251.3.233   worker-1.k8s.freedom.org   <none>           <none>
kube-system       coredns-55b9c9ffdf-vbcn2                                 1/1     Running   1 (28h ago)     28h     10.251.0.112   master-1.k8s.freedom.org   <none>           <none>
[root@master-1.k8s.freedom.org ~ 16:06]# 9> 
```
