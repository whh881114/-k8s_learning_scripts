# 部署sftp服务

## 参考资料
- https://www.kancloud.cn/noahs/linux/1629269
- https://blog.csdn.net/qq_35623011/article/details/85003109


## 连接报错日志
```shell
client_loop: send disconnect: Broken pipe
Connection closed.  
Connection closed
```


## 解决方法
- 网上查询，故障原因是指向sftp目录权限不对。但是自己不知道到底是哪个目录不对，所以需要开启日志进行排错，直到修改好目录权限为至。


## 部署过程
- 编辑配置文件`/etc/ssh/sshd_config`，注释`Subsystem sftp /usr/libexec/openssh/sftp-server`，然后添加以下内容。
  开启日志，sftp登录指定的用户组为sftp，同时，**开启chroot功能，将登录用户限定在某一目录中**，%u表示用户名。
```shell
Subsystem sftp  internal-sftp -I INFO -f local5
LogLevel INFO
Match Group sftp
ChrootDirectory /data/sftp_chroot/%u
ForceCommand internal-sftp
AllowTcpForwarding no
X11Forwarding no
```


- 配置日志。
```shell
# cat /etc/rsyslog.d/sftp.conf 
auth,authpriv.*,local5.* /var/log/sftp.log
# systemctl restart rsyslog
```

- 创建组，用户并设置密码，其中，**权限设置很重要**，要不然就会出sftp连接失败的情况。
  建议sftp_chroot目录放在根目录下。
  权限说明：sftp_demo的家目录为`/data/sftp_chroot/sftp_demo`，那么这三个目录的属主必须是root，那么组就设置成sftp，所以sftp_demo
  用户登录后，所在的根目录无写入权限，那么就创建一个upload目录仅用户读写。
```shell
# groupadd sftp
# useradd -d /data/sftp_chroot/sftp_demo -G sftp -s /bin/false -c "sftp测试用户" sftp_demo
# mkdir /data/sftp_chroot/sftp_demo/upload
# chown root:sftp /data /data/sftp_chroot /data/sftp_chroot/sftp_demo
# chown sftp_demo:sftp /data/sftp_chroot/sftp_demo/upload
# passwd sftp_demo
```

- 错误日志记录：**fatal: bad ownership or modes for chroot directory component "/data/" [postauth]**
```shell
Jul 22 11:48:38 sftp-server-001 sshd[1082091]: Accepted password for sftp_demo from xxx.xxx.xxx.xxx port 35862 ssh2
Jul 22 11:48:38 sftp-server-001 systemd-logind[642]: New session 22752 of user sftp_demo.
Jul 22 11:48:38 sftp-server-001 systemd[1082095]: pam_unix(systemd-user:session): session opened for user sftp_demo(uid=1003) by (uid=0)
Jul 22 11:48:39 sftp-server-001 sshd[1082091]: pam_unix(sshd:session): session opened for user sftp_demo(uid=1003) by (uid=0)
Jul 22 11:48:39 sftp-server-001 sshd[1082091]: fatal: bad ownership or modes for chroot directory component "/data/" [postauth]
Jul 22 11:48:39 sftp-server-001 sshd[1082091]: pam_unix(sshd:session): session closed for user sftp_demo
Jul 22 11:48:39 sftp-server-001 systemd-logind[642]: Session 22752 logged out. Waiting for processes to exit.
Jul 22 11:48:39 sftp-server-001 systemd-logind[642]: Removed session 22752.
```
