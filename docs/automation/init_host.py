#!/usr/bin/python
# -*- coding: UTF-8 -*-

# CGI处理模块
import cgi, cgitb
import re
import sys
import subprocess
from colorama import Fore, Back, Style

print("Content-type:text/html")
print("")

# 创建 FieldStorage 的实例化
form = cgi.FieldStorage()

# 获取数据
id = form.getvalue("id")  # id，各厂商不一样，先暂时按(\w+-){1,}匹配处理。
hostname = form.getvalue("hostname")  # 主机名要求格式"(\w+-){1,}-\d{3}"。
ip = form.getvalue(
    "ip")  # (25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)

pattern_id = r"\w+-\w+(?:-\w+)*$"
pattern_hostname = r"\w+-\w+(?:-\w+)*-\d{3}$"
pattern_ip = r"(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)"

match_id = re.search(pattern_id, id)
match_hostname = re.search(pattern_hostname, hostname)
match_ip = re.search(pattern_ip, ip)

if match_id:
    print(Fore.BLUE + "The provided id, %s, is valid." % id, Style.RESET_ALL)
else:
    print("The provided id, %s, is invalid. Valid id must follow the pattern \"\w+-\w+(?:-\w+)*$\"." % id)

if match_hostname:
    print("The provided hostname, %s, is valid." % hostname)
    ansible_hostgroup = "-".join(hostname.split("-")[0:-1])
else:
    print("The provided hostname, %s, is invalid. Valid hostname must follow the pattern \"\w+-\w+(?:-\w+)*-\d{3}$\"." % hostname)

if match_ip:
    print("The provided ip, %s, is valid." % ip)
else:
    print("The provided ip, %s, is invalid." % ip)

if match_id and match_hostname and match_ip:
    pass
else:
    print("Data Verification Failed.")
    sys.exit()