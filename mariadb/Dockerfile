FROM centos:7
MAINTAINER rabe_ame rabe.ame@gmail.com

# リポジトリを追加
ADD ./configs/etc/yum.repos.d/mariadb.repo /etc/yum.repos.d/mariadb.repo

# 必要なパッケージをインストール
RUN yum update -y
RUN yum install -y tar sudo vim-enhanced MariaDB-devel MariaDB-server MariaDB-Client hostname

# 開発用ユーザーを作成
RUN useradd -m -s /bin/bash docker
RUN echo 'docker:password' | chpasswd
RUN echo 'docker ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/docker

# db 設定
ADD ./scripts/run.sh /
ADD ./scripts/setup.sh /
RUN chmod 775 /*.sh

# 設定ファイル
ADD ./configs/etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf

# clean up
RUN yum clean all

RUN touch /var/lib/mysql/.init

# entrypoint
CMD ["/run.sh"]
