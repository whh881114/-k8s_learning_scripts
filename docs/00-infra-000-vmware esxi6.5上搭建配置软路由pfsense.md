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
    
- 创建四个vSwitch，分别是BJ-LAN/SH-LAN/GD-LAN/HK-LAN，模拟企业分支机构网络。


## esxi网络交换机地址规划
|名称|地址|上游网关|
|:----|:----|:----|
|WAN|192.168.1.0/24|192.168.1.1|
|LAN|192.168.2.0/24|N/A|
|DMZ|192.168.3.0/24|N/A|
|BJ-LAN|192.168.4.0/24|N/A|
|SH-LAN|192.168.5.0/24|N/A|
|GD-LAN|192.168.6.0/24|N/A|
|HK-LAN|192.168.7.0/24|N/A|


## pfsense地址规划
- pfsense配置六张网卡——em{0..6}，详细信息如下。

    |网卡所属esxi交换机端口组|网卡名称|网卡地址|网卡上游网关|备注|
    |:------|:------|:------|:------|:------|
    |WAN|em0|192.168.1.254/24|192.168.1.1|外网网段，即直连互联网。|
    |LAN|em1|192.168.2.254/24|N/A|企业内部网段，用于业务部署。|
    |DMZ|em2|192.168.3.254/24|N/A|企业内部网段，用于隔离业务网络，作为业务网络的入口。|
    |BJ-LAN|em3|192.168.4.254/24|N/A|企业分支机构网络。|
    |SH-LAN|em4|192.168.5.254/24|N/A|企业分支机构网络。|
    |GD-LAN|em5|192.168.6.254/24|N/A|企业分支机构网络。|
    |HK-LAN|em6|192.168.7.254/24|N/A|企业分支机构网络。|


## pfsense安装配置
- 配置esxi虚拟交换机。

- 配置pfsense虚拟机，配置7张网卡，分别连接WAN/LAN/DMZ/BJ-LAN/SH-LAN/GD-LAN/HK-LAN网段。

- 安装过程就按系统提示一步一步安装即可。

- 配置pfsense网络，在终端页面，选择2，配置网卡的地址，核心在于配置WAN口地址，即配置为192.168.1.254。管理界面默认用户名密码分别为`admin`和`pfsense`，后续可以管理界面中配置各个网卡的名字和地址。


## pfsense各网段开启路由
- 各个网段开启路由后，网段内的主机才可以访问外网。
  
  ![PFSENSE-WAN口路由信息.png](images/pfsense/PFSENSE-WAN口路由信息.png "PFSENSE-WAN口路由信息.png")
  
  ![PFSENSE-LAN口路由信息.png](images/pfsense/PFSENSE-LAN口路由信息.png "PFSENSE-LAN口路由信息.png")
  
  ![PFSENSE-DMZ口路由信息.png](images/pfsense/PFSENSE-DMZ口路由信息.png "PFSENSE-DMZ口路由信息.png")
  
  ![PFSENSE-BJ-LAN口路由信息.png](images/pfsense/PFSENSE-BJ-LAN口路由信息.png "PFSENSE-BJ-LAN口路由信息.png")
  
  ![PFSENSE-SH-LAN口路由信息.png](images/pfsense/PFSENSE-SH-LAN口路由信息.png "PFSENSE-SH-LAN口路由信息.png")
  
  ![PFSENSE-GD-LAN口路由信息.png](images/pfsense/PFSENSE-GD-LAN口路由信息.png "PFSENSE-GD-LAN口路由信息.png")
  
  ![PFSENSE-HK-LAN口路由信息.png](images/pfsense/PFSENSE-HK-LAN口路由信息.png "PFSENSE-HK-LAN口路由信息.png")
 

## pfsense配置NAT端口转发
- 配置NAT端口转发，将DMZ区中个人linux主机的ssh协议和windows主机的rdp协议转发出来，配置截图如下。  
  ![PFSENSE-NAT端口转发总览.png](images/pfsense/PFSENSE-NAT端口转发总览.png "PFSENSE-NAT端口转发总览.png")


## pfsense配置dhcp中继
- 配置DHCP中继则可以实现跨网段自动安装操作系统。
  ![PFSENSE-DHCP中继.png](images/pfsense/PFSENSE-DHCP中继.png "PFSENSE-DHCP中继.png")


## pfsense配置静态路由
- 打通各个k8s集群外部主机与pod通信，当前环境有istio，暂时关闭路由。
  ![PFSENSE-配置网关.png](images/pfsense/PFSENSE-配置网关.png "PFSENSE-配置网关.png")
  
  ![PFSENSE-配置静态路由.png](images/pfsense/PFSENSE-配置静态路由.png "PFSENSE-配置静态路由.png")
