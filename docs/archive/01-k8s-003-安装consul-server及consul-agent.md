# consul-server及consul-agent安装说明文档

### 前言
- consul-server采用stateful部署。
- consul-agent采用daemonset部署。

## 1. 安装步骤
- consul-server集群安装，进入kubernetes-manifests-infra/consul-server下的各region，执行以下命令。
    ```shell
    kubectl apply -f namespace.yaml
    kubectl apply -f statefulset.yaml
    kubectl apply -f service.yaml
    kubectl apply -f ingress.yaml
    ```

- consul-agent安装，进入kubernetes-manifests-infra/consul-agent下的各region，执行以下命令。
    ```shell
    kubectl apply -f namespace.yaml
    kubectl apply -f configmap.yaml
    kubectl apply -f consul-agent.yaml
    ```