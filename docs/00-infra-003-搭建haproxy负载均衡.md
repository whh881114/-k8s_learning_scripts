# 00-infra-003-搭建haproxy负载均衡.md

### 前言
- 优先搭建haproxy服务器，为多master节点的k8s集群做准备。

## 部署
- `cd ansible_playbooks && ansible-playbook deploy-haproxy.yml`进行部署即可，所有的配置都在`001-infra-019-haproxy`此角色中。
- 配置k8s apiserver的tcp转发，将6443转至后端master节点即可。
- 配置k8s ingress的tcp转发，将32080/32443转至后端master/worker节点即可。