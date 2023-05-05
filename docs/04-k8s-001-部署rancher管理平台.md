# 04-k8s-001-部署rancher管理平台.md

### 前言
- rancher可以图形化管理k8s集群，官网地址：https://rancher.com/。
- 部署rancher步骤适合当前实验环境的四个集群，各集群定义proxy_host值后，其余步骤一样。

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
   
   - 命令：在集群中部署rancher，指定版本使用rancherImageTag参数，另外要使用useBundledSystemChart参数才能使用自带的监控，现在使用了prometheus-operator，所以不需要此参数。
   ```
   helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
   
   kubectl create namespace cattle-system
   
   helm upgrade --install rancher rancher-latest/rancher \
    --namespace cattle-system \
    --set hostname=${proxy_host} \
    --set proxy=http://${proxy_host} \
    --set no_proxy=127.0.0.0/8\\,10.0.0.0/8\\,cattle-system.svc\\,172.16.0.0/12\\,192.168.0.0/16\\,.svc\\,.cluster.local
   ```
   
   - 安装过程：
   ```
    Release "rancher" does not exist. Installing it now.
    W0611 16:24:21.064871   51742 warnings.go:70] cert-manager.io/v1beta1 Issuer is deprecated in v1.4+, unavailable in v1.6+; use cert-manager.io/v1 Issuer
    NAME: rancher
    LAST DEPLOYED: Sat Jun 11 16:24:19 2022
    NAMESPACE: cattle-system
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    Rancher Server has been installed.
    
    NOTE: Rancher may take several minutes to fully initialize. Please standby while Certificates are being issued, Containers are started and the Ingress rule comes up.
    
    Check out our docs at https://rancher.com/docs/
    
    If you provided your own bootstrap password during installation, browse to https://rancher.k8s.freedom.org to get started.
    
    If this is the first time you installed Rancher, get started by running this command and clicking the URL it generates:
    
    # shell command
    echo https://rancher.k8s.freedom.org/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')

    
    To get just the bootstrap password on its own, run:
    
    # shell command
    kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'

    Happy Containering!
    ```
   
   - 命令：需要给rancher的ingress添加注释。
   ```
   # kubectl -n cattle-system edit ingress rancher
   # 添加内容如下：
   # kubernetes.io/ingress.class: nginx
   ```

- 删除rancher工具：https://mp.weixin.qq.com/s/jgAmw9c9pnKFPSrEJV8Yvg。我最开始安装了2.6，更新时指定版本报错无法部署，我删除了rancher还是报错，所以还原镜像再重新部署。
