# virtualenv部署不同python开发环境

## 部署步骤
- 先要有对应的`python`版本，自行安装，此处我选`python3.8`，安装命令为`yum install rh-python38-*`。
- 将`python3.8`加入环境变量，命令为`source /opt/rh/rh-python38/enable`。
- 安装`virtualenv`，命令为`pip3 install virtualenv`。
- 创建虚拟环境，环境为`tencent`，命令为`virtualenv tencent`。
- 激活环境，命令为`source tencent/bin/activate`。
- 退出环境，命令为`deactivate`。

## 结果
```shell
[root@wang-hao-hao-01.indv.freedom.org ~ 15:26]# 1> source tencent/bin/activate
(tencent) [root@wang-hao-hao-01.indv.freedom.org ~ 15:26]# 2> deactivate 
[root@wang-hao-hao-01.indv.freedom.org ~ 15:26]# 3> 
```


