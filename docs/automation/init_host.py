#!/usr/bin/python
# -*- coding: UTF-8 -*-


# CGI处理模块
import cgi, cgitb
import subprocess

from colorama import Fore, Back, Style


# 创建 FieldStorage 的实例化
form = cgi.FieldStorage()

# 获取数据
site_name = form.getvalue('name')
site_url  = form.getvalue('url')

print("Content-type:text/html")
print("")
print("name: %s, url: %s" % (site_name, site_url))

print("开始初始化主机")

test_cmd = "ansible 192.168.255.251 -u root -m shell -a 'touch /tmp/init_host.py--$$.txt'"
p = subprocess.Popen(test_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)

print(Fore.BLUE + "正常输出", Style.RESET_ALL)
print(p.stdout.read())

print(Fore.RED + "异常输出", Style.RESET_ALL)
print(p.stderr.read())