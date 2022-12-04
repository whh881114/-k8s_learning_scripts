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

#### 数据平面：集群k8s.sh.freedom.org
```shell
export EXTERNAL_ISTIOD_ADDR=istio-external-controlplane.freedom.org
export REMOTE_CLUSTER_NAME=sh
export CTX_REMOTE_CLUSTER=kubernetes-admin@kubernetes

cat <<EOF > remote-config-cluster.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: external-istiod
spec:
  profile: remote
  values:
    global:
      istioNamespace: external-istiod
      configCluster: true
    pilot:
      configMap: true
    istiodRemote:
      injectionURL: https://${EXTERNAL_ISTIOD_ADDR}:15017/inject/cluster/${REMOTE_CLUSTER_NAME}/net/network1
    base:
      validationURL: https://${EXTERNAL_ISTIOD_ADDR}:15017/validate
EOF

kubectl create namespace external-istiod --context="${CTX_REMOTE_CLUSTER}"
istioctl manifest generate -f remote-config-cluster.yaml --set values.defaultRevision=default | kubectl apply --context="${CTX_REMOTE_CLUSTER}" -f -

kubectl get mutatingwebhookconfiguration --context="${CTX_REMOTE_CLUSTER}"

kubectl get validatingwebhookconfiguration --context="${CTX_REMOTE_CLUSTER}"

istioctl x create-remote-secret \
  --context="${CTX_REMOTE_CLUSTER}" \
  --type=config \
  --namespace=external-istiod \
  --service-account=istiod \
  --create-service-account=false
```


#### 控制平面：集群k8s.bj.freedom.org，第二步操作。
```shell
export CTX_EXTERNAL_CLUSTER=kubernetes-admin@kubernetes

kubectl create namespace external-istiod --context="${CTX_EXTERNAL_CLUSTER}"

kubectl create sa istiod-service-account -n external-istiod --context="${CTX_EXTERNAL_CLUSTER}"


# 因为我是在各个集群的master节点上配置的，所以此处需要先在k8s.sh.freedom.org上生成配置文件，然后在k8s.bj.freedom.org上再apply一次即可。
kubectl create sa istiod-service-account -n external-istiod --context="${CTX_EXTERNAL_CLUSTER}"
istioctl x create-remote-secret \
  --context="${CTX_REMOTE_CLUSTER}" \
  --type=config \
  --namespace=external-istiod \
  --service-account=istiod \
  --create-service-account=false | \
  kubectl apply -f - --context="${CTX_EXTERNAL_CLUSTER}"



export EXTERNAL_ISTIOD_ADDR=istio-external-controlplane.freedom.org
export REMOTE_CLUSTER_NAME=sh

cat <<EOF > external-istiod.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: external-istiod
spec:
  profile: empty
  meshConfig:
    rootNamespace: external-istiod
    defaultConfig:
      discoveryAddress: $EXTERNAL_ISTIOD_ADDR:15012
      proxyMetadata:
        XDS_ROOT_CA: /etc/ssl/certs/ca-certificates.crt
        CA_ROOT_CA: /etc/ssl/certs/ca-certificates.crt
  components:
    pilot:
      enabled: true
      k8s:
        overlays:
        - kind: Deployment
          name: istiod
          patches:
          - path: spec.template.spec.volumes[100]
            value: |-
              name: config-volume
              configMap:
                name: istio
          - path: spec.template.spec.volumes[100]
            value: |-
              name: inject-volume
              configMap:
                name: istio-sidecar-injector
          - path: spec.template.spec.containers[0].volumeMounts[100]
            value: |-
              name: config-volume
              mountPath: /etc/istio/config
          - path: spec.template.spec.containers[0].volumeMounts[100]
            value: |-
              name: inject-volume
              mountPath: /var/lib/istio/inject
        env:
        - name: INJECTION_WEBHOOK_CONFIG_NAME
          value: ""
        - name: VALIDATION_WEBHOOK_CONFIG_NAME
          value: ""
        - name: EXTERNAL_ISTIOD
          value: "true"
        - name: LOCAL_CLUSTER_SECRET_WATCHER
          value: "true"
        - name: CLUSTER_ID
          value: ${REMOTE_CLUSTER_NAME}
        - name: SHARED_MESH_CONFIG
          value: istio
  values:
    global:
      caAddress: $EXTERNAL_ISTIOD_ADDR:15012
      istioNamespace: external-istiod
      operatorManageWebhooks: true
      configValidation: false
      meshID: mesh1
EOF

istioctl install -f external-istiod.yaml --context="${CTX_EXTERNAL_CLUSTER}"

kubectl get po -n external-istiod --context="${CTX_EXTERNAL_CLUSTER}"

export SSL_SECRET_NAME=freedom-org-credential


cat <<EOF > external-istiod-gw.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: external-istiod-gw
  namespace: external-istiod
spec:
  selector:
    istio: ingressgateway
  servers:
    - port:
        number: 15012
        protocol: https
        name: https-XDS
      tls:
        mode: SIMPLE
        credentialName: $SSL_SECRET_NAME
      hosts:
      - $EXTERNAL_ISTIOD_ADDR
    - port:
        number: 15017
        protocol: https
        name: https-WEBHOOK
      tls:
        mode: SIMPLE
        credentialName: $SSL_SECRET_NAME
      hosts:
      - $EXTERNAL_ISTIOD_ADDR
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
   name: external-istiod-vs
   namespace: external-istiod
spec:
    hosts:
    - $EXTERNAL_ISTIOD_ADDR
    gateways:
    - external-istiod-gw
    http:
    - match:
      - port: 15012
      route:
      - destination:
          host: istiod.external-istiod.svc.cluster.local
          port:
            number: 15012
    - match:
      - port: 15017
      route:
      - destination:
          host: istiod.external-istiod.svc.cluster.local
          port:
            number: 443
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: external-istiod-dr
  namespace: external-istiod
spec:
  host: istiod.external-istiod.svc.cluster.local
  trafficPolicy:
    portLevelSettings:
    - port:
        number: 15012
      tls:
        mode: SIMPLE
      connectionPool:
        http:
          h2UpgradePolicy: UPGRADE
    - port:
        number: 443
      tls:
        mode: SIMPLE
EOF



```
