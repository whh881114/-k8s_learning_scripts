# 核心服务器：foreman.freedom.org

## 更新日志
- 2024/05/18更新日志
  - 私有云环境下，foreman服务器核心功能是提供yum源仓库，像ansible/discovery插件就不安装了，功能单一化处理，核心点在于
    discovery安装部署过于复杂，时间成本过高，另外，ansible自动化处理则使用静态方式处理即可。
  - CentOS 7 将于2024/06/30走向生命周期，私有云操作系统将使用RockyLinux，官方地址：https://rockylinux.org。
  - 此次使用`Rocky-9.4-x86_64`部署系统，foreman使用3.10版本，katello使用4.12版本。

## 配置foreman服务器核心过程
- 官方文档：
  - https://theforeman.org/manuals/3.10/quickstart_guide.html
  - https://docs.theforeman.org/3.9/Installing_Server/index-katello.html（3.10版本过新，文档还没有更新，参考3.9版本。）

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
    [root@foreman ~]# foreman-installer --scenario katello
    2024-05-19 08:12:10 [NOTICE] [root] Loading installer configuration. This will take some time.
    2024-05-19 08:12:15 [NOTICE] [root] Running installer with log based terminal output at level NOTICE.
    2024-05-19 08:12:15 [NOTICE] [root] Use -l to set the terminal output log level to ERROR, WARN, NOTICE, INFO, or DEBUG. See --full-help for definitions.
    2024-05-19 08:12:22 [NOTICE] [configure] Starting system configuration.
    2024-05-19 08:12:33 [NOTICE] [configure] 250 configuration steps out of 1414 steps complete.
    2024-05-19 08:12:39 [NOTICE] [configure] 500 configuration steps out of 1416 steps complete.
    2024-05-19 08:27:48 [NOTICE] [configure] 750 configuration steps out of 1420 steps complete.
    2024-05-19 08:27:48 [NOTICE] [configure] 1000 configuration steps out of 1425 steps complete.
    2024-05-19 08:30:59 [NOTICE] [configure] 1250 configuration steps out of 1425 steps complete.
    2024-05-19 08:35:01 [NOTICE] [configure] System configuration has finished.
    Executing: foreman-rake upgrade:run
    =============================================
    Upgrade Step 1/11: katello:correct_repositories. This may take a long while.
    =============================================
    Upgrade Step 2/11: katello:clean_backend_objects. This may take a long while.
    0 orphaned consumer id(s) found in candlepin.
    Candlepin orphaned consumers: []
    =============================================
    Upgrade Step 3/11: katello:upgrades:4.0:remove_ostree_puppet_content. =============================================
    Upgrade Step 4/11: katello:upgrades:4.1:sync_noarch_content. =============================================
    Upgrade Step 5/11: katello:upgrades:4.1:fix_invalid_pools. I, [2024-05-19T08:35:20.695986 #23936]  INFO -- : Corrected 0 invalid pools
    I, [2024-05-19T08:35:20.696107 #23936]  INFO -- : Removed 0 orphaned pools
    =============================================
    Upgrade Step 6/11: katello:upgrades:4.1:reupdate_content_import_export_perms. =============================================
    Upgrade Step 7/11: katello:upgrades:4.2:remove_checksum_values. =============================================
    Upgrade Step 8/11: katello:upgrades:4.4:publish_import_cvvs. =============================================
    Upgrade Step 9/11: katello:upgrades:4.8:fix_incorrect_providers. Fixing incorrect providers
    Fixed 0 incorrect providers
    Cleaning Candlepin orphaned custom products for organization Default Organization
    Deleted 0 Candlepin orphaned custom products for organization Default Organization
    =============================================
    Upgrade Step 10/11: katello:upgrades:4.8:regenerate_imported_repository_metadata. No repositories found for regeneration.
    =============================================
    Upgrade Step 11/11: katello:upgrades:4.12:update_content_access_modes. Checking Candlepin status
    Setting content access modes
    ----------------------------------------
    Set content access mode for 0 organizations
    ----------------------------------------
      Success!
      * Foreman is running at https://foreman.freedom.org
          Initial credentials are admin / xQrZiCFGyrbmobE2
        * To install an additional Foreman proxy on separate machine continue by running:
    
            foreman-proxy-certs-generate --foreman-proxy-fqdn "$FOREMAN_PROXY" --certs-tar "/root/$FOREMAN_PROXY-certs.tar.gz"
        * Foreman Proxy is running at https://foreman.freedom.org:9090
    
    The full log is at /var/log/foreman-installer/katello.log
    [root@foreman ~]#
    ```

## katello配置
- 文档地址：https://docs.theforeman.org/nightly/Content_Management_Guide/index-foreman-el.html
- 将katello存放rpm包目录移至大容量目录下。
  ```shell
  mv /var/lib/pulp /data
  ln -s /data/pulp /var/lib/
  ```

## RockyLinux9源列表
- appstream，https://mirrors.aliyun.com/rockylinux/9/AppStream/x86_64/os
- baseos，https://mirrors.aliyun.com/rockylinux/9/BaseOS/x86_64/os
- extras，https://mirrors.aliyun.com/rockylinux/9/extras/x86_64/os
- crb，https://mirrors.aliyun.com/rockylinux/9/CRB/x86_64/os
- epel，https://mirrors.aliyun.com/epel/9/Everything/x86_64
- zabbix，https://mirrors.aliyun.com/zabbix/zabbix/6.0/rhel/9/x86_64

## 订阅RockyLinux9本地源
3.10版本和之前安装的3.3版本有差异，使用以下命令订阅并注册主机，其中token无过期时间。
```shell
set -o pipefail && curl -sS --insecure 'https://foreman.freedom.org/register?activation_keys=Rocky-Linux-9-x86_64&force=true&location_id=2&organization_id=1&update_packages=false' -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0LCJpYXQiOjE3MTYwODMzMTcsImp0aSI6ImU4MTBjMTE2ZmJiNGRjYWI5Yzc0MjU3MDU3MWFhMGQ0YTZlOTZhY2U0MWM2YzU1ZjZkNjk5MTU5NzJiZGMwYjIiLCJzY29wZSI6InJlZ2lzdHJhdGlvbiNnbG9iYWwgcmVnaXN0cmF0aW9uI2hvc3QifQ.8hXP9U67TjQeduIvRFaZ5PReKZHezDQguF5EcHuR7Zs' | bash
```