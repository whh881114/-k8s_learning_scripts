# kubernetes-开发环境minikube部署

## 前言
个人私有云环境下，按`haproxy+masters+workers`模式部署kubernetes集群所需的资源比minikube多，此外，个人私有云环境下所做的工作是验证
部署及个人的小实验，所以不会运行`所谓的业务`，所以就打算使用minikube部署了。

## 部署过程
- 准备工作，安装docker和kubectl。
```shell
[root@minikube ~]# dnf install docker-ce kubectl
[root@minikube ~]# systemctl enable docker
[root@minikube ~]# systemctl start docker
```

- 安装minikube。
```shell
[root@minikube ~]# curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
[root@minikube ~]# sudo rpm -Uvh minikube-latest.x86_64.rpm

[root@minikube ~]# minikube start --force
* minikube v1.33.1 on Rocky 9.4
! minikube skips various validations when --force is supplied; this may lead to unexpected behavior
* Automatically selected the docker driver. Other choices: podman, none, ssh
* The "docker" driver should not be used with root privileges. If you wish to continue as root, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/
* Using Docker driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.44 ...
! minikube was unable to download gcr.io/k8s-minikube/kicbase:v0.0.44, but successfully downloaded docker.io/kicbase/stable:v0.0.44 as a fallback image
* Creating docker container (CPUs=2, Memory=2200MB) ...
* Preparing Kubernetes v1.30.0 on Docker 26.1.1 ...
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring bridge CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
[root@minikube ~]# 

[root@minikube ~]# kubectl get pods -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7db6d8ff4d-wj9d9           1/1     Running   0          2m1s
kube-system   etcd-minikube                      1/1     Running   0          2m15s
kube-system   kube-apiserver-minikube            1/1     Running   0          2m16s
kube-system   kube-controller-manager-minikube   1/1     Running   0          2m15s
kube-system   kube-proxy-cwmgz                   1/1     Running   0          2m1s
kube-system   kube-scheduler-minikube            1/1     Running   0          2m17s
kube-system   storage-provisioner                1/1     Running   0          2m13s
[root@minikube ~]# 
```

- 机器重启后，启动minikube命令为`minikube start --force`。

