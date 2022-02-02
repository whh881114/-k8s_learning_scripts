FROM harbor.freedom.org/freedom/common-centos7:latest

LABEL AUTHOR="Wanghaohao"
LABEL DATACENTER="DELL-R620-PERSONAL-DATACENTER"

ADD entrypoint.sh /

# 个人数据中心的kubeneters版本为1.21.5，所以kubectl安装的版本也是这个。
RUN set -eux && \
    chmod 755 /entrypoint.sh && \
    yum -y install http://foreman.freedom.org/pub/jenkins-2.319.1-1.1.noarch.rpm \
                   docker-ce

WORKDIR /root

VOLUME /data

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]