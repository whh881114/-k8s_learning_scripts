#!/usr/bin/python
# -*- coding: UTF-8 -*-

# CGI处理模块
import cgi, cgitb
import subprocess
import logging
import colorlog
import re
import sys

print("Content-type:text/html")
print("")

# 创建 FieldStorage 的实例化
form = cgi.FieldStorage()

# 获取数据
id = form.getvalue("id")              # id，各厂商不一样，先暂时按(\w+-){1,}匹配处理。
hostname  = form.getvalue("hostname") # 主机名要求格式"(\w+-){1,}-\d{3}"。
ip  = form.getvalue("ip")             # (25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)

# 日志配置
log_colors_config = {
    "DEBUG": "white",
    "INFO": "blue",
    "WARNING": "yellow",
    "ERROR": "red",
    "CRITICAL": "bold_red",
}

logger = logging.getLogger('logger_name')

# 日志配置：控制台
console_handler = logging.StreamHandler()
console_formatter = colorlog.ColoredFormatter(fmt='%(log_color)s[%(asctime)s.%(msecs)03d] [%(levelname)s]: %(message)s',
                                              datefmt='%Y-%m-%d  %H:%M:%S', log_colors=log_colors_config)
console_handler.setFormatter(console_formatter)

# 日志配置：文件
file_handler = logging.FileHandler(filename="%s__%s__%s.log" % (id, hostname, ip), mode="w", encoding="utf8")
file_formatter = logging.Formatter(fmt='[%(asctime)s.%(msecs)03d] [%(levelname)s]: %(message)s',datefmt='%Y-%m-%d  %H:%M:%S')
file_handler.setFormatter(file_formatter)

# 重复日志问题：
# 1、防止多次addHandler；
# 2、loggername 保证每次添加的时候不一样；
# 3、显示完log之后调用removeHandler
if not logger.handlers:
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

console_handler.close()
file_handler.close()

# 开始验证数据
pattern_id = r"\w+-\w+(?:-\w+)*$"
pattern_hostname = r"\w+-\w+(?:-\w+)*-\d{3}$"
pattern_ip = r"(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)"

match_id = re.search(pattern_id, id)
match_hostname = re.search(pattern_hostname, hostname)
match_ip = re.search(pattern_ip, ip)

if match_id:
    logger.info("The provided id, %s, is valid." % id)
else:
    logger.error("The provided id, %s, is invalid. Valid id must follow the pattern \"\w+-\w+(?:-\w+)*$\"." % id)

if match_hostname:
    logger.info("The provided hostname, %s, is valid." % hostname)
    ansible_hostgroup = "-".join(hostname.split("-")[0:-1])
else:
    logger.error("The provided hostname, %s, is invalid. Valid hostname must follow the pattern \"\w+-\w+(?:-\w+)*-\d{3}$\"." % hostname)

if match_ip:
    logger.info("The provided ip, %s, is valid." % ip)
else:
    logger.error("The provided ip, %s, is invalid." % ip)

if match_id and match_hostname and match_ip:
    pass
else:
    logger.error("Data Verification Failed.")
    sys.exit()


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