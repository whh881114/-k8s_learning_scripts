# 安装cert-manager

## 前言
- https://cert-manager.io/docs/
- https://github.com/cert-manager/cert-manager/releases
- https://artifacthub.io/packages/helm/cert-manager/cert-managers
- https://github.com/topics/cert-manager-webhook
- https://github.com/snowdrop/godaddy-webhook

## 部署
- 主要是调整镜像地址，另外，手动安装crds，其次，相对应的deployment启用多副本，同时开启`podDisruptionBudget.enabled=true`。

## 结果
```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "NAME: cert-manager",
            "LAST DEPLOYED: Thu Aug  8 15:27:48 2024",
            "NAMESPACE: cert-manager",
            "STATUS: deployed",
            "REVISION: 1",
            "TEST SUITE: None",
            "NOTES:",
            "cert-manager v1.15.2 has been deployed successfully!",
            "",
            "In order to begin issuing certificates, you will need to set up a ClusterIssuer",
            "or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).",
            "",
            "More information on the different types of issuers and how to configure them",
            "can be found in our documentation:",
            "",
            "https://cert-manager.io/docs/configuration/",
            "",
            "For information on how to configure cert-manager to automatically provision",
            "Certificates for Ingress resources, take a look at the `ingress-shim`",
            "documentation:",
            "",
            "https://cert-manager.io/docs/usage/ingress/"
        ],
        []
    ]
}
```

## ACME签发证书流程
```shell
- 创建`dns-provider`，如果provider在此清单中就忽略，如果不在就使用webhook即可，
  https://cert-manager.io/docs/configuration/acme/dns01/#supported-dns01-providers
  https://cert-manager.io/docs/configuration/acme/dns01/#webhook

- 创建ClusterIssuer: 定义证书颁发机构（CA），例如Let's Encrypt。

- 创建Certificate: 定义要申请的证书，包括 DNS 名称、密钥使用等信息。 

- Cert-Manager 自动申请证书: Cert-Manager 会根据 Issuer 和 Certificate 的配置，向 CA 申请证书。

- 证书存储: 签发的证书会被存储在 Kubernetes Secret 中。
```

## ACME创建示例
- 目前我使用的是GoDaddy厂商证书，因为网络问题没办法签发成功。文档地址：https://github.com/snowdrop/godaddy-webhook。

- 创建GoDaddy的密钥对地址：https://api.godaddy.com。

- 创建示例。
```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: godaddy-api-key-ote-idc
  namespace: cert-manager
type: Opaque
stringData:
  token: <GODADDY_API_KEY:GODADDY_SECRET_KEY>


---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: whh881114@gmail.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - selector:
          dnsZones:
            - "*.idc.roywong.top"
            - "*.idc-ingress-nginx.roywong.top"
            - "*.idc-ingress-istio.roywong.top"
        dns01:
          webhook:
            config:
              apiKeySecretRef:
                name: godaddy-api-key-ote-idc
                key: token
              production: true
              ttl: 600
            groupName: acme.mycompany.com
            solverName: godaddy

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-idc-roywong-top
  namespace: cert-manager
spec:
  secretName: tls-unavailable-wildcard-idc-roywong-top
  renewBefore: 240h
  dnsNames:
    - "*.idc.roywong.top"
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
```

- 结果，其中clusterissuer和certificate的状态是True就表示是正常的，其中wildcard-idc-roywong-top证书状态是False，这个表示签发失败。
  查看cert-manager-controller的日志可以看出是什么原因导致。
