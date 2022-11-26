# 01-k8s-004-安装istio.md

## 架构
- 安装两个mesh网络，一个叫sun.freedom.org，另一个叫moon.freedom.org。
- 一个mesh网络中，一个istio控制两个k8s集群，sun.freedom.org控制bj.freedom.org和sh.freedom.org；moon.freedom.org控制gd.freedom.org和hk.freedom.org。

## 自定义参数
- https://istio.io/latest/docs/setup/additional-setup/customize-installation/
- https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/

## mesh：sun.freedom.org规划
- bj.freedom.org为primary角色，可自定义参数文件：istio-1.16.0/manifests/profiles/default.yaml，安装命令：istioctl install -f istio-1.16.0/manifests/profiles/default.yaml。
- sh.freedom.org为remote角色，可自定义参数文件：istio-1.16.0/manifests/profiles/remote.yaml，安装命令：istioctl install -f istio-1.16.0/manifests/profiles/remote.yaml。

## mesh：moon.freedom.org规划
- gd.freedom.org为primary角色，可自定义参数文件：istio-1.16.0/manifests/profiles/default.yaml，安装命令：istioctl install -f istio-1.16.0/manifests/profiles/default.yaml。
- hk.freedom.org为remote角色，可自定义参数文件：istio-1.16.0/manifests/profiles/remote.yaml，安装命令：istioctl install -f istio-1.16.0/manifests/profiles/remote.yaml。