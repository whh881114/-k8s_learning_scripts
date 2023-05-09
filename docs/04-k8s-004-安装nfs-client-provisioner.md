# 04-k8s-004-安装nfs-client-provisioner.md

## 重要说明
- 在v1.20.0以上的版本，移除了"RemoveSelfLink"，导致无法使用nfs存储类，网上有解决方法，只需要把此行`- --feature-gates=RemoveSelfLink=false`添加到配置文件`/etc/kubernetes/manifests/kube-apiserver.yaml`，然后执行`kubectl apply -f /etc/kubernetes/manifests/kube-apiserver.yaml`即可，**需要在所有的master节点上执行**。
- https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/issues/25
- storage-class类型，nfs提供pvc功能，其中重点是修改权限这一行，特别是polkitd用户。

## 安装说明
- 安装部署已在`nfs`角色中已声明。
- 在`ansible`主机上执行部署命令：`ansible-playbook deploy-nfs.yml -t nfs`。
- argocd部署时不需要持久化数据所以部署顺序可以调整到argocd之后。
- ~~在bj/sh/gd/hk四个区的master节点上执行生成的manifests文件即可。~~
   
   ~~```shell~~
   
   ~~kubectl apply -f deploy-kubernetes-storageclass-nfs-infra.yaml~~
   
   ~~kubectl apply -f deploy-kubernetes-storageclass-nfs-mysql.yaml~~
   
   ~~kubectl apply -f deploy-kubernetes-storageclass-nfs-redis.yaml~~
   
   ~~```~~
   