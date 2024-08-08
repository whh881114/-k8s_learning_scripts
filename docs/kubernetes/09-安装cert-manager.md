# 安装cert-manager

## 前言
- https://cert-manager.io/docs/
- https://github.com/cert-manager/cert-manager/releases
- https://artifacthub.io/packages/helm/cert-manager/cert-managers

## 部署


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