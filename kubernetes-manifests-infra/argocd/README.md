# 说明

- 因为后续会使用`ingress`暴露外网，所以`argocd`不启用`tls`，在`argocd-server`的`Deployment`中加入`--insecure`。

- `ingress`的`apiVersion`修改为`networking.k8s.io/v1`，这个是高版本的`k8s`的，并且`ingress`的`yaml`文件也有所变化了。