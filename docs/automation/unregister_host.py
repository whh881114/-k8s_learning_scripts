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
id = form.getvalue("id")

if id is None:
    print(Fore.RED + "[%s] - [CRITICAL] - The required parameters (id, hostname, and ip) are missing." %
          datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), Style.RESET_ALL)
    sys.exit()

pattern_id = r"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*$"
match_id = re.search(pattern_id, id)
if match_id:
    print(Fore.BLUE + "[%s] - [INFO] - The provided id, %s, is valid." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), id), Style.RESET_ALL)
else:
    print(Fore.RED + "[%s] - [ERROR] - The provided id, %s, is invalid. Valid id must follow the pattern "
                     "\"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*$\"." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), id), Style.RESET_ALL)
    sys.exit()


# 释放主机名锁
r = redis.StrictRedis(host="localhost", port=6379, db=15, password="svkinyOeb.lz!fpO7_ntb7ikbgmezmcd")
for k in r.keys("LOCK_%s__*" % (id)):
    r.delet(k)
print(Fore.BLUE + "[%s] - [INFO] - The lock of the id is released, %s." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), id), Style.RESET_ALL)


# 不对主机上的程序做任何变更。