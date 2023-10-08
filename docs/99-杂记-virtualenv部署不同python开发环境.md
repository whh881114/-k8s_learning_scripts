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

## 安装bpython失败解决方法
- 安装成功，运行失败。
```shell
(tencent) [root@wang-hao-hao-01.indv.freedom.org ~/tencent/scripts 15:31]# 19> pip3 install bpython
Collecting bpython
  Using cached bpython-0.24-py3-none-any.whl (194 kB)
Collecting curtsies>=0.4.0 (from bpython)
  Obtaining dependency information for curtsies>=0.4.0 from https://files.pythonhosted.org/packages/5e/ab/c4ae7ff01c75001829dfa54da9b25632a8206fa5c9036ea0292096b402d0/curtsies-0.4.2-py3-none-any.whl.metadata
  Downloading curtsies-0.4.2-py3-none-any.whl.metadata (4.3 kB)
Collecting cwcwidth (from bpython)
  Using cached cwcwidth-0.1.8-cp38-cp38-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl (54 kB)
Collecting greenlet (from bpython)
  Obtaining dependency information for greenlet from https://files.pythonhosted.org/packages/8e/0b/4351fe5357b7d8adf0e3fce495c4ba0e7f4a1aa1f446e95d5d0dc94f2229/greenlet-3.0.0-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata
  Downloading greenlet-3.0.0-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (3.8 kB)
Collecting pygments (from bpython)
  Obtaining dependency information for pygments from https://files.pythonhosted.org/packages/43/88/29adf0b44ba6ac85045e63734ae0997d3c58d8b1a91c914d240828d0d73d/Pygments-2.16.1-py3-none-any.whl.metadata
  Downloading Pygments-2.16.1-py3-none-any.whl.metadata (2.5 kB)
Collecting pyxdg (from bpython)
  Using cached pyxdg-0.28-py2.py3-none-any.whl (49 kB)
Requirement already satisfied: requests in /root/tencent/lib/python3.8/site-packages (from bpython) (2.31.0)
Collecting blessed>=1.5 (from curtsies>=0.4.0->bpython)
  Using cached blessed-1.20.0-py2.py3-none-any.whl (58 kB)
Requirement already satisfied: charset-normalizer<4,>=2 in /root/tencent/lib64/python3.8/site-packages (from requests->bpython) (3.3.0)
Requirement already satisfied: idna<4,>=2.5 in /root/tencent/lib/python3.8/site-packages (from requests->bpython) (3.4)
Requirement already satisfied: urllib3<3,>=1.21.1 in /root/tencent/lib/python3.8/site-packages (from requests->bpython) (2.0.6)
Requirement already satisfied: certifi>=2017.4.17 in /root/tencent/lib/python3.8/site-packages (from requests->bpython) (2023.7.22)
Collecting wcwidth>=0.1.4 (from blessed>=1.5->curtsies>=0.4.0->bpython)
  Obtaining dependency information for wcwidth>=0.1.4 from https://files.pythonhosted.org/packages/58/19/a9ce39f89cf58cf1e7ce01c8bb76ab7e2c7aadbc5a2136c3e192097344f5/wcwidth-0.2.8-py2.py3-none-any.whl.metadata
  Downloading wcwidth-0.2.8-py2.py3-none-any.whl.metadata (13 kB)
Collecting six>=1.9.0 (from blessed>=1.5->curtsies>=0.4.0->bpython)
  Downloading six-1.16.0-py2.py3-none-any.whl (11 kB)
Using cached curtsies-0.4.2-py3-none-any.whl (35 kB)
Using cached greenlet-3.0.0-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (662 kB)
Using cached Pygments-2.16.1-py3-none-any.whl (1.2 MB)
Using cached wcwidth-0.2.8-py2.py3-none-any.whl (31 kB)
Installing collected packages: wcwidth, pyxdg, six, pygments, greenlet, cwcwidth, blessed, curtsies, bpython
Successfully installed blessed-1.20.0 bpython-0.24 curtsies-0.4.2 cwcwidth-0.1.8 greenlet-3.0.0 pygments-2.16.1 pyxdg-0.28 six-1.16.0 wcwidth-0.2.8

(tencent) [root@wang-hao-hao-01.indv.freedom.org ~/tencent/scripts 15:32]# 20> bpython
Traceback (most recent call last):
  File "/root/tencent/bin/bpython", line 5, in <module>
    from bpython.curtsies import main
  File "/root/tencent/lib/python3.8/site-packages/bpython/curtsies.py", line 15, in <module>
    from . import args as bpargs, translations, inspection
  File "/root/tencent/lib/python3.8/site-packages/bpython/args.py", line 42, in <module>
    import requests
  File "/root/tencent/lib/python3.8/site-packages/requests/__init__.py", line 43, in <module>
    import urllib3
  File "/root/tencent/lib/python3.8/site-packages/urllib3/__init__.py", line 41, in <module>
    raise ImportError(
ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+, currently the 'ssl' module is compiled with 'OpenSSL 1.0.2k-fips  26 Jan 2017'. See: https://github.com/urllib3/urllib3/issues/2168
```

