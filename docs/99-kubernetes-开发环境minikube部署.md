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

## 删除环境
```shell
[root@minikube ~]# minikube delete --all
* Deleting "minikube" in docker ...
* Removing /root/.minikube/machines/minikube ...
* Removed all traces of the "minikube" cluster.
* Successfully deleted all profiles
[root@minikube ~]# 
```