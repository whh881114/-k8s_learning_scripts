FROM harbor.freedom.org/docker.io/centos:7.9.2009

LABEL AUTHOR="Wanghaohao"
LABEL DATACENTER="DELL-R620-PERSONAL-DATACENTER"

ENV LANG zh_CN.UTF-8
ENV LC_CTYPE zh_CN.UTF-8

WORKDIR /data

ADD files/vimrc /root/.vimrc
ADD files/el7-repo.tar.gz /etc/yum.repos.d
ADD files/arthas-bin.zip .

RUN set -eux && \
    yum -y install curl \
                   wget \
                   nc \
                   gcc \
                   make \
                   unzip \
                   telnet \
                   java-1.8.0-openjdk \
                   java-1.8.0-openjdk-* \
                   net-tools \
                   iproute \
                   vim \
                   dos2unix \
                   unix2dos \
                   tree \
                   git \
                   supervisor \
                   kde-l10n-Chinese && \
    yum -y reinstall glibc-common && \
    localedef -i zh_CN -c -f UTF-8 zh_CN.UTF-8 && \
    echo "export LC_ALL=zh_CN.UTF-8" >> /etc/profile && \
    unzip arthas-bin.zip && \
    rm -f arthas-bin.zip