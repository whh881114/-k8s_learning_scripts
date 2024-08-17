# 安装argo-cd


## 参考资料
- https://argo-cd.readthedocs.io/en/stable/
- https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd
- https://argo-cd.readthedocs.io/en/stable/operator-manual/architecture/
- https://github.com/DandyDeveloper/charts/blob/master/charts/redis-ha/values.yaml
- https://argo-cd.readthedocs.io/en/stable/operator-manual/high_availability/
- https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/
- https://github.com/bitnami-labs/sealed-secrets


## 前言
- 以高可用模式部署。
- 理解各个服务功能。
  - `argocd-application-controller`:    The argocd-application-controller uses argocd-repo-server to get generated 
                                        manifests and Kubernetes API server to get the actual cluster state.
  - `argocd-repo-server`:               The argocd-repo-server is responsible for cloning Git repository, keeping it 
                                        up to date and generating manifests using the appropriate tool.
  - `argocd-server`:                    The argocd-server is stateless and probably the least likely to cause issues. 
                                        To ensure there is no downtime during upgrades, consider increasing the number 
                                        of replicas to 3 or more and repeat the number in the 
                                        ARGOCD_API_SERVER_REPLICAS environment variable.
  - `redis-ha-server`:                  argocd-redis is pre-configured with the understanding of only three total 
                                        redis servers/sentinels.
  - `argocd-dex-server`:                The argocd-dex-server uses an in-memory database, and two or more instances 
                                        would have inconsistent data. 
  - `argocd-applicationset-controller`: The ApplicationSet controller adds Application automation and seeks to improve 
                                        multi-cluster support and cluster multitenant support within Argo CD.
  - `argocd-notifications-controller`:  Argo CD Notifications continuously monitors Argo CD applications and provides 
                                        a flexible way to notify users about important changes in the application state. 


## 安装
- `values.yaml`文件内容不算复杂，配置起来还不算复杂，如果安装报错，根据错误信息再结合template进行排查即可。
- 启用`redis-ha`时，不需要再启用`haproxy`，这个配置项目是建议连接外部的`redis-cluster`。
- 启用`redis-ha`时，还需要配置`externalRedis.existingSecret="argocd-redis"`，如果此值为空，那么安装时会报错。


