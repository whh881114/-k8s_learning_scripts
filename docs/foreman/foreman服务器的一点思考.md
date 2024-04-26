# foreman服务器的一点思考

## 思考点一：foreman是否需要部署自动化安装操作系统？
解答：**先说观点，在vmware虚拟化平台下，不需要部署自动化安装操作系统。**   
有以下几论点支撑观点：
- 安装复杂，如果安装过程中出错，排查起来也复杂。常规安装步骤如下：
  - https://www.theforeman.org/manuals/3.10/quickstart_guide.html
  - https://theforeman.org/plugins/foreman_discovery/18.0/index.html
  - 就以上这两个步骤，就需要时间研究，除去上面的，还需要额外配置dhcp和tftp，此外，还需要先在虚拟环境下配置dns服务器，并且还要用以下命令来安装相对应的插件。
    ```shell
    foreman-installer --scenario katello \
    --enable-foreman-plugin-discovery \
    --enable-foreman-plugin-ansible \
    --enable-foreman-proxy-plugin-ansible \
    --enable-foreman-plugin-remote-execution \
    --foreman-proxy-dhcp true \
    --foreman-proxy-dhcp-managed true \
    --foreman-proxy-dhcp-interface ens192 \
    --foreman-proxy-dhcp-range "192.168.2.100 192.168.2.200" \
    --foreman-proxy-dhcp-gateway 10.255.2.254 \
    --foreman-proxy-dhcp-nameservers 192.168.2.250,192.168.2.251 \
    --foreman-proxy-tftp true \
    --foreman-proxy-tftp-managed true \
    --foreman-proxy-http true
    ```
    
- 部署一个可用于自动化安装操作系统的步骤也复杂，需要配置安装介质，子网，域，主机组，分区表，PXE模板，置备表等等，这过于繁琐，此外，为了使用主机在部署过程中指定网卡地址，还要了解ERB语法，然后做各种尝试，以下的配置网卡为命令，我已记不清是从哪里copy的，最有力的线索是官方的模板内容，从中学习理解。这无疑对初学者来说，难度不小。
    ```shell
    <% subnet = @host.subnet -%>
    <% dhcp = @static -%>
    network --bootproto <%= dhcp ? 'dhcp' : "static --ip=#{@host.ip} --netmask=#{subnet.mask} --gateway=#{subnet.gateway} --nameserver=#{[subnet.dns_primary, subnet.dns_secondary].select{ |item| item.present? }.join(',')}" %> --hostname <%= @host %>
    ```
  
- 安装操作系统太慢了，相比直接使用镜像部署来说。翻过了以上的两座大山，结果发现效率也没有那么高，这个才是最大的决定因素。

- 综上所述，为了实现一个"干净的"操作系统所要的时间成本过多，最多也就是实现了配置静态ip地址而已，此外，foreman的主机管理页面功能太弱了，ip地址都不能显示出来，虽然有对应的插件，但是目前此插件已EOL（End of Life）。

- 【待验证】虚拟机不再使用自动发现安装操作系统，转用模板部署，虚拟机订阅yum源后，实现了主机注册，之后要验证一点就是，客户端不管是ansible还是puppet的facts信息要实时同步，如ip地址修改后，需要同步到foreman的管理界面。
  - 【ansible已验证】主机修改了ip地址后，管理员需要在foreman管理端去修改主机的ip地址，然后再执行一次ansible任务，这样就能更新页面上显示的ip地址了。