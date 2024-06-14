# vsftpd日志

## 参考资料
- https://cloud.tencent.com/developer/article/2009915

## 配置日志选项
```shell
dual_log_enable=YES
vsftpd_log_file=/var/log/vsftpd.log  

xferlog_enable=YES
xferlog_file=/var/log/xferlog
xferlog_std_format=YES
```

```shell
dual_log_enable，如果启用该选项，将生成两个相似的日志文件，默认在 /var/log/xferlog 和 /var/log/vsftpd.log 目录下。前者是 wu-ftpd 类型的传输日志，可以利用标准日志工具对其进行分析；后者是Vsftpd类型的日志。
```

```shell
xferlog_enable，xferlog_file，xferlog_std_format，三个选项用于配置上传和下载情况的日志文件。
```

```shell
/var/log/xferlog日志格式说明

Sun Feb 23 22:08:26 2014 6 212.73.193.130 1023575 /Lille_IconSP/win_230214_52_11.jpg b _ i r sipafranch ftp 0 * c

- Sun Feb 23 22:08:26 2014，传输时间。
- 6，传输文件所用时间，单位/秒。
- 212.73.193.130，ftp客户端名称/IP。
- 1023575，传输文件大小，单位/Byte。
- /Lille_IconSP/win_230214_52_11.jpg，传输文件名，包含路径。
- b，传输方式。a以ASCII方式传输，b以二进制(binary)方式传输。
- _，特殊处理标志位。"_"不做任何处理；"C"文件是压缩格式；"U"文件非压缩格式；"T"文件是tar格式。
- i，传输方向。"i"表示上传；"o"表示下载。
- r，用户访问模式。"a"匿名用户；"g"访客模式；"r"系统中用户。
- sipafranch，登录用户名。
- ftp，服务名称。一般都是ftp。
- 0，认证方式。"0"表示无认证；"1"表示RFC931认证；
- *，认证用户id。"*"表示无法获取id。
- c，完成状态。"i"表示传输未完成；"c"表示传输已完成；
```
