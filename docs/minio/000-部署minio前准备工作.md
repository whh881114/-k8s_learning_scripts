# 部署minio前准备工作

## 准备工作
- minio打算使用"Multi-Node Multi-Drive (MNMD)"模式部署，在部署开始之前，需要部署一个反向代理。
- 反向代理使用nginx，同时考虑到反向代理高可用性，那就使用keepalived实现。
- keepalived参考资料。
  - https://www.keepalived.org/
  - https://cloud.tencent.com/developer/article/1416596


## keeplived.conf文件重点
- keepalived介绍。
```shell
Keepalived is a routing software written in C. The main goal of this project is to provide simple and robust facilities 
for loadbalancing and high-availability to Linux system and Linux based infrastructures. Loadbalancing framework relies 
on well-known and widely used Linux Virtual Server (IPVS) kernel module providing Layer4 loadbalancing. 
Keepalived implements a set of checkers to dynamically and adaptively maintain and manage loadbalanced server pool according their health. 
On the other hand high-availability is achieved by VRRP protocol. VRRP is a fundamental brick for router failover. 
In addition, Keepalived implements a set of hooks to the VRRP finite state machine providing low-level and high-speed protocol interactions. 
In order to offer fastest network failure detection, Keepalived implements BFD protocol. 
VRRP state transition can take into account BFD hint to drive fast state transition. 
Keepalived frameworks can be used independently or all together to provide resilient infrastructures.
```


## 部署细节
- 两台主机名：ha-nginx-01.freedom.org和ha-nginx-02.freedom.org。
- 两台主机均安装nginx和keepalived软件。
- ha-nginx-01.freedom.org主机keepalived.conf配置文件。
```shell
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id ha-nginx-01.freedom.org
   vrrp_skip_check_adv_addr
   vrrp_garp_interval 0
   vrrp_gna_interval 0
   # 禁用vrrp_strict，允许vip可以被ping通。
   # vrrp_strict
}

vrrp_script check_nginx_pid {
  script "/usr/sbin/pidof nginx"
  interval 3
  weight -10
  fall 3
  rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface ens192
    virtual_router_id 51   # 这个值在Master和Backup服务器上必须相同，以确保它们属于同一个VRRP实例。
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.255.1.111/22
    }
}

vrrp_instance VI_2 {
    state BACKUP
    interface ens192
    virtual_router_id 52
    priority 80
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.255.1.222/22
    }
}
```
- ha-nginx-02.freedom.org主机keepalived.conf配置文件。
```shell
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id ha-nginx-02.freedom.org
   vrrp_skip_check_adv_addr
   vrrp_garp_interval 0
   vrrp_gna_interval 0
   # 禁用vrrp_strict，允许vip可以被ping通。
   # vrrp_strict
}

vrrp_script check_nginx_pid {
  script "/usr/sbin/pidof nginx"
  interval 3
  weight -10
  fall 3
  rise 2
}

vrrp_instance VI_1 {
    state BACKUP
    interface ens192
    virtual_router_id 51   # 这个值在Master和Backup服务器上必须相同，以确保它们属于同一个VRRP实例。
    priority 80
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.255.1.111/22
    }
}

vrrp_instance VI_2 {
    state MASTER
    interface ens192
    virtual_router_id 52
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.255.1.222/22
    }
}
```