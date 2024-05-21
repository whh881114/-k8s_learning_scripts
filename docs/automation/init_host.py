#!/usr/bin/python
# -*- coding: UTF-8 -*-

# CGI处理模块
import cgi, cgitb
import re
import sys
import subprocess
import datetime
from colorama import Fore, Back, Style

print("Content-type:text/html")
print("")


# 创建FieldStorage的实例化
form = cgi.FieldStorage()

# 获取数据
id = form.getvalue("id")
hostname = form.getvalue("hostname")
ip = form.getvalue("ip")

if id is None or hostname is None or ip is None:
    print(Fore.RED + "[%s] - [CRITICAL] - The required parameters (id, hostname, and ip) are missing." %
          datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'), Style.RESET_ALL)
    sys.exit()

pattern_id = r"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*$"
pattern_hostname = r"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*-\d{3}$"
pattern_ip = r"(^25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d$)"

match_id = re.search(pattern_id, id)
match_hostname = re.search(pattern_hostname, hostname)
match_ip = re.search(pattern_ip, ip)

if match_id:
    print(Fore.BLUE + "[%s] - [INFO] - The provided id, %s, is valid." %
          (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'), id), Style.RESET_ALL)
else:
    print(Fore.RED + "[%s] - [ERROR] - The provided id, %s, is invalid. Valid id must follow the pattern "
                     "\"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*$\"." %
          (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'), id), Style.RESET_ALL)

if match_hostname:
    print(Fore.BLUE + "[%s] - [INFO] - The provided hostname, %s, is valid." %
          (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'), hostname), Style.RESET_ALL)
    hostgroup = "-".join(hostname.split("-")[0:-1])
else:
    print(Fore.RED + "[%s] - [ERROR] - The provided hostname, %s, is invalid. Valid hostname must follow the pattern "
                     "\"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*-\d{3}$\"." %
          (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'), hostname), Style.RESET_ALL)

if match_ip:
    print(Fore.BLUE + "[%s] - [INFO] - The provided ip, %s, is valid." %
          (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'), ip), Style.RESET_ALL)
else:
    print(Fore.RED + "[%s] - [ERROR] - The provided ip, %s, is invalid." %
          (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'), ip), Style.RESET_ALL)

if match_id and match_hostname and match_ip:
    pass
else:
    print(Fore.RED + "[%s] - [ERROR] - Data Verification Failed." %
          datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'), Style.RESET_ALL)
    sys.exit()


# 检查ansible playbook是否存在
playbook_root_dir = "/opt/ansible"
playbook_default = "default.yaml"
playbook_hostgroup = hostgroup + ".yaml"

cmd_exist_playbook_default = "test -f %s" % playbook_default
cmd_exist_playbook_hostgroup = "test -f %s" % playbook_hostgroup

status_playbook_default, _ = subprocess.getstatusoutput(cmd_exist_playbook_default)
status_playbook_hostgroup, _ = subprocess.getstatusoutput(cmd_exist_playbook_hostgroup)

if not status_playbook_default and status_playbook_hostgroup:
    print(Fore.YELLOW + "[%s] - [WARNING] - The default ansible playbook (%s) exists, however, the hostgroup ansible "
                      "playbook (%s) does not exist." % (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'),
                                                         playbook_default, playbook_hostgroup), Style.RESET_ALL)

if status_playbook_default and not status_playbook_hostgroup:
    print(Fore.BLUE + "[%s] - [INFO] - The default ansible playbook (%s) does not exist, fortunately, the hostgroup "
                    "ansible playbook (%s) exists." % (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'),
                                                       playbook_default, playbook_hostgroup), Style.RESET_ALL)

if not status_playbook_default and not status_playbook_hostgroup:
    print(Fore.BLUE + "[%s] - [INFO] - The default ansible playbook (%s) and the hostgroup ansible playbook (%s) exist."
        % (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'), playbook_default, playbook_hostgroup), Style.RESET_ALL)

if status_playbook_default and status_playbook_hostgroup:
    print(Fore.RED + "[%s] - [CRITICAL] - Neither the default ansible playbook (%s) nor the hostgroup ansible "
                     "playbook (%s) exists." % (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f'),
                                                playbook_default, playbook_hostgroup), Style.RESET_ALL)
    sys.exit()



#test_cmd = "ansible 192.168.255.251 -u root -m shell -a 'touch /tmp/init_host.py--$$.txt'"
#p = subprocess.Popen(test_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
#
#print(Fore.BLUE + "正常输出", Style.RESET_ALL)
#print(p.stdout.read())
#
#print(Fore.RED + "异常输出", Style.RESET_ALL)
#print(p.stderr.read())