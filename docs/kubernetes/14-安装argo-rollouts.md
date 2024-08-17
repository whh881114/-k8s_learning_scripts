# 安装argo-rollouts


## 参考资料
- https://argoproj.github.io/argo-rollouts/
- https://github.com/argoproj/argo-helm/releases


## 前言
- 配置文件修改起来不难，慢慢修改即可。

- 理解各个服务功能。
  - `rollouts`:      Argo Rollouts is a Kubernetes controller and set of CRDs which provide advanced deployment 
                     capabilities such as blue-green, canary, canary analysis, experimentation, 
                     and progressive delivery features to Kubernetes.
  - `dashboard `:    The Argo Rollouts Kubectl plugin can serve a local UI Dashboard to visualize your Rollouts.              
  - `notifications`: Argo Rollouts provides notifications powered by the Notifications Engine. Controller 
                     administrators can leverage flexible systems of triggers and templates to configure 
                     notifications requested by the end users.                 

