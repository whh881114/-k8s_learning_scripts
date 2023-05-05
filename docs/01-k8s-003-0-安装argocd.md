# 安装argocd

## 版本说明
- https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#supported-versions

## 版本选择
- 2.7.1

## 说明
- 在bj集群中安装argocd，并且argocd管理四个集群部署——bj/sh/gd/hk。

- 因为后续会使用`ingress`暴露外网，所以`argocd`不启用`tls`，在`argocd-server`的`Deployment`中加入`--insecure`。

- `ingress`的`apiVersion`修改为`networking.k8s.io/v1`，这个是高版本的`k8s`的，并且`ingress`的`yaml`文件也有所变化了。

- 获取管理页面`admin`用户密码：`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`


## 安装
- 地址：https://github.com/argoproj/argo-cd/releases/tag/v2.7.1

- HA安装方式
    ```shell
    kubectl create namespace argocd
    wget https://raw.githubusercontent.com/argoproj/argo-cd/v2.7.1/manifests/ha/install.yaml -O argo-cd-v2.7.1-ha.yaml
    kubectl apply -n argocd -f argo-cd-v2.7.1-ha.yaml
    ```
    
- ingress导流
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: argocd-server-http-ingress
      namespace: argocd
      annotations:
        kubernetes.io/ingress.class: "nginx"
        nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    spec:
      rules:
        - host: argocd.freedom.org
          http:
            paths:
              - pathType: Prefix
                path: /
                backend:
                  service:
                    name: argocd-server
                    port:
                      number: 80
    ```