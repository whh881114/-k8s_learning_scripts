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
hostname = form.getvalue("hostname")
ip = form.getvalue("ip")

if id is None or hostname is None or ip is None:
    print(Fore.RED + "[%s] - [CRITICAL] - The required parameters (id, hostname, and ip) are missing." %
          datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), Style.RESET_ALL)
    sys.exit()

pattern_id = r"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*$"
pattern_hostname = r"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*-\d{3}$"
pattern_ip = (r"(^25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\."
              r"(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d$)")

match_id = re.search(pattern_id, id)
match_hostname = re.search(pattern_hostname, hostname)
match_ip = re.search(pattern_ip, ip)

if match_id:
    print(Fore.BLUE + "[%s] - [INFO] - The provided id, %s, is valid." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), id), Style.RESET_ALL)
else:
    print(Fore.RED + "[%s] - [ERROR] - The provided id, %s, is invalid. Valid id must follow the pattern "
                     "\"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*$\"." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), id), Style.RESET_ALL)

if match_hostname:
    print(Fore.BLUE + "[%s] - [INFO] - The provided hostname, %s, is valid." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), hostname), Style.RESET_ALL)
    hostgroup = "-".join(hostname.split("-")[0:-1])  # 主机组名中使用"-"，在执行ansible命令时，会有WARNING提示，影响不大。
else:
    print(Fore.RED + "[%s] - [ERROR] - The provided hostname, %s, is invalid. Valid hostname must follow the pattern "
                     "\"^[a-zA-Z0-9]+-[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*-\d{3}$\"." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), hostname), Style.RESET_ALL)

if match_ip:
    print(Fore.BLUE + "[%s] - [INFO] - The provided ip, %s, is valid." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), ip), Style.RESET_ALL)
else:
    print(Fore.RED + "[%s] - [ERROR] - The provided ip, %s, is invalid." %
          (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), ip), Style.RESET_ALL)

if match_id and match_hostname and match_ip:
    pass
else:
    print(Fore.RED + "[%s] - [ERROR] - Data Verification Failed." %
          datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), Style.RESET_ALL)
    sys.exit()


# 主机名全局唯一
r = redis.StrictRedis(host="localhost", port=6379, db=15, password="svkinyOeb.lz!fpO7_ntb7ikbgmezmcd")
try:
    hostname_lock = r.hsetnx("LOCK__" + hostname, "id__ip", id + "__" + ip)
except:
    if hostname_lock:
        print(Fore.BLUE + "[%s] - [INFO] - Set a lock for the hostname, %s." %
              (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), hostname), Style.RESET_ALL)
    else:
        # 重复初始化逻辑
        lock_result = str(r.hget(hostname, "id_ip")).split("__")
        lock_id = lock_result[0]
        lock_ip = lock_result[1]
        if lock_id == id and lock_ip == ip:
            print(Fore.BLUE + "[%s] - [INFO] - Set a lock for the hostname, %s." %
                  (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), hostname), Style.RESET_ALL)
        else:
            print(Fore.RED + "[%s] - [CRITICAL] - The hostname is locked, %s." %
                  (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), hostname), Style.RESET_ALL)
            sys.exit()


# 检查ansible playbook是否存在
playbook_root_dir = "/opt/ansible"
playbook_log_dir = "/var/www/html/init_host_log"
playbook_default = "%s/default.yaml" % playbook_root_dir
playbook_hostgroup = "%s/%s.yaml" % (playbook_root_dir, hostgroup)

cmd_exist_playbook_default = "test -f %s" % playbook_default
cmd_exist_playbook_hostgroup = "test -f %s" % playbook_hostgroup

status_playbook_default, _ = subprocess.getstatusoutput(cmd_exist_playbook_default)
status_playbook_hostgroup, _ = subprocess.getstatusoutput(cmd_exist_playbook_hostgroup)

if not status_playbook_default and status_playbook_hostgroup:
    print(Fore.YELLOW + "[%s] - [WARNING] - The default ansible playbook (%s) exists, however, the hostgroup ansible "
                      "playbook (%s) does not exist." % (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'),
                                                         playbook_default, playbook_hostgroup), Style.RESET_ALL)
    playbook = playbook_default

if status_playbook_default and not status_playbook_hostgroup:
    print(Fore.BLUE + "[%s] - [INFO] - The default ansible playbook (%s) does not exist, fortunately, the hostgroup "
                    "ansible playbook (%s) exists." % (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'),
                                                       playbook_default, playbook_hostgroup), Style.RESET_ALL)
    playbook = playbook_hostgroup

if not status_playbook_default and not status_playbook_hostgroup:
    print(Fore.BLUE + "[%s] - [INFO] - The default ansible playbook (%s) and the hostgroup ansible playbook (%s) exist."
        % (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), playbook_default, playbook_hostgroup),
          Style.RESET_ALL)
    playbook = playbook_hostgroup

if status_playbook_default and status_playbook_hostgroup:
    print(Fore.RED + "[%s] - [CRITICAL] - Neither the default ansible playbook (%s) nor the hostgroup ansible "
                     "playbook (%s) exists." % (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'),
                                                playbook_default, playbook_hostgroup), Style.RESET_ALL)
    sys.exit()


# 开始初始化主机
print(Fore.BLUE + "[%s] - [INFO] - Start to initialize the host: %s -- %s -- %s, using %s playbook." %
      (datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), id, hostname, ip, playbook), Style.RESET_ALL)

# 需要修改playbook_log_dir权限，chown apache:apache $playbook_log_dir，cgi-bin客户端请求时，是以apache身份执行程序。
inventory = "%s/%s__%s__%s.txt" % (playbook_log_dir, id, hostname, ip)
with open(inventory, 'w') as f:
    f.write("[%s]\n" % hostgroup)
    f.write("%s\n" % ip)
    f.close()

command = ("cd %s && ansible-playbook %s -i %s 2>&1 | tee %s__%s.log" %
           (playbook_root_dir, playbook, inventory, inventory.replace(".txt", ""),
            datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f')))
process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
while True:
    line = process.stdout.readline()
    if not line:
        break
    print(line.decode('utf-8').rstrip())
process.stdout.close()
process.wait()

print(Fore.BLUE + "[%s] - [INFO] - Initialize host done." %
      datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S.%f'), Style.RESET_ALL)