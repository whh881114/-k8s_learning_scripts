# 00-infra-001-服务器清单&DNS解析清单.md

## 服务器清单
- 服务器清单，统计物理机和虚拟机。

    |服务器名称|物理机/虚拟机|WAN段地址|LAN段地址|DMZ段地址|备注|
    |:------|:------|:------|:------|:------|:------|
    |DELL R620物理机|物理机|192.168.1.253|N/A|N/A|iDRAC管理地址为192.168.1.252|
    |pfsense.freedom.org|虚拟机|192.168.1.254|192.168.2.254|192.168.3.254||
    |windows.freedom.org|虚拟机|192.168.1.253|N/A|N/A|windows主机，机器里安装远程桌面软件，方便在其他地方连进来。|
    |vcenter.freedom.org|虚拟机|192.168.1.252|N/A|N/A|vcenter服务器。|
    |foreman.freedom.org|虚拟机|N/A|192.168.2.1|N/A||
    |haproxy.freedom.org|虚拟机|N/A|192.168.2.2|N/A||
    |harbor.freedom.org|虚拟机|N/A|192.168.2.3|N/A||
    |master01.k8s.freedom.org|虚拟机|N/A|192.168.2.11|N/A||
    |master02.k8s.freedom.org|虚拟机|N/A|192.168.2.12|N/A||
    |master03.k8s.freedom.org|虚拟机|N/A|192.168.2.13|N/A||
    |worker01.k8s.freedom.org|虚拟机|N/A|192.168.2.14|N/A||
    |worker02.k8s.freedom.org|虚拟机|N/A|192.168.2.15|N/A||
    |worker03.k8s.freedom.org|虚拟机|N/A|192.168.2.16|N/A|N/A||
    |node01.ceph.freedom.org|虚拟机|N/A|192.168.2.21|N/A||
    |node02.ceph.freedom.org|虚拟机|N/A|192.168.2.22|N/A||
    |node03.ceph.freedom.org|虚拟机|N/A|192.168.2.23|N/A||


## DNS解析清单
- 内部环境，只使用一台主机搭建DNS服务器。

    |域名|A记录|CNAME记录|是否配置反向解析|
    |:------|:------|:------|:------|
    |ns01.freedom.org|192.168.2.1|N/A|否|
    |foreman.freedom.org|192.168.2.1|N/A|是|
    |ansible.freedom.org|N/A|foreman.freedom.org|N/A|
    |nfs.freedom.org|N/A|foreman.freedom.org|N/A|
    |jenkins.freedom.org|N/A|foreman.freedom.org|N/A|
    |yum.freedom.org|N/A|foreman.freedom.org|N/A|
    |files.freedom.org|N/A|foreman.freedom.org|N/A|
    |zabbix.freedom.org|N/A|foreman.freedom.org|N/A|
    |katello.freedom.org|N/A|foreman.freedom.org|N/A|
    |es.freedom.org|N/A|foreman.freedom.org|N/A|
    |elastic.freedom.org|N/A|foreman.freedom.org|N/A|
    |elasticsearch.freedom.org|N/A|foreman.freedom.org|N/A|
    |kibana.freedom.org|N/A|foreman.freedom.org|N/A|
    |haproxy.freedom.org|192.168.2.2|N/A|否|
    |ns02.freedom.org|192.168.2.2|N/A|否|
    |harbor.freedom.org|N/A|192.168.2.3|N/A|
    |docker.freedom.org|N/A|harbor.freedom.org|N/A|
    |master01.freedom.org|192.168.2.11|N/A|否|
    |master02.freedom.org|192.168.2.12|N/A|否|
    |master03.freedom.org|192.168.2.13|N/A|否|
    |worker01.freedom.org|192.168.2.14|N/A|否|
    |worker02.freedom.org|192.168.2.15|N/A|否|
    |worker03.freedom.org|192.168.2.16|N/A|否|
    |node01.ceph.freedom.org|192.168.2.21|N/A|否|
    |node02.ceph.freedom.org|192.168.2.22|N/A|否|
    |node03.ceph.freedom.org|192.168.2.23|N/A|否|
    |windows.freedom.org|192.168.2.253|N/A|否|
    |vcenter.freedom.org|192.168.2.252|N/A|否|
    

