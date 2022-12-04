# 01-k8s-004-安装istio.md

## 架构
- 只安装一个mesh网络。
- 安装方式：`Install Istio with an External Control Plane`。
- 将`the External Control Plane`部署在k8s.bj.freedom.org集群中。
- k8s.sh.freedom.org，k8s.gd.freedom.org和k8s.hk.freedom.org集群连接到控制平面中。

## 网络规划
- 在pfsense上禁用各个集群的cluster和pod网段路由，用来部署单mesh多cluster模式。

## 官方文档
- https://istio.io/latest/docs/setup/install/external-controlplane/

## 部署总结
- 实验环节，不需要配置SSL，因为在使用自签名证书时，会报错误`x509: certificate signed by unknown authority`。
- 在haproxy.k8s.bj.freedom.org主机上暴露出k8s集群istio-system下的istio-ingressgateway服务，TCP端口一对一转发。
- 在master01.k8s.bj.freedom.org主机配置多集群访问方式，文档地址：https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/

### 准备工作
#### 配置好多集群访问方式后，
```shell
export CTX_EXTERNAL_CLUSTER=kubernetes-admin-bj@bj
export CTX_REMOTE_CLUSTER=kubernetes-admin-sh@sh
export EXTERNAL_ISTIOD_ADDR=192.168.4.11
export SSL_SECRET_NAME=NONE
export REMOTE_CLUSTER_NAME=sh

export CTX_SECOND_CLUSTER=kubernetes-admin-gd@gd
export SECOND_CLUSTER_NAME=gd
```

#### 部署过程按官方的文档即可。