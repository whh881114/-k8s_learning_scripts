FROM harbor.freedom.org/freedom/common-centos7:latest

LABEL AUTHOR="Wanghaohao"
LABEL DATACENTER="DELL-R620-PERSONAL-DATACENTER"

ENV JAVA_HEAP_XMS 1024m
ENV JAVA_HEAP_XMX 8192m
ENV JAVA_JMX_OPTS "-javaagent:/lib/jmx_prometheus_javaagent.jar=60030:/etc/jmx-cfg.yml"
ENV JAVA_OPTS "-Djava.awt.headless=true -DJENKINS_HOME=/data -jar /usr/lib/jenkins/jenkins.war --logfile=/dev/terminal --webroot=/data/war --httpPort=8080 --debug=5 --handlerCountMax=10 --handlerCountMaxIdle=20"

COPY files/jmx_prometheus_javaagent-0.17.0.jar /lib/jmx_prometheus_javaagent.jar
COPY files/jmx-cfg.yml /etc/jmx-cfg.yml
COPY files/jenkins-2.319.1-1.1.noarch.rpm /usr/local/src
COPY entrypoint.sh /entrypoint.sh

# 个人数据中心的kubeneters版本为1.21.5，所以kubectl安装的版本也是这个。
RUN set -eux && \
    chmod 755 /entrypoint.sh && \
    yum -y localinstall /usr/local/src/jenkins-2.319.1-1.1.noarch.rpm && \
    yum -y install docker-ce

WORKDIR /root

VOLUME /data

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]