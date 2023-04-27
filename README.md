# k8s_learning_scripts

## 说明
- 将原来存放在`ansible_playbooks`仓库中的k8s相关的manifests独立出来。

## TODO
- 当前有四个k8s集群，istio控制平台安装在bj集群，其他的作来接入此集群。
- bj集群中部署内部GITLAB，学习GITLAB的CI/CD功能。
- bj集群中部署prometheus-operator监控本集群数据，同时也要监控其他集群数据。
- bj集群中部署argocd工具来实现gitops，理论上来说，各环境就应该部署一个argocd，互不影响。
- 当前的静态的yaml文件，用jsonnet实现，减少代码的冗余程度。