# 安装cert-manager

## 前言
- https://cert-manager.io/docs/
- https://github.com/cert-manager/cert-manager/releases
- https://artifacthub.io/packages/helm/cert-manager/cert-managers

## 部署

## 工作流程
```shell
理解 Cert-Manager 的工作流程
在 Cert-Manager 中，获取 ACME 签发的证书主要分为以下几个步骤：

创建 Issuer: 定义证书颁发机构（CA），例如 Let's Encrypt。
创建 Certificate: 定义要申请的证书，包括 DNS 名称、密钥使用等信息。
Cert-Manager 自动申请证书: Cert-Manager 会根据 Issuer 和 Certificate 的配置，向 CA 申请证书。
证书存储: 签发的证书会被存储在 Kubernetes Secret 中。
```

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