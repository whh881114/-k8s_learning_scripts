# 01-k8s-004-安装istio.md

## 架构
- 安装两个mesh网络，一个叫sun.freedom.org，另一个叫moon.freedom.org。
- 一个mesh网络中，一个istio控制两个k8s集群，sun.freedom.org控制bj.freedom.org和sh.freedom.org；moon.freedom.org控制gd.freedom.org和hk.freedom.org。

## 自定义参数
- https://istio.io/latest/docs/setup/additional-setup/customize-installation/
- https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/

## mesh：sun.freedom.org规划
- bj.freedom.org为primary角色，可自定义参数文件：istio-1.16.0/manifests/profiles/default.yaml，安装命令：istioctl install -f istio-1.16.0/manifests/profiles/default.yaml。
- sh.freedom.org为remote角色，可自定义参数文件：istio-1.16.0/manifests/profiles/remote.yaml，安装命令：istioctl install -f istio-1.16.0/manifests/profiles/remote.yaml。

## mesh：moon.freedom.org规划
- gd.freedom.org为primary角色，可自定义参数文件：istio-1.16.0/manifests/profiles/default.yaml，安装命令：istioctl install -f istio-1.16.0/manifests/profiles/default.yaml。
- hk.freedom.org为remote角色，可自定义参数文件：istio-1.16.0/manifests/profiles/remote.yaml，安装命令：istioctl install -f istio-1.16.0/manifests/profiles/remote.yaml。

## 网络规划
- 在pfsense上删除各个集群的cluster和pod网段路由，用来部署单mesh多cluster模式。

## 官方文档
- https://istio.io/latest/docs/setup/install/multicluster/primary-remote_multi-network/

## 部署
### 准备工作
- 清除环境命令。
```shell
kubectl delete -f samples/addons
istioctl uninstall -y --purge
kubectl delete namespace istio-system
```

- 配置信任，在主集群k8s.bj.freedom.org上操作。
```shell
kubectl create namespace istio-system
kubectl create secret generic cacerts -n istio-system \
      --from-file=samples/certs/ca-cert.pem \
      --from-file=samples/certs/ca-key.pem \
      --from-file=samples/certs/root-cert.pem \
      --from-file=samples/certs/cert-chain.pem

export CTX_CLUSTER1=kubernetes-admin@kubernetes
kubectl --context="${CTX_CLUSTER1}" get namespace istio-system && \
kubectl --context="${CTX_CLUSTER1}" label namespace istio-system topology.istio.io/network=network1


cat <<EOF > cluster1.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: cluster1
      network: network1
EOF

istioctl install --set values.pilot.env.EXTERNAL_ISTIOD=true --context="${CTX_CLUSTER1}" -f cluster1.yaml -y

```

- 此时，原istiod服务是ClusterIP，现需要将istiod的服务暴露出来，也就是控制平台，之后remote注册时需要使用到。
  可以使用`kubectl -n istio-system get svc istiod -o yaml`获取内容，然后将ClusterIP相关的全删除。
```shell
cat <<EOF > istiod-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: istiod
    install.operator.istio.io/owning-resource: unknown
    install.operator.istio.io/owning-resource-namespace: istio-system
    istio: pilot
    istio.io/rev: default
    operator.istio.io/component: Pilot
    operator.istio.io/managed: Reconcile
    operator.istio.io/version: 1.16.0
    release: istio
  name: istiod-nodeport
  namespace: istio-system
spec:
  ports:
  - name: grpc-xds
    port: 15010
    protocol: TCP
    targetPort: 15010
    nodePort: 32478
  - name: https-webhook
    port: 443
    protocol: TCP
    targetPort: 15017
    nodePort: 30175
  selector:
    app: istiod
    istio: pilot
  type: NodePort
EOF

kubectl --context="${CTX_CLUSTER1}" apply -f istiod-nodeport.yaml
```

- 安装eastwest网关。
```shell
samples/multicluster/gen-eastwest-gateway.sh --mesh mesh1 --cluster cluster1 --network network1 > cluster1-eastwest.yaml
istioctl --context="${CTX_CLUSTER1}" install -f cluster1-eastwest.yaml -y
```

- 使用haproxy转发`istiod`，`istio-ingressgateway`和`istio-eastwestgateway`三个服务，将其暴露出来。

istio-eastwestgateway   LoadBalancer   172.16.24.172   <pending>     15021:30496/TCP,15443:31994/TCP,15012:30631/TCP,15017:31451/TCP   2m14s
istio-ingressgateway    LoadBalancer   172.16.49.130   <pending>     15021:30517/TCP,80:30695/TCP,443:31139/TCP                        13m
istiod                  NodePort       172.16.43.151   <none>        15010:32478/TCP,15012:31403/TCP,443:30175/TCP,15014:31357/TCP     14m