- 启动插件
```shell
[root@minikube ~]# minikube addons list
|-----------------------------|----------|--------------|--------------------------------|
|         ADDON NAME          | PROFILE  |    STATUS    |           MAINTAINER           |
|-----------------------------|----------|--------------|--------------------------------|
| ambassador                  | minikube | disabled     | 3rd party (Ambassador)         |
| auto-pause                  | minikube | disabled     | minikube                       |
| cloud-spanner               | minikube | disabled     | Google                         |
| csi-hostpath-driver         | minikube | disabled     | Kubernetes                     |
| dashboard                   | minikube | disabled     | Kubernetes                     |
| default-storageclass        | minikube | enabled ✅   | Kubernetes                     |
| efk                         | minikube | disabled     | 3rd party (Elastic)            |
| freshpod                    | minikube | disabled     | Google                         |
| gcp-auth                    | minikube | disabled     | Google                         |
| gvisor                      | minikube | disabled     | minikube                       |
| headlamp                    | minikube | disabled     | 3rd party (kinvolk.io)         |
| helm-tiller                 | minikube | disabled     | 3rd party (Helm)               |
| inaccel                     | minikube | disabled     | 3rd party (InAccel             |
|                             |          |              | [info@inaccel.com])            |
| ingress                     | minikube | disabled     | Kubernetes                     |
| ingress-dns                 | minikube | disabled     | minikube                       |
| inspektor-gadget            | minikube | disabled     | 3rd party                      |
|                             |          |              | (inspektor-gadget.io)          |
| istio                       | minikube | disabled     | 3rd party (Istio)              |
| istio-provisioner           | minikube | disabled     | 3rd party (Istio)              |
| kong                        | minikube | disabled     | 3rd party (Kong HQ)            |
| kubeflow                    | minikube | disabled     | 3rd party                      |
| kubevirt                    | minikube | disabled     | 3rd party (KubeVirt)           |
| logviewer                   | minikube | disabled     | 3rd party (unknown)            |
| metallb                     | minikube | disabled     | 3rd party (MetalLB)            |
| metrics-server              | minikube | disabled     | Kubernetes                     |
| nvidia-device-plugin        | minikube | disabled     | 3rd party (NVIDIA)             |
| nvidia-driver-installer     | minikube | disabled     | 3rd party (Nvidia)             |
| nvidia-gpu-device-plugin    | minikube | disabled     | 3rd party (Nvidia)             |
| olm                         | minikube | disabled     | 3rd party (Operator Framework) |
| pod-security-policy         | minikube | disabled     | 3rd party (unknown)            |
| portainer                   | minikube | disabled     | 3rd party (Portainer.io)       |
| registry                    | minikube | disabled     | minikube                       |
| registry-aliases            | minikube | disabled     | 3rd party (unknown)            |
| registry-creds              | minikube | disabled     | 3rd party (UPMC Enterprises)   |
| storage-provisioner         | minikube | enabled ✅   | minikube                       |
| storage-provisioner-gluster | minikube | disabled     | 3rd party (Gluster)            |
| storage-provisioner-rancher | minikube | disabled     | 3rd party (Rancher)            |
| volumesnapshots             | minikube | disabled     | Kubernetes                     |
| yakd                        | minikube | disabled     | 3rd party (marcnuri.com)       |
|-----------------------------|----------|--------------|--------------------------------|
[root@minikube ~]# 

[root@minikube ~]# minikube addons enable dashboard
* dashboard is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
  - Using image docker.io/kubernetesui/dashboard:v2.7.0
  - Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
* Some dashboard features require the metrics-server addon. To enable all features please run:

	minikube addons enable metrics-server

* The 'dashboard' addon is enabled
[root@minikube ~]# 
[root@minikube ~]# minikube addons enable metrics-server
* metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
  - Using image registry.k8s.io/metrics-server/metrics-server:v0.7.1
* The 'metrics-server' addon is enabled
[root@minikube ~]# 
```

- 启用插件ingress
```shell
[root@minikube ~]# minikube addons enable ingress --images="KubeWebhookCertgenCreate=k8s.dockerproxy.com/ingress-nginx/kube-webhook-certgen:v1.4.1,KubeWebhookCertgenPatch=k8s.dockerproxy.com/ingress-nginx/kube-webhook-certgen:v1.4.1,IngressController=k8s.dockerproxy.com/ingress-nginx/controller:v1.10.1" --registries="k8s.dockerproxy.com"
* ingress is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
! Ignoring invalid pair entry k8s.dockerproxy.com
  - Using image k8s.dockerproxy.com/ingress-nginx/controller:v1.10.1
  - Using image k8s.dockerproxy.com/ingress-nginx/kube-webhook-certgen:v1.4.1
  - Using image k8s.dockerproxy.com/ingress-nginx/kube-webhook-certgen:v1.4.1
* Verifying ingress addon...
* The 'ingress' addon is enabled
[root@minikube ~]# 
```

## 删除环境
```shell
[root@minikube ~]# minikube delete --all
* Deleting "minikube" in docker ...
* Removing /root/.minikube/machines/minikube ...
* Removed all traces of the "minikube" cluster.
* Successfully deleted all profiles
[root@minikube ~]# 
```

## 部署过程中镜像无法拉取解决方法
- minikube默认是不识别本地镜像的，需要使用`minikube image load <image_name>:<image_tag>`加载，但是碰到启用ingress插件时就无效了。
- 启用ingress时，需要指定镜像，在网上找到的解决方法，但是明白images指定的那些参数在哪里找，https://juejin.cn/post/7165777147959705608。
- 另外，可以参考这一篇文档，https://developer.aliyun.com/article/221687。