#!/usr/bin/python
# -*- coding: UTF-8 -*-


# CGI处理模块
import cgi, cgitb
import subprocess

from colorama import Fore, Back, Style

print("Content-type:text/html")
print("")

# 创建 FieldStorage 的实例化
form = cgi.FieldStorage()

# 获取数据
id = form.getvalue("id")
hostname  = form.getvalue("hostname")
ip  = form.getvalue("ip")
ansible_hostgroup = "-".join(hostname.split("-")[0:-1])

print(Fore.BLUE + "[INFO] 初始化主机信息：ID: %s, HOSTNAME: %s, IP: %s, ANSIBLE_HOSTGROUP: %s" %
      (id, hostname, ip, ansible_hostgroup), Style.RESET_ALL)

# 默认使用ansible_hostgroup命名的playbook，如test-bigdata.yaml，如果没有则使用default.yaml文件进行初始化。
ansible_default_playbook = "default.yaml"
ansible_hostgroup_playbook = ansible_hostgroup + ".yaml"

cmd_exist_default_playbook = "test -f %s" % ansible_default_playbook
cmd_exist_ansible_hostgroup_playbook = "test -f %s" % ansible_default_playbook


test_cmd = "ansible 192.168.255.251 -u root -m shell -a 'touch /tmp/init_host.py--$$.txt'"
p = subprocess.Popen(test_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)

print(Fore.BLUE + "正常输出", Style.RESET_ALL)
print(p.stdout.read())

print(Fore.RED + "异常输出", Style.RESET_ALL)
print(p.stderr.read())