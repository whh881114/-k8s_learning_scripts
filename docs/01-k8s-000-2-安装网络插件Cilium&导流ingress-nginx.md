# 01-k8s-000-3安装网络插件Cilium&导流ingress-nginx.md

### 前言
- cilium网站：https://docs.cilium.io
- ingress-nginx网站：https://github.com/kubernetes/ingress-nginx
- 等k8s集群安装好后，再装网络插件cilium和ingress-nginx。
- 使用k8s-v1.21.5版本时，安装ingress时不能用3.x.x版本的chart了，需要改用4.x.x，当前使用的是4.0.3。
- 使用k8s-v1.18.20版本时，安装ingress时使用用3.x.x版本的chart了，当前使用的是3.38.0。

## 部署
- `cd ansible_playbooks && ansible-playbook deploy-kubernetes-master01-addons.yml`进行部署即可。

## 集群状态
```shell
[root@master01.k8s.freedom.org /tmp 15:40]# 20> kubectl get nodes -o wide
NAME                       STATUS   ROLES                  AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION                CONTAINER-RUNTIME
master01.k8s.freedom.org   Ready    control-plane,master   130m   v1.22.2   192.168.2.11   <none>        CentOS Linux 7 (Core)   5.4.197-1.el7.elrepo.x86_64   docker://20.10.8
master02.k8s.freedom.org   Ready    control-plane,master   129m   v1.22.2   192.168.2.12   <none>        CentOS Linux 7 (Core)   5.4.197-1.el7.elrepo.x86_64   docker://20.10.8
master03.k8s.freedom.org   Ready    control-plane,master   128m   v1.22.2   192.168.2.13   <none>        CentOS Linux 7 (Core)   5.4.197-1.el7.elrepo.x86_64   docker://20.10.8
worker01.k8s.freedom.org   Ready    <none>                 117m   v1.22.2   192.168.2.14   <none>        CentOS Linux 7 (Core)   5.4.197-1.el7.elrepo.x86_64   docker://20.10.8
worker02.k8s.freedom.org   Ready    <none>                 116m   v1.22.2   192.168.2.15   <none>        CentOS Linux 7 (Core)   5.4.197-1.el7.elrepo.x86_64   docker://20.10.8
worker03.k8s.freedom.org   Ready    <none>                 116m   v1.22.2   192.168.2.16   <none>        CentOS Linux 7 (Core)   5.4.197-1.el7.elrepo.x86_64   docker://20.10.8
[root@master01.k8s.freedom.org /tmp 15:40]# 21> 
```

