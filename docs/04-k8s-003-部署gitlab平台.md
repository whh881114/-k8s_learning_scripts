# 04-k8s-003-部署gitlab平台.md

### 前言

- 官方网站：https://docs.gitlab.com/operator/。

- 部署gitlab平台，管理自己的代码仓库，这个用于argocd拉取代码，因为使用github仓库，拉取超时，体验太差了。

- 使用operator模式部署，其参数过多，也过于复杂，最后采用docker模式部署，只是说把此模式改成用k8s平台上的statefulset模式进行部署。




## operator安装步骤
- 下载文件
    ```bash
    GL_OPERATOR_VERSION=0.8.1 # https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/releases
    PLATFORM=kubernetes # or "openshift"
    wget https://gitlab.com/api/v4/projects/18899486/packages/generic/gitlab-operator/${GL_OPERATOR_VERSION}/gitlab-operator-${PLATFORM}-${GL_OPERATOR_VERSION}.yaml
    ```
- 修改gitlab-operator的yaml文件中的镜像地址，具体文件在`kubernetes-manifests/gitlab`目录。
    ```shell
    gcr.io/kubebuilder/kube-rbac-proxy:v0.5.0 --> kubesphere/kube-rbac-proxy:v0.5.0 --> harbor.freedom.org/gcr.io/kube-rbac-proxy:v0.5.0
    ```

- 安装命令
    ```shell
    kubectl create namespace gitlab-system
    kubectl apply -f gitlab-operator-${PLATFORM}-${GL_OPERATOR_VERSION}.yaml
    ```

- 创建Gitlab类型资源，网站：https://docs.gitlab.com/operator/installation.html。
