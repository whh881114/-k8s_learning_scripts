# kubernetes-v1.30.3集群部署


## 正文
- kubernetes-v1.30.3部署和之前的版本有点区别，比如说之前我部署的最新v1.22.2，现在此版本不使用docker引擎了，所以说区别还是很大。

- 提前准备镜像，指定镜像仓库，kubeadm config images list，也可以在后面指定版本号： 
  kubeadm config images list --kubernetes-version v1.30.3，并且提前将镜像push到私有仓库。
  ```shell
  registry.k8s.io/kube-apiserver:v1.30.3
  registry.k8s.io/kube-controller-manager:v1.30.3
  registry.k8s.io/kube-scheduler:v1.30.3
  registry.k8s.io/kube-proxy:v1.30.3
  registry.k8s.io/coredns/coredns:v1.11.1
  registry.k8s.io/pause:3.9
  registry.k8s.io/etcd:3.5.12-0
  ```
  
- kubernetes-v1.30.3使用containerd了，所以需要做些配置，先生成默认配置文件
  `containerd config default > /etc/containerd/config.toml`
  然后需要修改以下内容，其中sandbox_image必须要重启，否则则会去访问官方源镜像，从而导致安装失败。
  ```shell
  [plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6"
  
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
      SystemdCgroup = true
  
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.freedom.org"]
          endpoint = ["http://harbor.freedom.org"]
  ```

- 安装高可用k8s集群（多master节点）前提，先建一个负载均衡地址，然后做TCP转到到后端的k8s master节点上的6443端口， 
  此时我使用的是`apiserver.k8s.freedom.org:6443`，使用haproxy完成转发。
  参考资料就是：`https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/high-availability/`。

- 在master-1.k8s.freedom.org上执行初始化命令，这里指定镜像仓库了，所以各k8s集群中不用手动去pull镜像，然后再打tag。
  ```shell
    # kubeadm init \
             --image-repository=harbor.freedom.org/registry.k8s.io
             --kubernetes-version=v1.30.3 \
             --pod-network-cidr=10.251.0.0/16 \
             --service-cidr=10.252.0.0/16 \
             --control-plane-endpoint="apiserver.k8s.bj.freedom.org:6443" \
             --upload-certs
    # mkdir -p $HOME/.kube 
    # sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
    # sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```
    
- 添加master节点，在其他master节点执行如下命令。
    ```shell
    kubeadm join apiserver.k8s.freedom.org:6443 \
                 --token nxar03.twaeblpfqd2da7np \
                 --discovery-token-ca-cert-hash sha256:77b78a283161048bcafeef79c65b58e3de668a6773ebb456134dc4079992754b \
                 --control-plane --certificate-key 5b8776558fc4d503c2007e8f0459988855244625e577cd0e0081bb2ba45e73fe
    ```

- 添加worker节点，在worker节点执行如下命令。
    ```shell
    kubeadm join apiserver.k8s.freedom.org:6443 \
                 --token nxar03.twaeblpfqd2da7np \
                 --discovery-token-ca-cert-hash sha256:77b78a283161048bcafeef79c65b58e3de668a6773ebb456134dc4079992754b
    ```

- 集群节点初始状态为`NotReady`状态，这是因为没有安装网络插件，此插件安装过程在ansible角色中完成，不在这里说明了。
    ```shell
    [root@master-1.k8s.freedom.org ~ 09:34]# 1> kubectl get nodes -o wide
    NAME                       STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                      KERNEL-VERSION                CONTAINER-RUNTIME
    master-1.k8s.freedom.org   Ready    control-plane   104m   v1.30.3   10.255.1.12   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
    master-2.k8s.freedom.org   Ready    control-plane   100m   v1.30.3   10.255.1.22   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
    master-3.k8s.freedom.org   Ready    control-plane   100m   v1.30.3   10.255.1.23   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
    worker-1.k8s.freedom.org   Ready    <none>          98m    v1.30.3   10.255.1.24   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
    worker-2.k8s.freedom.org   Ready    <none>          98m    v1.30.3   10.255.1.25   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
    worker-3.k8s.freedom.org   Ready    <none>          98m    v1.30.3   10.255.1.26   <none>        Rocky Linux 9.3 (Blue Onyx)   5.14.0-362.8.1.el9_3.x86_64   containerd://1.7.19
    [root@master-1.k8s.freedom.org ~ 09:35]# 2> 
    ```

## 部署后碰到的一些问题
- 集群所有主机重启后，其集群无法启动。
  - 排查过程如下：
    - 容器kube-apiserver一直重启，除去kube-apiserver容器不断重启外，还有其他容器在重启。查看kube-apiserver报错日志，
      提示连接不上etcd。
      ```shell
      {"level":"warn","ts":"2024-07-31T02:04:12.73454Z","caller":"rafthttp/probing_status.go:68","msg":"prober detected unhealthy status","round-tripper-name":"ROUND_TRIPPER_RAFT_MESSAGE","remote-peer-id":"574495eef1b06886","rtt":"0s","error":"dial tcp 10.255.1.22:2380: connect: connection refused"}
      ```
    - 查看etcd日志，提示当前etcd数据与其他节点不一致，导致不断重启。
      ```shell
      {"level":"fatal","ts":"2024-07-31T02:38:02.899481Z","caller":"etcdmain/etcd.go:204","msg":"discovery failed","error":"error validating peerURLs {ClusterID:9e6395fd91cf74a7 Members:[&{ID:27a71e7180313263 RaftAttributes:{PeerURLs:[https://10.255.1.12:2380] IsLearner:false} Attributes:{Name:master-1.k8s.freedom.org ClientURLs:[https://10.255.1.12:2379]}}] RemovedMemberIDs:[]}: member count is unequal","stacktrace":"go.etcd.io/etcd/server/v3/etcdmain.startEtcdOrProxyV2\n\tgo.etcd.io/etcd/server/v3/etcdmain/etcd.go:204\ngo.etcd.io/etcd/server/v3/etcdmain.Main\n\tgo.etcd.io/etcd/server/v3/etcdmain/main.go:40\nmain.main\n\tgo.etcd.io/etcd/server/v3/main.go:31\nruntime.main\n\truntime/proc.go:250"}
      ```
    - 处理方法：
      - 重置集群。
      - 在各个master节点，清除etcd本地数据，`rm -rf /var/lib/ectd`。