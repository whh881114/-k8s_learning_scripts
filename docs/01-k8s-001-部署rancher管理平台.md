# k8s集群上安装rancher管理平台安装说明文档

### 前言
- rancher可以图形化管理k8s集群，官网地址：https://rancher.com/。

## 1. 安装步骤
- 安装helm工具，下载最新版即可。官网地址：https://helm.sh/docs/intro/install/。

- 官方安装说明文档：https://rancher.com/docs/rancher/v2.6/en/installation/other-installation-methods/behind-proxy/install-rancher/。

- 安装起来没有什么坑，镜像下载还是很顺畅。helm就是版本3，比版本2好用多了。

- 安装依赖：`必须安装ingress服务`。
    
- 记录安装过程。

    - rancher的域名为：rancher.k8s.freedom.org。

    - 命令：安装证书管理。
    ```
    proxy_host="rancher.k8s.freedom.org"

    helm repo add jetstack https://charts.jetstack.io
    
    kubectl create namespace cert-manager
    
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml
     
    helm upgrade --install cert-manager jetstack/cert-manager \
      --namespace cert-manager --version v1.5.1 \
      --set http_proxy=http://${proxy_host} \
      --set https_proxy=http://${proxy_host} \
      --set no_proxy=127.0.0.0/8\\,10.0.0.0/8\\,cattle-system.svc\\,172.16.0.0/12\\,192.168.0.0/16\\,.svc\\,.cluster.local
    ```
   
   - 命令：在集群中部署rancher，指定版本使用rancherImageTag参数，另外要使用useBundledSystemChart参数才能使用自带的监控。
   ```
   helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
   
   kubectl create namespace cattle-system
   
   helm upgrade --install rancher rancher-latest/rancher \
    --namespace cattle-system \
    --set hostname=${proxy_host} \
    --set proxy=http://${proxy_host} \
    --set no_proxy=127.0.0.0/8\\,10.0.0.0/8\\,cattle-system.svc\\,172.16.0.0/12\\,192.168.0.0/16\\,.svc\\,.cluster.local \
   --set rancherImageTag=v2.4.17 \
   --set useBundledSystemChart=true
   ```
   
   - 命令：需要给rancher的ingress添加注释。
   ```
   # kubectl -n cattle-system edit ingress rancher
   # 添加内容如下：
   # kubernetes.io/ingress.class: nginx
   ```

- 删除rancher工具：https://mp.weixin.qq.com/s/jgAmw9c9pnKFPSrEJV8Yvg。我最开始安装了2.6，更新时指定版本报错无法部署，我删除了rancher还是报错，所以还原镜像再重新部署。
