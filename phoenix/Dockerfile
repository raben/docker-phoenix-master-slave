FROM centos:7
MAINTAINER rabe_ame rabe.ame@gmail.com

# リポジトリを追加
ADD ./configs/etc/yum.repos.d/mariadb.repo /etc/yum.repos.d/mariadb.repo


# 必要なパッケージをインストール
RUN yum update -y
RUN yum install -y tar wget sudo vim-enhanced git gcc gcc-c++ make zlib-devel openssl openssl-devel ncurses-devel MariaDB-devel MariaDB-client patch

# 開発用ユーザーを作成
RUN useradd -m -s /bin/bash docker
RUN echo 'docker:password' | chpasswd
RUN echo 'docker ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/docker

ENV HOME /root
WORKDIR $HOME
# erlang インストール
RUN wget http://www.erlang.org/download/otp_src_19.1.tar.gz
RUN tar xvf otp_src_19.1.tar.gz
RUN cd otp_src_19.1 && ./configure && make && make install
RUN rm -rf otp_src_19.1 otp_src_19.1.tar.gz
RUN echo 'export PATH="$PATH:/usr/local/bin"' >> ~/.bashrc

# nodejs インストール
RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
RUN yum -y install nodejs

# elixir インストール
ENV LANG ja_JP.UTF-8
RUN git clone --depth 1 https://github.com/elixir-lang/elixir.git
RUN cd elixir && git checkout -b v1.3.4 && make && make install
RUN cp elixir/rebar /usr/local/bin/
RUN rm -rf $HOME/elixir

# clean up
RUN yum clean all

# phoenix.ezを転送
#ADD ./src/phoenix_new-1.2.1.ez /phoenix_new.ez

ADD ./scripts/run.sh /run.sh
ADD ./scripts/init.sh /init.sh

RUN chmod 0755 /run.sh
RUN chmod 0755 /init.sh

USER docker
ENV HOME /home/docker
WORKDIR $HOME
CMD ["/run.sh"]
