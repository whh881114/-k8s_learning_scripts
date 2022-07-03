# 00-infra-001-服务器清单&DNS解析清单.md

## 服务器清单
- 服务器清单，统计物理机和虚拟机。

    |服务器名称|物理机/虚拟机|WAN段地址|LAN段地址|DMZ段地址|备注|
    |:------|:------|:------|:------|:------|:------|
    |DELL R620物理机|物理机|192.168.1.253|N/A|N/A|iDRAC管理地址为192.168.1.252|
    |pfsense.freedom.org|虚拟机|192.168.1.254|192.168.2.254|192.168.3.254||
    |windows.freedom.org|虚拟机|192.168.2.253|N/A|N/A|windows主机，机器里安装远程桌面软件，方便在其他地方连进来。|
    |vcenter.freedom.org|虚拟机|192.168.2.252|N/A|N/A|vcenter服务器。|
    |ns01.freedom.org|虚拟机|192.168.2.250|N/A|N/A|dns主服务器。|
    |ns02.freedom.org|虚拟机|192.168.2.251|N/A|N/A|dns从服务器。|
    |foreman.freedom.org|虚拟机|N/A|192.168.2.1|N/A||
    |haproxy.freedom.org|虚拟机|N/A|192.168.2.2|N/A||
    |harbor.freedom.org|虚拟机|N/A|192.168.2.3|N/A||
    |nfs.freedom.org|虚拟机|N/A|192.168.2.4|N/A||
    |zabbix.freedom.org|虚拟机|N/A|192.168.2.5|N/A||
    |node01.consul.freedom.org|虚拟机|N/A|192.168.2.6|N/A||
    |node02.consul.freedom.org|虚拟机|N/A|192.168.2.7|N/A||
    |node03.consul.freedom.org|虚拟机|N/A|192.168.2.8|N/A||
    |master01.k8s.freedom.org|虚拟机|N/A|192.168.2.11|N/A||
    |master02.k8s.freedom.org|虚拟机|N/A|192.168.2.12|N/A||
    |master03.k8s.freedom.org|虚拟机|N/A|192.168.2.13|N/A||
    |worker01.k8s.freedom.org|虚拟机|N/A|192.168.2.14|N/A||
    |worker02.k8s.freedom.org|虚拟机|N/A|192.168.2.15|N/A||
    |worker03.k8s.freedom.org|虚拟机|N/A|192.168.2.16|N/A||
    |wanghaohao.indv.freedom.org|虚拟机|N/A|192.168.2.100|N/A|个人实验服务器|
    

