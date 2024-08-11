# 安装kubernetes-dashboard

## 前言
- https://github.com/kubernetes/dashboard/releases/download/kubernetes-dashboard-7.5.0/kubernetes-dashboard-7.5.0.tgz

## 部署
- 使用helm安装kubernetes-dashboard。

- kong需要声明image和tag。
  ```yaml
  kong:
    enabled: true
    image:
      repository: kong/kong
      tag: 3.6.x # 或指定具体的版本号
    ## Configuration reference: https://docs.konghq.com/gateway/3.6.x/reference/configuration
    env:
      dns_order: LAST,A,CNAME,AAAA,SRV
      plugins: 'off'
      nginx_worker_processes: 1
    ingressController:
      enabled: false
    dblessConfig:
      configMap: kong-dbless-config
    proxy:
      type: NodePort
      http:
        enabled: true
  ```

- **因为环境中暂时没有https证书，所以启用了http，但是，这里出现问题了，必须要用https协议，否则会出现401
  错误。所以，这里kong.proxy.type指定为NodePort，可以复现登录错误。**
  ```shell
  2024-08-08 11:07:31.822 E0808 03:07:31.822540       1 handler.go:33] "Could not get user" err="MSG_LOGIN_UNAUTHORIZED_ERROR"
  2024-08-08 11:06:38.607 I0808 03:06:38.607705       1 main.go:41] "Listening and serving insecurely on" address="0.0.0.0:8000"
  2024-08-08 11:06:38.607 I0808 03:06:38.607522       1 init.go:47] Using in-cluster config
  2024-08-08 11:06:38.607 I0808 03:06:38.607466       1 main.go:34] "Starting Kubernetes Dashboard Auth" version="1.1.3"
  ```
  


## 安装结果
```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "release \"kubernetes-dashboard\" uninstalled",
            "NAME: kubernetes-dashboard",
            "LAST DEPLOYED: Thu Aug  8 11:30:25 2024",
            "NAMESPACE: kubernetes-dashboard",
            "STATUS: deployed",
            "REVISION: 1",
            "TEST SUITE: None",
            "NOTES:",
            "*************************************************************************************************",
            "*** PLEASE BE PATIENT: Kubernetes Dashboard may need a few minutes to get up and become ready ***",
            "*************************************************************************************************",
            "",
            "Congratulations! You have just installed Kubernetes Dashboard in your cluster.",
            "",
            "To access Dashboard run:",
            "  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443",
            "",
            "NOTE: In case port-forward command does not work, make sure that kong service name is correct.",
            "      Check the services in Kubernetes Dashboard namespace using:",
            "        kubectl -n kubernetes-dashboard get svc",
            "",
            "Dashboard will be available at:",
            "  https://localhost:8443",
            "",
            "",
            "",
            "Looks like you are deploying Kubernetes Dashboard on a custom domain(s).",
            "Please make sure that the ingress configuration is valid.",
            "Dashboard should be accessible on your configured domain(s) soon:",
            "  - https://kubernetes-dashboard.ingress-nginx.freedom.org",
            "  - https://k8s-dash.ingress-nginx.freedom.org"
        ],
        []
    ]
}
```