# 核心服务器：foreman.freedom.org

## 更新日志
- 2024/05/18更新日志
  - 私有云环境下，foreman服务器核心功能是提供yum源仓库，像ansible/discovery插件就不安装了，功能单一化处理，核心点在于
    discovery安装部署过于复杂，时间成本过高，另外，ansible自动化处理则使用静态方式处理即可。
  - CentOS 7 将于2024/06/30走向生命周期，私有云操作系统将使用RockyLinux，官方地址：https://rockylinux.org。
  - 此次使用`Rocky-9.4-x86_64`部署系统，foreman使用3.10版本，katello使用4.12版本。

## 配置foreman服务器核心过程
- 官方文档：https://theforeman.org/manuals/3.10/quickstart_guide.html。

- 前提条件：主机名设置成fqdn格式（foreman.freedom.org），并且需要有此fqdn的正反解析，否则会有如下报错信息。
  ```shell
  2024-05-18 23:07:35 [NOTICE] [root] Loading installer configuration. This will take some time.
  2024-05-18 23:07:41 [NOTICE] [root] Running installer with log based terminal output at level NOTICE.
  2024-05-18 23:07:41 [NOTICE] [root] Use -l to set the terminal output log level to ERROR, WARN, NOTICE, INFO, or DEBUG. See --full-help for definitions.
  Unable to resolve forward DNS for foreman.freedom.org
  ```

- 命令简化如下：
    ```shell
    dnf clean all
    dnf install https://yum.theforeman.org/releases/3.10/el9/x86_64/foreman-release.rpm
    dnf install https://yum.theforeman.org/katello/4.12/katello/el9/x86_64/katello-repos-4.12.0-1.el9.noarch.rpm
    dnf install https://yum.puppet.com/puppet7-release-el-9.noarch.rpm

    dnf install foreman-installer-katello

    foreman-installer --scenario katello
    ```

- 安装过程日志：
    ```
    [root@foreman.freedom.org ~ 11:23]# 9> foreman-installer --scenario katello
    2022-07-03 11:23:49 [NOTICE] [root] Loading installer configuration. This will take some time.
    2022-07-03 11:23:55 [NOTICE] [root] Running installer with log based terminal output at level NOTICE.
    2022-07-03 11:23:55 [NOTICE] [root] Use -l to set the terminal output log level to ERROR, WARN, NOTICE, INFO, or DEBUG. See --full-help for definitions.
    2022-07-03 11:24:05 [NOTICE] [configure] Starting system configuration.
    2022-07-03 11:24:39 [NOTICE] [configure] 250 configuration steps out of 1353 steps complete.
    2022-07-03 11:32:59 [NOTICE] [configure] 500 configuration steps out of 1355 steps complete.
    2022-07-03 11:37:05 [NOTICE] [configure] 750 configuration steps out of 1361 steps complete.
    2022-07-03 11:37:08 [NOTICE] [configure] 1000 configuration steps out of 1381 steps complete.
    2022-07-03 11:43:34 [NOTICE] [configure] 1250 configuration steps out of 1381 steps complete.
    2022-07-03 11:47:54 [NOTICE] [configure] System configuration has finished.
    Executing: foreman-rake upgrade:run
    =============================================
    Upgrade Step 1/8: katello:correct_repositories. This may take a long while.
    =============================================
    Upgrade Step 2/8: katello:clean_backend_objects. This may take a long while.
    0 orphaned consumer id(s) found in candlepin.
    Candlepin orphaned consumers: []
    =============================================
    Upgrade Step 3/8: katello:upgrades:4.0:remove_ostree_puppet_content. =============================================
    Upgrade Step 4/8: katello:upgrades:4.1:sync_noarch_content. =============================================
    Upgrade Step 5/8: katello:upgrades:4.1:fix_invalid_pools. I, [2022-07-03T11:48:13.956548 #54399]  INFO -- : Corrected 0 invalid pools
    I, [2022-07-03T11:48:13.956586 #54399]  INFO -- : Removed 0 orphaned pools
    =============================================
    Upgrade Step 6/8: katello:upgrades:4.1:reupdate_content_import_export_perms. =============================================
    Upgrade Step 7/8: katello:upgrades:4.2:remove_checksum_values. =============================================
    Upgrade Step 8/8: katello:upgrades:4.4:publish_import_cvvs.   Success!
      * Foreman is running at https://foreman.freedom.org
          Initial credentials are admin / qrWp4LmGHeV9dwxu
      * To install an additional Foreman proxy on separate machine continue by running:
        
          foreman-proxy-certs-generate --foreman-proxy-fqdn "$FOREMAN_PROXY" --certs-tar "/root/$FOREMAN_PROXY-certs.tar"
      * Foreman Proxy is running at https://foreman.freedom.org:9090
        
      The full log is at /var/log/foreman-installer/katello.log
    You have new mail in /var/spool/mail/root
    [root@foreman.freedom.org ~ 11:48]# 10> 
    ```


