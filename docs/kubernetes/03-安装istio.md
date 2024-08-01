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
