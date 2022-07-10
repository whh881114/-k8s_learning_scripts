# 00-infra-000-vmware esxi6.5上搭建配置软路由pfsense.md

## 前言
- vmware workstation与esxi的网络有点不一样，在workstation中可以轻松使用nat网络，但在esxi中没有，所以需要自己搭一个软路由。这里在网上找了一个叫pfSense的软件。

## pfSense官网
- https://www.pfsense.org
- https://www.pfsense.org/download/

## 安装文档
- https://docs.netgate.com/pfsense/en/latest/recipes/virtualize-esxi.html

## esxi网络交换机规划
- 默认交换机vSwitch0。
    - vSwitch0，接入外网，并且创建一个WAN的端口组。
- 创建两个vSwitch，一个是LAN，另一个是DMZ。针对我当前网络拓扑，这两个vSwitch均无须配置上行链路端口。
    - LAN，内部私有服务，创建一个LAN端口组。
    - DMZ，DMZ隔离区，放置些对外访问的服务器。

## esxi网络交换机地址规划
|名称|地址|上游网关|
|:----|:----|:----|
|WAN|192.168.1.0/24|192.168.1.1|
|LAN|192.168.2.0/24|N/A|
|DMZ|192.168.3.0/24|N/A|


## pfsense地址规划
- pfsense配置三张网卡——em0/em1/em2，其网卡分别连接WAN/LAN/DMZ网段，详细信息如下。

    |网卡所属esxi交换机端口组|网卡名称|网卡地址|网卡上游网关|
    |:------|:------|:------|:------|
    |WAN|em0|192.168.1.254/24|192.168.1.1|
    |LAN|em1|192.168.2.254/24|N/A|
    |DMZ|em2|192.168.3.254/24|N/A|

## pfsense安装配置
- 配置esxi虚拟交换机。

- 配置pfsense虚拟机，配置三张网卡，分别连接WAN/LAN/DMZ网段。

- 安装过程就按系统提示一步一步安装即可。

- 配置pfsense网络，在终端页面，选择3，配置连接WAN/LAN网段网卡的地址。

- 配置pfsense的DMZ网卡，在终端页面，选择2，分配网卡，WAN/LAN分别选择em0/em1，为最后一个me2增加一个optional网卡，配置好ip即可。后续可以管理界面中把名字改为DMZ。

- 配置pfsense界面访问，因为在当前的网络结构下无法访问管理界面，所以安装一个带有图形界面主机访问pfsense所在LAN网段地址，默认用户名密码分别为`admin`和`pfsense`。

- 配置管理界面可以通过WAN地址访问。进入Firewall/Rules/WAN，增加一条路由规则允许ipv4所有协议都能被访问，配置截图如下。  
  ![pfsense配置WAN口规则结果.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置WAN口规则结果.png "pfsense配置WAN口规则结果.png")  

  ![pfsense配置WAN口规则.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置WAN口规则.png "pfsense配置WAN口规则.png")

- 配置NAT端口转发，将LAN中的ansible主机的ssh转发出来，此外，windows主机的rdp转发出来，配置截图如下。  
  ![pfsense配置NAT转发总览.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置NAT转发总览.png "pfsense配置NAT转发总览.png")  

  ![pfsense配置NAT转发--SSH.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置NAT转发--SSH.png "pfsense配置NAT转发--SSH.png")

  ![pfsense配置NAT转发--MSRDP.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置NAT转发--MSRDP.png "pfsense配置NAT转发--MSRDP.png")

- 配置DMZ区可以访问外网，配置方法与WAN一致，截图如下。  
  ![pfsense配置DMZ口规则结果.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置DMZ口规则结果.png "pfsense配置DMZ口规则结果.png")  

  ![pfsense配置DMZ口规则.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置DMZ口规则.png "pfsense配置DMZ口规则.png")

- 至此，pfsense防火墙配置已完成了我所需要的最基本需求。此外，DMZ区暂时还没有用上。

## pfsense配置静态路由：打通k8s集群外部主机与pod通信
- 配置网关。  
  ![pfsense配置网关.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置网关.png "pfsense配置网关.png")  
  
  ![pfsense配置网关总览.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置网关总览.png "pfsense配置网关总览.png")

- 静态网关总览。  
  ![pfsense配置静态路由.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置静态路由.png "pfsense配置静态路由.png")  
  
  ![pfsense配置静态路由总览.png](https://github.com/whh881114/k8s_learning_scripts/blob/master/docs/images/pfsense配置静态路由总览.png "pfsense配置静态路由总览.png")