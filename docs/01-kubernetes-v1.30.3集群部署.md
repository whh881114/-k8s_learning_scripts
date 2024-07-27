# kubernetes-v1.30.3集群部署


## 正文
- kubernetes-v1.30.3部署和之前的版本有点区别，比如说之前我部署的最新v1.22.2，现在此版本不使用docker引擎了，所以说区别还是很大。

- 提前准备镜像，指定镜像仓库，kubeadm config images list，也可以在后面指定版本号：kubeadm config images list --kubernetes-version v1.30.3。
  ```shell
  # registry.k8s.io/kube-apiserver:v1.30.3
  # registry.k8s.io/kube-controller-manager:v1.30.3
  # registry.k8s.io/kube-scheduler:v1.30.3
  # registry.k8s.io/kube-proxy:v1.30.3
  # registry.k8s.io/coredns/coredns:v1.11.1
  # registry.k8s.io/pause:3.9
  # registry.k8s.io/etcd:3.5.12-0
  ```
- kubernetes-v1.30.3使用containerd了，所以需要做些配置，先生成默认配置文件`containerd config default > /etc/containerd/config.toml`
  然后需要修改以下内容，其中sandbox_image必须要重启，否则则会去访问官方源镜像，从而导致安装失败。
  ```shell
  [plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6"
  
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
      SystemdCgroup = true
  ```

- 安装高可用k8s集群（多master节点）前提，先建一个负载均衡地址，然后做TCP转到到后端的k8s master节点上的6443端口，此时我使用的是`apiserver.k8s.freedom.org:6443`，使用haproxy完成转发。
  参考资料就是：`https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/high-availability/`。

- 在master-1.k8s.freedom.org上执行初始化命令，这里指定镜像仓库了，所以各k8s集群中不用手动去pull镜像，然后再打tag。
  ```shell
    # kubeadm init \
             --image-repository=harbor.freedom.org/registry.k8s.io
             --kubernetes-version=v1.30.3 \
             --pod-network-cidr=10.0.0.0/16 \
             --service-cidr=172.16.0.0/16 \
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