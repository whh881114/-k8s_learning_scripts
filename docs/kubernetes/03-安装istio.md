# 安装istio

## 部署架构
- 在一个kubernetes集群中部署istio。

## 安装
- 安装命令很简单，`istioctl install --set profile=default -y`。
- 安装参考文档：
  - https://istio.io/latest/docs/setup/additional-setup/config-profiles/
  - https://istio.io/latest/docs/setup/additional-setup/customize-installation/

## 安装结果
```shell
[root@master-1.k8s.freedom.org ~ 16:19]# 4> kubectl get pods -n istio-system -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP             NODE                       NOMINATED NODE   READINESS GATES
istio-ingressgateway-6fc5889967-hjmxq   1/1     Running   0          28h   10.251.3.56    worker-1.k8s.freedom.org   <none>           <none>
istiod-d56968787-fm2jw                  1/1     Running   0          28h   10.251.4.117   worker-2.k8s.freedom.org   <none>           <none>
[root@master-1.k8s.freedom.org ~ 16:19]# 5> 
```

## istio暴露至集群外
- 默认安装后，在私有云中没有`LoadBalancer Providers`，所以需要创建一个NodePort服务，然后使用haproxy做tcp转发。
- 根据默认的LoadBalancer服务修改，创建NodePort服务文件，其文件`istio-ingressgateway-nodeport.yml`，内容如下。
  ```shell
  apiVersion: v1
  kind: Service
  metadata:
    labels:
      app: istio-ingressgateway
      install.operator.istio.io/owning-resource: installed-state
      install.operator.istio.io/owning-resource-namespace: istio-system
      istio: ingressgateway
      istio.io/rev: default
      operator.istio.io/component: IngressGateways
      operator.istio.io/managed: Reconcile
      release: istio
    name: istio-ingressgateway-nodeport
    namespace: istio-system
  spec:
    type: NodePort
    selector:
      app: istio-ingressgateway
      istio: ingressgateway
    ports:
      - name: status-port
        nodePort: 30021
        port: 15021
        protocol: TCP
        targetPort: 15021
      - name: http2
        nodePort: 30080
        port: 80
        protocol: TCP
        targetPort: 8080
      - name: https
        nodePort: 30443
        port: 443
        protocol: TCP
        targetPort: 8443
  ```