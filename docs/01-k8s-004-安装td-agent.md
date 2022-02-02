# td-agent.md安装说明文档

## 引用
- http://www.pangxieke.com/linux/docker-logging-fluentd.html
- https://xujiahua.github.io/posts/20200402-use-fluentd/
- https://docs.docker.com/config/containers/logging/configure/
- https://docs.docker.com/config/containers/logging/json-file/

## 说明
- Docker每个容器运行一个单独的进程，进程的输出，一般保存在容器中，或者挂载在主机的磁盘上。这样会存在一些问题：
    - 日志无限制的增长。Docker以JSON消息记录每一行日志，这能引起文件增长过快以及超过主机上的磁盘空间，因为它不会自动轮转。（旧版本是不支持rotation）
    - docker logs 命令返回在每次它运行的时候返回所有的日志记录。任何长时间运行的进程产生的日志都是冗长的，这会导致仔细检查非常困难。
    - 日志位于容器 /var/log 下或者宿主机磁盘空间上。

- Docker官方有fluentd的Logging Driver。不足之处：
    - 因为没有了本地日志文件，docker logs 不管用了。我当前使用kurbernetes-v1.21.5和docker-ce-20.10.8，可以使用kubectl查看到日志。
    - 需要额外配置，或是在daemon.json里设定，或是docker run时候设定。新增机器或是运行容器，很容易忘记。
    - 如果远程的elasticsearch集群宕机，会丢数据，并且还需要重启td-agent。

- 综上所述：最好的方法是，先将日志格式改造，然后将容器日志输出到/dev/stdout和/dev/stderr，另一方面，应用日志输出到规定目录，然后映射到本地，最后使用td-agent/filebeat收集。

## 当前实施方案
- 使用fluentd日志引擎，因为配置这个可以有container_name，在用json-file时，获取不到container_name，不知道是不是配置的不对，并且改日志引擎，需要把容器recreate一次。排查json-file太要时间了，为了省事，就先用fluentd了。
- 当可以读取日志文件时，就可以考虑别的工具了，不一定是fluentd。