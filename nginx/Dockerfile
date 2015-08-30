FROM centos:7
MAINTAINER rabe_ame rabe.ame@gmail.com

# 必要なパッケージをインストール
RUN yum update -y
RUN yum install -y vim sudo

# 開発用ユーザーを作成
RUN useradd -m -s /bin/bash docker
RUN echo 'docker:password' | chpasswd
RUN echo 'docker ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/docker

# nginx インストール
RUN rpm --import http://nginx.org/keys/nginx_signing.key
RUN yum install -y http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum install -y nginx
ADD ./configs/nginx.conf /etc/nginx/nginx.conf
ADD ./configs/default.conf /etc/nginx/conf.d/default.conf

# clean up
RUN yum clean all

# entrypoint
CMD ["nginx"]