- 出错原因：`问题出现在urllib3库的版本与你的系统上的OpenSSL版本不兼容。urllib3版本2.0需要OpenSSL 1.1.1或更高版本，但你的系统上安装的是OpenSSL 1.0.2k-fips。`

- 解决方法：
```shell
(tencent) [root@wang-hao-hao-01.indv.freedom.org ~/tencent/scripts 15:32]# 21> pip3 install bpython urllib3==1.26.5
Requirement already satisfied: bpython in /root/tencent/lib/python3.8/site-packages (0.24)
Collecting urllib3==1.26.5
  Downloading urllib3-1.26.5-py2.py3-none-any.whl (138 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 138.1/138.1 kB 137.5 kB/s eta 0:00:00
Requirement already satisfied: curtsies>=0.4.0 in /root/tencent/lib/python3.8/site-packages (from bpython) (0.4.2)
Requirement already satisfied: cwcwidth in /root/tencent/lib64/python3.8/site-packages (from bpython) (0.1.8)
Requirement already satisfied: greenlet in /root/tencent/lib64/python3.8/site-packages (from bpython) (3.0.0)
Requirement already satisfied: pygments in /root/tencent/lib/python3.8/site-packages (from bpython) (2.16.1)
Requirement already satisfied: pyxdg in /root/tencent/lib/python3.8/site-packages (from bpython) (0.28)
Requirement already satisfied: requests in /root/tencent/lib/python3.8/site-packages (from bpython) (2.31.0)
Requirement already satisfied: blessed>=1.5 in /root/tencent/lib/python3.8/site-packages (from curtsies>=0.4.0->bpython) (1.20.0)
Requirement already satisfied: charset-normalizer<4,>=2 in /root/tencent/lib64/python3.8/site-packages (from requests->bpython) (3.3.0)
Requirement already satisfied: idna<4,>=2.5 in /root/tencent/lib/python3.8/site-packages (from requests->bpython) (3.4)
Requirement already satisfied: certifi>=2017.4.17 in /root/tencent/lib/python3.8/site-packages (from requests->bpython) (2023.7.22)
Requirement already satisfied: wcwidth>=0.1.4 in /root/tencent/lib/python3.8/site-packages (from blessed>=1.5->curtsies>=0.4.0->bpython) (0.2.8)
Requirement already satisfied: six>=1.9.0 in /root/tencent/lib/python3.8/site-packages (from blessed>=1.5->curtsies>=0.4.0->bpython) (1.16.0)
Installing collected packages: urllib3
  Attempting uninstall: urllib3
    Found existing installation: urllib3 2.0.6
    Uninstalling urllib3-2.0.6:
      Successfully uninstalled urllib3-2.0.6
Successfully installed urllib3-1.26.5

(tencent) [root@wang-hao-hao-01.indv.freedom.org ~/tencent/scripts 15:33]# 22> bpython
bpython version 0.24 on top of Python 3.8.13 /root/tencent/bin/python
>>> quit()
(tencent) [root@wang-hao-hao-01.indv.freedom.org ~/tencent/scripts 15:34]# 23> 
```