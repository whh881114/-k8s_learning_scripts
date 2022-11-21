# 01-k8s-004-安装istio.md

## 1. 安装步骤
- 安装istio的demo环境，在ansible主机上执行以下命令即可。
  ```
  ansible-playbook master01.k8s.bj.freedom.org-addons.yml -t istio
  ansible-playbook master01.k8s.sh.freedom.org-addons.yml -t istio
  ansible-playbook master01.k8s.gd.freedom.org-addons.yml -t istio
  ```