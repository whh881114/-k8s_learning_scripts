# 核心服务器：foreman.freedom.org

## 安装epel源
- 使用清华镜像源，地址：https://mirrors.tuna.tsinghua.edu.cn/help/epel/

## 安装配置ansible
- 配置ssh key，命令为：`ssh-keygen`。
- 安装ansible，命令为：`yum -y install ansible`。
- 编辑ansible配置文件/etc/ansible/ansible.cfg，修改内容如下：
    ```
    roles_path = /etc/ansible/roles:/opt/ansible_playbooks/roles
    host_key_checking = False
    module_name = shell
    ```

## 配置foreman服务器
- 初始化主机。使用ansible部署，命令为：`cd /opt/ansible_playbooks && ansible-playbook deploy-foreman.yml -t common`。
- 安装foreman和katello。按官方文档操作即可，本次使用2.5版本，katello配套版本为4.1。
    - katello可以管理yum源仓库，这个比写脚本高级些，所以安装了这个插件。
    - 文档地址：
        - https://theforeman.org/manuals/2.5/quickstart_guide.html
        - https://docs.theforeman.org/2.5/Installing_Server_on_Red_Hat/index-katello.htm
    - 命令简化如下：
        ```shell
        yum -y install https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
        yum -y install centos-release-scl-rh
        yum -y install https://yum.theforeman.org/releases/2.5/el7/x86_64/foreman-release.rpm
        yum -y install https://yum.theforeman.org/katello/4.1/katello/el7/x86_64/katello-repos-latest.rpm
        yum -y install foreman-installer foreman-installer-katello
        
        foreman-installer --list-scenarios
        foreman-installer --scenario katello
        ```
    - 安装过程日志：
        ```
        [root@foreman.freedom.org ~ 22:13]# 6> foreman-installer --scenario katello
        2021-08-30 22:15:20 [NOTICE] [root] Loading installer configuration. This will take some time.
        2021-08-30 22:15:25 [NOTICE] [root] Running installer with log based terminal output at level NOTICE.
        2021-08-30 22:15:25 [NOTICE] [root] Use -l to set the terminal output log level to ERROR, WARN, NOTICE, INFO, or DEBUG. See --full-help for definitions.
        2021-08-30 22:15:32 [NOTICE] [configure] Starting system configuration.
        2021-08-30 22:15:51 [NOTICE] [configure] 250 configuration steps out of 1878 steps complete.
        2021-08-30 22:16:25 [NOTICE] [configure] 500 configuration steps out of 1880 steps complete.
        2021-08-30 22:16:29 [NOTICE] [configure] 750 configuration steps out of 1882 steps complete.
        2021-08-30 22:16:43 [NOTICE] [configure] 1000 configuration steps out of 1888 steps complete.
        2021-08-30 22:16:44 [NOTICE] [configure] 1250 configuration steps out of 1890 steps complete.
        2021-08-30 22:25:35 [NOTICE] [configure] 1500 configuration steps out of 1890 steps complete.
        2021-08-30 22:27:44 [NOTICE] [configure] 1750 configuration steps out of 1890 steps complete.
        2021-08-30 22:28:40 [NOTICE] [configure] System configuration has finished.
        Executing: foreman-rake upgrade:run
        `/usr/share/foreman` is not writable.
        Bundler will use `/tmp/bundler20210830-11070-5fwwle11070' as your home directory temporarily.
        =============================================
        Upgrade Step 1/5: katello:correct_repositories. This may take a long while.
        =============================================
        Upgrade Step 2/5: katello:clean_backend_objects. This may take a long while.
        0 orphaned consumer id(s) found in candlepin.
        Candlepin orphaned consumers: []
        =============================================
        Upgrade Step 3/5: katello:upgrades:4.0:remove_ostree_puppet_content. =============================================
        Upgrade Step 4/5: katello:upgrades:4.1:sync_noarch_content. =============================================
        Upgrade Step 5/5: katello:upgrades:4.1:fix_invalid_pools. I, [2021-08-30T22:29:03.781599 #11070]  INFO -- : Corrected 0 invalid pools
        I, [2021-08-30T22:29:03.781705 #11070]  INFO -- : Removed 0 orphaned pools
          Success!
          * Foreman is running at https://foreman.freedom.org
              Initial credentials are admin / U99mwoa6KbCS2zBF
          * To install an additional Foreman proxy on separate machine continue by running:
        
              foreman-proxy-certs-generate --foreman-proxy-fqdn "$FOREMAN_PROXY" --certs-tar "/root/$FOREMAN_PROXY-certs.tar"
          * Foreman Proxy is running at https://foreman.freedom.org:9090
        
          The full log is at /var/log/foreman-installer/katello.log
        [root@foreman.freedom.org ~ 22:29]# 7> 
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
    --enable-foreman-plugin-puppetdb \
    --enable-foreman-plugin-remote-execution \
    --enable-foreman-proxy-plugin-remote-execution-ssh \
    --foreman-proxy-dhcp true \
    --foreman-proxy-dhcp-managed true \
    --foreman-proxy-dhcp-interface ens192 \
    --foreman-proxy-dhcp-range "10.255.0.200 10.255.3.250" \
    --foreman-proxy-dhcp-gateway 10.255.3.254 \
    --foreman-proxy-dhcp-nameservers 10.255.0.121,10.255.0.122 \
    --foreman-proxy-tftp true \
    --foreman-proxy-tftp-managed true 
    ```

## 配置foremna服务器插件--foreman_column_view
- rpm包地址：
    - https://yum.theforeman.org/plugins/2.5/el7/x86_64/tfm-rubygem-foreman_column_view-0.4.0-5.fm2_5.el7.noarch.rpm
    - https://yum.theforeman.org/plugins/2.5/el7/x86_64/tfm-rubygem-foreman_column_view-doc-0.4.0-5.fm2_5.el7.noarch.rpm
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
    cd mkdir -p /var/lib/tftpboot/boot
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
    - docker-ce-stable, https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/x86_64/stable/
    - epel, https://mirrors.tuna.tsinghua.edu.cn/epel/7/x86_64/
    - extras, https://mirrors.tuna.tsinghua.edu.cn/centos/7/extras/x86_64/
    - kubernetes, https://mirrors.tuna.tsinghua.edu.cn/kubernetes/yum/repos/kubernetes-el7-x86_64/
    - mysql-5.7-community, https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-5.7-community-el7-x86_64/
    - mysql-8.0-community, https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-8.0-community-el7-x86_64/
    - mysql-connectors-community, https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-connectors-community-el7-x86_64/
    - mysql-tools-community, https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-tools-community-el7-x86_64/
    - puppet6, http://yum.puppetlabs.com/puppet6/el/7/x86_64/
    - updates, https://mirrors.tuna.tsinghua.edu.cn/centos/7/updates/x86_64/
    - zabbix-5.0-lts, https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/5.0/rhel/7/x86_64/
    - zabbix-frontend-5.0-lts, https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/5.0/rhel/7/x86_64/frontend/
    - zabbix-non-supported, https://mirrors.tuna.tsinghua.edu.cn/zabbix/non-supported/rhel/7/x86_64/
    - centos-sclo-rh, http://mirror.centos.org/centos/7/sclo/x86_64/rh/
    - centos-sclo-sclo, http://mirror.centos.org/centos/7/sclo/x86_64/sclo/
    
## 安装puppetdb
- 安装包：yum -y install puppetdb
- 配置数据库：https://puppet.com/docs/puppetdb/6/configure_postgres.html
- 配置foreman-puppetdb-plugin：https://github.com/theforeman/puppetdb_foreman
- 特别说明，默认puppetdb里使用的jetty的http端口为8080，可以自行修改，另外，配置foreman-puppetdb-plugin时，可以不配置https，
如果要配置ssl时，可以使用参考以下信息。另外，发现配置DB后，两边的信息没有同步，不过这个无伤大雅，其实本来也没啥用，我的强迫症犯了。
    ```shell
    puppetdb_address                https://foreman.freedom.org:8081/pdb/cmd/v1
    puppetdb_ssl_ca_file            /etc/puppetlabs/puppet/ssl/certs/ca.pem
    puppetdb_ssl_certificate        /etc/puppetlabs/puppet/ssl/certs/foreman.freedom.org.pem
    puppetdb_ssl_private_key        /etc/puppetlabs/puppet/ssl/private_keys/foreman.freedom.org.pem
    ```