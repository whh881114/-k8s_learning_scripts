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
- 在master01.k8s.sh.freedom.org和master01.k8s.gd.freedom.org集群中部署istio-eastwestgateway服务是使用的LoadBalancer，需要指定`externalIPs: []`地址，然后在对应的haproxy上一对一转发服务。

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

export CTX_THIRD_CLUSTER=kubernetes-admin-hk@hk
export THIRD_CLUSTER_NAME=hk

export GATEWAY_URL=192.168.5.11
```

#### 部署过程按官方的文档即可。

#### 添加hk集群命令。
```shell
cat <<EOF > third-remote-cluster.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: external-istiod
spec:
  profile: remote
  values:
    global:
      istioNamespace: external-istiod
    istiodRemote:
      injectionURL: https://${EXTERNAL_ISTIOD_ADDR}:15017/inject/cluster/${THIRD_CLUSTER_NAME}/net/network3
EOF


sed  -i'.bk' \
  -e "s|injectionURL: https://${EXTERNAL_ISTIOD_ADDR}:15017|injectionPath: |" \
  -e "/istioNamespace:/a\\
      remotePilotAddress: ${EXTERNAL_ISTIOD_ADDR}" \
  third-remote-cluster.yaml; rm -f third-remote-cluster.yaml.bk

kubectl create namespace external-istiod --context="${CTX_THIRD_CLUSTER}"
kubectl annotate namespace external-istiod "topology.istio.io/controlPlaneClusters=${REMOTE_CLUSTER_NAME}" --context="${CTX_THIRD_CLUSTER}"

istioctl manifest generate -f third-remote-cluster.yaml | kubectl apply --context="${CTX_THIRD_CLUSTER}" -f -

kubectl get mutatingwebhookconfiguration --context="${CTX_THIRD_CLUSTER}"

istioctl x create-remote-secret \
  --context="${CTX_THIRD_CLUSTER}" \
  --name="${THIRD_CLUSTER_NAME}" \
  --type=remote \
  --namespace=external-istiod \
  --create-service-account=false | \
  kubectl apply -f - --context="${CTX_EXTERNAL_CLUSTER}"

samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster "${THIRD_CLUSTER_NAME}" --network network3 > eastwest-gateway-3.yaml
    
istioctl manifest generate -f eastwest-gateway-3.yaml \
    --set values.global.istioNamespace=external-istiod | \
    kubectl apply --context="${CTX_THIRD_CLUSTER}" -f -

kubectl --context="${CTX_THIRD_CLUSTER}" get svc istio-eastwestgateway -n external-istiod

kubectl --context="${CTX_REMOTE_CLUSTER}" apply -n external-istiod -f \
    samples/multicluster/expose-services.yaml

```

#### 验证部署
```shell
kubectl create --context="${CTX_THIRD_CLUSTER}" namespace sample
kubectl label --context="${CTX_THIRD_CLUSTER}" namespace sample istio-injection=enabled

kubectl apply -f samples/helloworld/helloworld.yaml -l service=helloworld -n sample --context="${CTX_THIRD_CLUSTER}"

echo '---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-v3
  labels:
    app: helloworld
    version: v3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld
      version: v3
  template:
    metadata:
      labels:
        app: helloworld
        version: v3
    spec:
      containers:
      - name: helloworld
        image: docker.io/istio/examples-helloworld-v2
        resources:
          requests:
            cpu: "100m"
        imagePullPolicy: IfNotPresent #Always
        ports:
        - containerPort: 5000
' >> samples/helloworld/helloworld.yaml


kubectl apply -f samples/helloworld/helloworld.yaml -l version=v3 -n sample --context="${CTX_THIRD_CLUSTER}"
kubectl apply -f samples/sleep/sleep.yaml -n sample --context="${CTX_THIRD_CLUSTER}"

kubectl get pod -n sample --context="${CTX_THIRD_CLUSTER}"

kubectl exec --context="${CTX_THIRD_CLUSTER}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_THIRD_CLUSTER}" -n sample -l app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello

for i in {1..10}; do curl -s "http://${GATEWAY_URL}/hello"; done

```

#### 删除istio-remote集群
```shell
kubectl delete ns sample --context="${CTX_THIRD_CLUSTER}"
istioctl manifest generate -f third-remote-cluster.yaml | kubectl delete --context="${CTX_THIRD_CLUSTER}" -f -
kubectl delete ns external-istiod --context="${CTX_THIRD_CLUSTER}"
rm -f thrid-remote-cluster.yaml eastwest-gateway-3.yaml
```