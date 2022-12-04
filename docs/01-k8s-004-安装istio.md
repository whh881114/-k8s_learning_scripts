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

## 部署
### 准备工作
#### 清除环境命令，适合所有集群。
```shell
kubectl delete -f samples/addons
istioctl uninstall -y --purge
kubectl delete namespace istio-system
```

#### 控制平面：集群k8s.bj.freedom.org
- 安装时需要注意点：做一个freedom.org域名的自签名证书；istiod服务是LoadBalancer类别，需要使用haproxy来进行tcp转发各端口。
```shell
cat <<EOF > controlplane-gateway.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
spec:
  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
        k8s:
          service:
            ports:
              - port: 15021
                targetPort: 15021
                name: status-port
              - port: 15012
                targetPort: 15012
                name: tls-xds
              - port: 15017
                targetPort: 15017
                name: tls-webhook
EOF

istioctl install -f controlplane-gateway.yaml

kubectl create -n istio-system secret tls freedom-org-credential \
  --key=freedom.org.key \
  --cert=freedom.org.crt

export EXTERNAL_ISTIOD_ADDR=istio-external-controlplane.freedom.org
export SSL_SECRET_NAME=freedom-org-credential
```