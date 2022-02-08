# 说明

- 因为后续会使用`ingress`暴露外网，所以`argocd`不启用`tls`，在`argocd-server`的`Deployment`中加入`--insecure`。

- `ingress`的`apiVersion`修改为`networking.k8s.io/v1`，这个是高版本的`k8s`的，并且`ingress`的`yaml`文件也有所变化了。

- 安装命令
    ```shell
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.2.3/manifests/ha/install.yaml
    ``

- 获取管理页面`admin`用户密码：`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`



# 官网

- https://argo-cd.readthedocs.io/en/stable/