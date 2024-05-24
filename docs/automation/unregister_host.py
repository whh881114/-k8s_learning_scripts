#!/usr/bin/python
# -*- coding: UTF-8 -*-

# CGI处理模块
import cgi, cgitb
import re
import sys
import redis
import subprocess
import datetime
from colorama import Fore, Back, Style

print("Content-type:text/html")
print("")


# 创建FieldStorage的实例化
form = cgi.FieldStorage()

# 获取数据
hostname = form.getvalue("hostname")
if hostname is None:
    print(Fore.RED + "[%s] - [CRITICAL] - The required parameters (id, hostname, and ip) are missing." %
          datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), Style.RESET_ALL)
    sys.exit()

pattern_hostname = r"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*-\d{3}$"
match_hostname = re.search(pattern_hostname, hostname)
if match_hostname:
    print(Fore.BLUE + "[%s] - [INFO] - The provided hostname, %s, is valid." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), hostname), Style.RESET_ALL)
else:
    print(Fore.RED + "[%s] - [ERROR] - The provided hostname, %s, is invalid. Valid hostname must follow the pattern "
                     "\"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*-\d{3}$\"." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), hostname), Style.RESET_ALL)
    sys.exit()


# 主机名全局唯一
r = redis.StrictRedis(host="localhost", port=6379, db=15, password="svkinyOeb.lz!fpO7_ntb7ikbgmezmcd")
lock_result = r.hget("LOCK__" + hostname, "id__ip")
if lock_result is None:
    print(Fore.YELLOW + "[%s] - [WARNING] - The lock of the hostname does not exist, %s." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), hostname), Style.RESET_ALL)
else:
    r.hdel("LOCK__" + hostname, "id__ip")
    print(Fore.BLUE + "[%s] - [INFO] - The lock of the hostname has been release, %s." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), hostname), Style.RESET_ALL)

# 注销主机时，除去释放锁外，暂时不执行任何ansible操作。