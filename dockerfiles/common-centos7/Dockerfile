FROM harbor.freedom.org/docker.io/centos:7.9.2009

LABEL AUTHOR="Wanghaohao"
LABEL DATACENTER="DELL-R620-PERSONAL-DATACENTER"

# 注册内部yum源，安装基础包。
RUN set -eux && yum -y install subscription-manager http://foreman.freedom.org/pub/katello-ca-consumer-latest.noarch.rpm
RUN set -eux && subscription-manager register --force --org=Default_Organization --activationkey=CentOS-7-x86_64
RUN set -eux && \
    yum -y install curl \
                   nc \
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
                   wget

# 配置vim。
ADD files/vim/vimrc /root/.vimrc