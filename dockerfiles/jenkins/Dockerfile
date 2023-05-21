FROM docker.io/jenkins/jenkins:2.405-centos7

LABEL AUTHOR="Wanghaohao"
LABEL DATACENTER="DELL-R620-PERSONAL-DATACENTER"

ENV LANG zh_CN.UTF-8
ENV LC_CTYPE zh_CN.UTF-8

USER 0

COPY files/vimrc /root/.vimrc
COPY files/docker-ce.repo /etc/yum.repos.d/docker-ce.repo
COPY files/jmx_prometheus_javaagent-0.17.0.jar /lib/jmx_prometheus_javaagent.jar
COPY files/jmx-cfg.yml /etc/jmx-cfg.yml

RUN set -eux && \
    yum -y install epel-release && \
    yum clean all && \
    yum -y install curl \
                   wget \
                   nc \
                   gcc \
                   make \
                   unzip \
                   telnet \
                   net-tools \
                   iproute \
                   vim \
                   dos2unix \
                   unix2dos \
                   tree \
                   git \
                   supervisor \
                   kde-l10n-Chinese \
                   docker-ce-20.10.8 \
                   docker-ce-cli-20.10.18 \
                   docker-ce-rootless-extras-20.10.18 && \
    yum -y reinstall glibc-common && \
    localedef -i zh_CN -c -f UTF-8 zh_CN.UTF-8 && \
    echo "export LC_ALL=zh_CN.UTF-8" >> /etc/profile

CMD ["-javaagent:/lib/jmx_prometheus_javaagent.jar=60030:/etc/jmx-cfg.yml"]

EXPOSE 8080 50000 60030

VOLUME [/var/jenkins_home]