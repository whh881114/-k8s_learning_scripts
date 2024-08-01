# 安装ingress-nginx

### 前言
- https://github.com/kubernetes/ingress-nginx
- https://github.com/kubernetes/ingress-nginx/archive/refs/tags/helm-chart-4.11.1.tar.gz
- https://helm.sh/


## 部署
- 使用helm安装ingress-nginx。
- 下载ingress-nginx的helm chart，修改values.yaml中的相关值。
```shell
controller.image.registry --> "harbor.freedom.org"
controller.image.image --> "registry.k8s.io/ingress-nginx/controller"
controller.image.tag --> "v1.11.1"
controller.image.digest --> "sha256:8f0d2b5885516c9d46c836dbb158446af6a0a9307ca2fd591c21171ff0bf2a7b"

controller.admissionWebhooks.patch.image.registry --> "harbor.freedom.org"
controller.admissionWebhooks.patch.image.image --> "registry.k8s.io/ingress-nginx/kube-webhook-certgen"
controller.admissionWebhooks.patch.image.tag --> "v1.4.1"
controller.admissionWebhooks.patch.image.digest --> "sha256:887b7f4495677473f1bef5bfb48200a1070e526183b515682a7e78e43c7d7da4"

defaultBackend.image.registry --> "harbor.freedom.org"
defaultBackend.image.image --> "registry.k8s.io/defaultbackend-amd64"
defaultBackend.image.tag --> "1.5"

controller.ingressClassResource.name --> "nginx"
controller.ingressClass --> "nginx"
```

## ingress安装日志
```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "NAME: nginx",
            "LAST DEPLOYED: Thu Aug  1 17:03:22 2024",
            "NAMESPACE: ingress-nginx",
            "STATUS: deployed",
            "REVISION: 1",
            "TEST SUITE: None",
            "NOTES:",
            "The ingress-nginx controller has been installed.",
            "It may take a few minutes for the load balancer IP to be available.",
            "You can watch the status by running 'kubectl get service --namespace ingress-nginx nginx-ingress-nginx-controller --output wide --watch'",
            "",
            "An example Ingress that makes use of the controller:",
            "  apiVersion: networking.k8s.io/v1",
            "  kind: Ingress",
            "  metadata:",
            "    name: example",
            "    namespace: foo",
            "  spec:",
            "    ingressClassName: nginx",
            "    rules:",
            "      - host: www.example.com",
            "        http:",
            "          paths:",
            "            - pathType: Prefix",
            "              backend:",
            "                service:",
            "                  name: exampleService",
            "                  port:",
            "                    number: 80",
            "              path: /",
            "    # This section is only required if TLS is to be enabled for the Ingress",
            "    tls:",
            "      - hosts:",
            "        - www.example.com",
            "        secretName: example-tls",
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
            "Error from server (AlreadyExists): namespaces \"ingress-nginx\" already exists"
        ]
    ]
}
```