## POD状态
```shell
[root@master01.k8s.freedom.org /tmp 15:41]# 25> kubectl get pod --all-namespaces -o wide
NAMESPACE     NAME                                               READY   STATUS    RESTARTS       AGE     IP             NODE                       NOMINATED NODE   READINESS GATES
kube-system   cilium-42qt4                                       1/1     Running   0              98s     192.168.2.15   worker02.k8s.freedom.org   <none>           <none>
kube-system   cilium-5th2z                                       1/1     Running   0              97s     192.168.2.14   worker01.k8s.freedom.org   <none>           <none>
kube-system   cilium-9x8mg                                       1/1     Running   0              98s     192.168.2.13   master03.k8s.freedom.org   <none>           <none>
kube-system   cilium-brvn6                                       1/1     Running   0              98s     192.168.2.16   worker03.k8s.freedom.org   <none>           <none>
kube-system   cilium-gd2hd                                       1/1     Running   0              97s     192.168.2.12   master02.k8s.freedom.org   <none>           <none>
kube-system   cilium-jjxch                                       1/1     Running   0              97s     192.168.2.11   master01.k8s.freedom.org   <none>           <none>
kube-system   cilium-operator-6bbdb895b5-lmwnl                   1/1     Running   0              4m41s   192.168.2.16   worker03.k8s.freedom.org   <none>           <none>
kube-system   coredns-78fcd69978-fbn25                           1/1     Running   0              131m    10.0.1.114     master02.k8s.freedom.org   <none>           <none>
kube-system   coredns-78fcd69978-hghzm                           1/1     Running   0              131m    10.0.1.170     master02.k8s.freedom.org   <none>           <none>
kube-system   etcd-master01.k8s.freedom.org                      1/1     Running   0              131m    192.168.2.11   master01.k8s.freedom.org   <none>           <none>
kube-system   etcd-master02.k8s.freedom.org                      1/1     Running   0              130m    192.168.2.12   master02.k8s.freedom.org   <none>           <none>
kube-system   etcd-master03.k8s.freedom.org                      1/1     Running   0              129m    192.168.2.13   master03.k8s.freedom.org   <none>           <none>
kube-system   hubble-relay-84999fcb48-7dqn6                      1/1     Running   0              98s     10.0.3.64      worker02.k8s.freedom.org   <none>           <none>
kube-system   hubble-ui-9b6d87f-q6lnf                            3/3     Running   0              98s     10.0.5.165     worker01.k8s.freedom.org   <none>           <none>
kube-system   kube-apiserver-master01.k8s.freedom.org            1/1     Running   0              131m    192.168.2.11   master01.k8s.freedom.org   <none>           <none>
kube-system   kube-apiserver-master02.k8s.freedom.org            1/1     Running   0              130m    192.168.2.12   master02.k8s.freedom.org   <none>           <none>
kube-system   kube-apiserver-master03.k8s.freedom.org            1/1     Running   0              129m    192.168.2.13   master03.k8s.freedom.org   <none>           <none>
kube-system   kube-controller-manager-master01.k8s.freedom.org   1/1     Running   1 (130m ago)   131m    192.168.2.11   master01.k8s.freedom.org   <none>           <none>
kube-system   kube-controller-manager-master02.k8s.freedom.org   1/1     Running   0              130m    192.168.2.12   master02.k8s.freedom.org   <none>           <none>
kube-system   kube-controller-manager-master03.k8s.freedom.org   1/1     Running   0              128m    192.168.2.13   master03.k8s.freedom.org   <none>           <none>
kube-system   kube-proxy-7gthg                                   1/1     Running   0              117m    192.168.2.16   worker03.k8s.freedom.org   <none>           <none>
kube-system   kube-proxy-8tnfk                                   1/1     Running   0              129m    192.168.2.13   master03.k8s.freedom.org   <none>           <none>
kube-system   kube-proxy-gwwpd                                   1/1     Running   0              130m    192.168.2.12   master02.k8s.freedom.org   <none>           <none>
kube-system   kube-proxy-jq2hw                                   1/1     Running   0              131m    192.168.2.11   master01.k8s.freedom.org   <none>           <none>
kube-system   kube-proxy-qgndq                                   1/1     Running   0              118m    192.168.2.14   worker01.k8s.freedom.org   <none>           <none>
kube-system   kube-proxy-sf4dx                                   1/1     Running   0              117m    192.168.2.15   worker02.k8s.freedom.org   <none>           <none>
kube-system   kube-scheduler-master01.k8s.freedom.org            1/1     Running   1 (130m ago)   131m    192.168.2.11   master01.k8s.freedom.org   <none>           <none>
kube-system   kube-scheduler-master02.k8s.freedom.org            1/1     Running   0              130m    192.168.2.12   master02.k8s.freedom.org   <none>           <none>
kube-system   kube-scheduler-master03.k8s.freedom.org            1/1     Running   0              129m    192.168.2.13   master03.k8s.freedom.org   <none>           <none>
[root@master01.k8s.freedom.org /tmp 15:41]# 26> 
```

## 补充：ingress安装日志
```ansible
TASK [001-infra-022-ingress-nginx : show install ingress-nginx log] ********************************************************************************************************************************************************************************************
ok: [master01.k8s.freedom.org] => {
    "msg": [
        [
            "namespace/ingress-nginx created", 
            "NAME: ingress-nginx", 
            "LAST DEPLOYED: Sat Jun 11 15:52:03 2022", 
            "NAMESPACE: ingress-nginx", 
            "STATUS: deployed", 
            "REVISION: 1", 
            "TEST SUITE: None", 
            "NOTES:", 
            "The ingress-nginx controller has been installed.", 
            "Get the application URL by running these commands:", 
            "  export HTTP_NODE_PORT=32080", 
            "  export HTTPS_NODE_PORT=32443", 
            "  export NODE_IP=$(kubectl --namespace ingress-nginx get nodes -o jsonpath=\"{.items[0].status.addresses[1].address}\")", 
            "", 
            "  echo \"Visit http://$NODE_IP:$HTTP_NODE_PORT to access your application via HTTP.\"", 
            "  echo \"Visit https://$NODE_IP:$HTTPS_NODE_PORT to access your application via HTTPS.\"", 
            "", 
            "An example Ingress that makes use of the controller:", 
            "", 
            "  apiVersion: networking.k8s.io/v1", 
            "  kind: Ingress", 
            "  metadata:", 
            "    annotations:", 
            "      kubernetes.io/ingress.class: nginx", 
            "    name: example", 
            "    namespace: foo", 
            "  spec:", 
            "    rules:", 
            "      - host: www.example.com", 
            "        http:", 
            "          paths:", 
            "            - backend:", 
            "                serviceName: exampleService", 
            "                servicePort: 80", 
            "              path: /", 
            "    # This section is only required if TLS is to be enabled for the Ingress", 
            "    tls:", 
            "        - hosts:", 
            "            - www.example.com", 
            "          secretName: example-tls", 
            "", 
            "If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:", 
            "", 
            "  apiVersion: v1", 
            "  kind: Secret", 
            "  metadata:", 
            "    name: example-tls", 
            "    namespace: foo", 
            "  data:", 
            "    tls.crt: <base64 encoded cert>", 
            "    tls.key: <base64 encoded key>", 
            "  type: kubernetes.io/tls"
        ], 
        [
            "Error: uninstall: Release not loaded: ingress-nginx: release: not found"
        ]
    ]
}
```