## 安装foreman服务器插件
- 常用插件：ansible/discovery/tftp，其中tftp插件必须要安装，否则后续在build默认pxe模板时就会报错，从而导致无法启动自动安装。
- 官方地址：
    - https://theforeman.org/plugins/foreman_ansible/3.x/index.html
    - https://theforeman.org/plugins/foreman_discovery/15.0/index.html
- 安装命令：
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
- 安装过程中报错了，在管理界面中看到`smart proxies`中的ERROR，手动处理下即可，其命令为：`ssh-keygen -t rsa -b 4096 -f /usr/share/foreman-proxy/.ssh/id_rsa_foreman_proxy`。

## 配置foremna服务器插件--foreman_column_view
- 安装：`yum -y install tfm-rubygem-foreman_column_view tfm-rubygem-foreman_column_view-doc`

- 配置文件`/etc/foreman/plugins/foreman_column_view.yaml`内容如下：
    ```
    :column_view:
      :ipaddress:
        :title: IP
        :after: name
        :content: facts_hash['ipaddress']
      :processorcount:
        :title: CPU
        :after: ipaddress
        :content: facts_hash["processorcount"]
      :memorysize:
        :title: MEM
        :after: ipaddress
        :content: facts_hash["memorysize"]
      :sdasize:
        :title: SDA-SIZE
        :after: memorysize
        :content: facts_hash['disks::sda::size']
      :sdbsize:
        :title: SDB-SIZE
        :after: sdasize
        :content: facts_hash['disks::sdb::size']
      :uptime:
        :title: UPTIME
        :after: sdbsize
        :content: facts_hash['uptime']
    ```
- 重启服务`service foreman restart`。


## 配置foremna服务器插件--discovery
- 手动下载镜像，为的是解决下载慢的问题。版本使用旧点的，最新版本3.8.0有问题，其终端看不到ip信息，其命令为：
    ```
    cd /var/lib/tftpboot/boot
    wget https://downloads.theforeman.org/discovery/releases/3.5/fdi-image-3.5.7.tar -O fdi-image-3.5.7.tar
    tar xf fdi-image-3.5.7.tar
    chown -R foreman-proxy:root fdi-image
    ```
- 后续的pxe配置，文档地址：https://theforeman.org/plugins/foreman_discovery/15.0/index.html#3.Configuration。


## 自动安装操作系统后续配置
- 配置安装介质，分区表，置备模板，子网，域名和主机组。太杂了，也不是很复杂，但是写不过来。
- 参考资料地址：
    - https://docs.theforeman.org/nightly/Provisioning_Guide/index-foreman-el.html
    - https://docs.theforeman.org/nightly/Managing_Hosts/index-foreman-el.html

## katello配置
- 文档地址：https://docs.theforeman.org/nightly/Content_Management_Guide/index-foreman-el.html

## yum源列表
    - base, https://mirrors.tuna.tsinghua.edu.cn/centos/7/os/x86_64/
    - extras, https://mirrors.tuna.tsinghua.edu.cn/centos/7/extras/x86_64/
    - updates, https://mirrors.tuna.tsinghua.edu.cn/centos/7/updates/x86_64/
    - puppet7, https://yum.puppetlabs.com/puppet7/el/7/x86_64/
    - epel, https://mirrors.tuna.tsinghua.edu.cn/epel/7/x86_64/
    - docker-ce-stable, https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/x86_64/stable/
    - kubernetes, https://mirrors.tuna.tsinghua.edu.cn/kubernetes/yum/repos/kubernetes-el7-x86_64/