## 结果
```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "customresourcedefinition.apiextensions.k8s.io \"applications.argoproj.io\" deleted",
            "customresourcedefinition.apiextensions.k8s.io \"applicationsets.argoproj.io\" deleted",
            "customresourcedefinition.apiextensions.k8s.io \"appprojects.argoproj.io\" deleted",
            "NAME: argo-cd",
            "LAST DEPLOYED: Sat Aug 17 17:16:56 2024",
            "NAMESPACE: argo",
            "STATUS: deployed",
            "REVISION: 1",
            "NOTES:",
            "In order to access the server UI you have the following options:",
            "",
            "1. kubectl port-forward service/argo-cd-argocd-server -n argo 8080:443",
            "",
            "    and then open the browser on http://localhost:8080 and accept the certificate",
            "",
            "2. enable ingress in the values file `server.ingress.enabled` and either",
            "      - Add the annotation for ssl passthrough: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-1-ssl-passthrough",
            "      - Set the `configs.params.\"server.insecure\"` in the values file and terminate SSL at your ingress: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-2-multiple-ingress-objects-and-hosts",
            "",
            "",
            "After reaching the UI the first time you can login with username: admin and the random password generated during the installation. You can find the password by running:",
            "",
            "kubectl -n argo get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d",
            "",
            "(You should delete the initial secret afterwards as suggested by the Getting Started Guide: https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli)"
        ],
        [
            "Error: uninstall: Release not loaded: argo-cd: release: not found"
        ]
    ]
}
```

```shell
[root@master-1.k8s.freedom.org ~ 17:21]# 1> kubectl get pods -o wide -n argo
NAME                                                        READY   STATUS    RESTARTS        AGE     IP             NODE                       NOMINATED NODE   READINESS GATES
argo-cd-argocd-application-controller-0                     1/1     Running   0               4m17s   10.251.3.67    worker-1.k8s.freedom.org   <none>           <none>
argo-cd-argocd-application-controller-1                     1/1     Running   0               4m6s    10.251.5.50    worker-3.k8s.freedom.org   <none>           <none>
argo-cd-argocd-application-controller-2                     1/1     Running   0               3m56s   10.251.4.69    worker-2.k8s.freedom.org   <none>           <none>
argo-cd-argocd-applicationset-controller-584986cc45-45npj   1/1     Running   0               4m17s   10.251.5.31    worker-3.k8s.freedom.org   <none>           <none>
argo-cd-argocd-applicationset-controller-584986cc45-gb9kk   1/1     Running   0               4m17s   10.251.4.139   worker-2.k8s.freedom.org   <none>           <none>
argo-cd-argocd-applicationset-controller-584986cc45-w9q8z   1/1     Running   0               4m17s   10.251.3.248   worker-1.k8s.freedom.org   <none>           <none>
argo-cd-argocd-dex-server-78dbdb8587-vtfd4                  1/1     Running   2 (4m14s ago)   4m17s   10.251.3.206   worker-1.k8s.freedom.org   <none>           <none>
argo-cd-argocd-notifications-controller-866c86f9f6-rc9br    1/1     Running   0               4m17s   10.251.3.55    worker-1.k8s.freedom.org   <none>           <none>
argo-cd-argocd-repo-server-6cf4d7d96c-dqlm8                 1/1     Running   0               4m2s    10.251.5.176   worker-3.k8s.freedom.org   <none>           <none>
argo-cd-argocd-repo-server-6cf4d7d96c-jrfmn                 1/1     Running   0               4m17s   10.251.3.165   worker-1.k8s.freedom.org   <none>           <none>
argo-cd-argocd-repo-server-6cf4d7d96c-rh74l                 1/1     Running   0               4m2s    10.251.4.201   worker-2.k8s.freedom.org   <none>           <none>
argo-cd-argocd-server-7cfd7cd965-98ntr                      1/1     Running   0               4m17s   10.251.3.141   worker-1.k8s.freedom.org   <none>           <none>
argo-cd-argocd-server-7cfd7cd965-d4qts                      1/1     Running   0               4m2s    10.251.5.135   worker-3.k8s.freedom.org   <none>           <none>
argo-cd-argocd-server-7cfd7cd965-j4cff                      1/1     Running   0               4m2s    10.251.4.241   worker-2.k8s.freedom.org   <none>           <none>
argo-cd-redis-ha-server-0                                   3/3     Running   0               4m17s   10.251.3.247   worker-1.k8s.freedom.org   <none>           <none>
argo-cd-redis-ha-server-1                                   3/3     Running   0               3m1s    10.251.5.251   worker-3.k8s.freedom.org   <none>           <none>
argo-cd-redis-ha-server-2                                   3/3     Running   0               2m1s    10.251.4.106   worker-2.k8s.freedom.org   <none>           <none>
argo-rollouts-d8977db6f-f7jm9                               1/1     Running   0               3m53s   10.251.5.57    worker-3.k8s.freedom.org   <none>           <none>
argo-rollouts-d8977db6f-h6f5r                               1/1     Running   0               3m53s   10.251.4.223   worker-2.k8s.freedom.org   <none>           <none>
argo-rollouts-d8977db6f-w5cfz                               1/1     Running   0               3m53s   10.251.3.95    worker-1.k8s.freedom.org   <none>           <none>
argo-rollouts-dashboard-7f58bf9575-fxqbq                    1/1     Running   0               3m53s   10.251.4.231   worker-2.k8s.freedom.org   <none>           <none>
argo-rollouts-dashboard-7f58bf9575-j9mz6                    1/1     Running   0               3m53s   10.251.5.48    worker-3.k8s.freedom.org   <none>           <none>
argo-rollouts-dashboard-7f58bf9575-trt89                    1/1     Running   0               3m53s   10.251.3.96    worker-1.k8s.freedom.org   <none>           <none>
[root@master-1.k8s.freedom.org ~ 17:21]# 2> 
```