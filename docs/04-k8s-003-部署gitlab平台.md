# 04-k8s-003-部署gitlab平台.md

### 前言
- 部署gitlab平台，管理自己的代码仓库，这个用于argocd拉取代码。

- 官方网站：https://docs.gitlab.com/operator/。


## 1. 安装步骤
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