```shell
I0811 04:15:45.896256       1 dns.go:90] "presenting DNS01 challenge for domain" logger="cert-manager.controller.Present" resource_name="wildcard-idc-roywong-top-1-287666903-3311906022" resource_namespace="cert-manager" resource_kind="Challenge" resource_version="v1" dnsName="idc.roywong.top" type="DNS-01" resource_name="wildcard-idc-roywong-top-1-287666903-3311906022" resource_namespace="cert-manager" resource_kind="Challenge" resource_version="v1" domain="idc.roywong.top"
E0811 04:16:15.904690       1 controller.go:162] "re-queuing item due to error processing" err="Unable to check the TXT record: Get \"https://api.godaddy.com/v1/domains/roywong.top/records/TXT/_acme-challenge.idc\": context deadline exceeded (Client.Timeout exceeded while awaiting headers)" logger="cert-manager.controller" key="cert-manager/wildcard-idc-roywong-top-1-287666903-3311906022"
```

```shell
[root@master-1.k8s.freedom.org ~/tmp 12:09]# 14> kubectl get clusterissuer
NAME               READY   AGE
letsencrypt-prod   True    40s
[root@master-1.k8s.freedom.org ~/tmp 12:10]# 15> 

[root@master-1.k8s.freedom.org ~/tmp 12:14]# 17> kubectl get certificate -n cert-manager
NAME                          READY   SECRET                                     AGE
godaddy-webhook-ca            True    godaddy-webhook-ca                         20m
godaddy-webhook-webhook-tls   True    godaddy-webhook-webhook-tls                20m
wildcard-idc-roywong-top      False   tls-unavailable-wildcard-idc-roywong-top   4m40s
[root@master-1.k8s.freedom.org ~/tmp 12:14]# 18> 

[root@master-1.k8s.freedom.org ~/tmp 12:15]# 20> kubectl describe certificate wildcard-idc-roywong-top -n cert-manager
Name:         wildcard-idc-roywong-top
Namespace:    cert-manager
Labels:       <none>
Annotations:  <none>
API Version:  cert-manager.io/v1
Kind:         Certificate
Metadata:
  Creation Timestamp:  2024-08-11T04:09:51Z
  Generation:          1
  Resource Version:    4506166
  UID:                 34996818-48aa-4327-93aa-6bc25e6c7c7d
Spec:
  Dns Names:
    *.idc.roywong.top
  Issuer Ref:
    Kind:        ClusterIssuer
    Name:        letsencrypt-prod
  Renew Before:  240h
  Secret Name:   tls-unavailable-wildcard-idc-roywong-top
Status:
  Conditions:
    Last Transition Time:        2024-08-11T04:09:51Z
    Message:                     Issuing certificate as Secret does not exist
    Observed Generation:         1
    Reason:                      DoesNotExist
    Status:                      False
    Type:                        Ready
    Last Transition Time:        2024-08-11T04:09:51Z
    Message:                     Issuing certificate as Secret does not exist
    Observed Generation:         1
    Reason:                      DoesNotExist
    Status:                      True
    Type:                        Issuing
  Next Private Key Secret Name:  wildcard-idc-roywong-top-2qdvt
Events:
  Type    Reason     Age    From                                       Message
  ----    ------     ----   ----                                       -------
  Normal  Issuing    5m56s  cert-manager-certificates-trigger          Issuing certificate as Secret does not exist
  Normal  Generated  5m55s  cert-manager-certificates-key-manager      Stored new private key in temporary Secret resource "wildcard-idc-roywong-top-2qdvt"
  Normal  Requested  5m55s  cert-manager-certificates-request-manager  Created new CertificateRequest resource "wildcard-idc-roywong-top-1"
[root@master-1.k8s.freedom.org ~/tmp 12:15]# 21> 
```

## 使用证书
- 因为没有签发成功，但是我根据kubernetes-dashboard的helm包查看模板得到的内容。实质上就是增加annotations，其他的和平常使用的配置方法没有区别。
```yaml
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: kubernetes-dashboard
spec:
  rules:
    - host: kubernetes-dashboard.idc.roywong.top
      http:
        paths:
          - path: /
            backend:
              serviceName: backend-service
              servicePort: 80
  tls:
    - hosts:
        - '*.idc.roywong.top'
      secretName: tls-unavailable-wildcard-idc-roywong-top
```
