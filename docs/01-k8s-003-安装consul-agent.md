# consul-agent安装说明文档

### 安装记要
- consul-agent采用daemonset部署。
- master节点被打了污点，所以要配置tolerations。
- 需要使用主机网络（hostNetwork: true），这样可以和集群外部的consul集群通信。
- 使用容器运行状态中的某些值传递给启动参数。