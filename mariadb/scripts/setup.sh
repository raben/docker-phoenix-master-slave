#!/bin/bash

IPADDRESS=`/usr/sbin/ip a show | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n1`
echo "-> hostname: $IPADDR"

# server-id 指定 http://blog.nomadscafe.jp/2011/02/mysqlserver-id.html
SERVER_ID=`expr \`echo $IPADDRESS | cut -d. -f3\` \* 256 +  \`echo $IPADDRESS | cut -d. -f4\``
echo "-> server-id: $SERVER_ID"
sed -i -r "s/#server-id=/server-id=$SERVER_ID/i" /etc/my.cnf.d/server.cnf

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1  
while [[ RET -ne 0 ]]; do  
    sleep 3
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

# secure install
# test データベースが存在したら削除
mysql -uroot -h 127.0.0.1 -e "DROP DATABASE IF EXISTS test;"
# 匿名ユーザの削除
mysql -uroot -h 127.0.0.1 -e "DELETE FROM mysql.user WHERE user = '';"
# root ユーザのパスワードを設定
mysql -uroot -h 127.0.0.1 -e "SET PASSWORD FOR 'root'@'::1'                   = PASSWORD('$DB_ROOTPASS');"
mysql -uroot -h 127.0.0.1 -e "SET PASSWORD FOR 'root'@'127.0.0.1'             = PASSWORD('$DB_ROOTPASS');"
mysql -uroot -h 127.0.0.1 -e "SET PASSWORD FOR 'root'@'localhost'             = PASSWORD('$DB_ROOTPASS');"
# write ユーザー作成
mysql -uroot -h 127.0.0.1 -p$DB_ROOTPASS -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_RWUSER'@'%' IDENTIFIED BY '$DB_RWPASS' WITH GRANT OPTION"

if $IS_MASTER; then
    echo "-> I am Master!!!"

    # repl ユーザー作成
    mysql -uroot -h 127.0.0.1 -p$DB_ROOTPASS -e "GRANT REPLICATION SLAVE ON *.* TO '$DB_REPLUSER'@'%' IDENTIFIED BY '$DB_REPLPASS' WITH GRANT OPTION"
    # READユーザー作成と同時にshutdownする(別コンテナからのヘルスチェックに引っかからなくするため)
    mysql -uroot -h 127.0.0.1 -p$DB_ROOTPASS -e "GRANT SELECT ON *.* TO '$DB_ROUSER'@'%' IDENTIFIED BY '$DB_ROPASS'"; mysqladmin -uroot -p$DB_ROOTPASS shutdown;

else
    echo "-> I am Slave!!!"

    # READユーザー作成
    mysql -uroot -h 127.0.0.1 -p$DB_ROOTPASS -e "GRANT SELECT ON *.* TO '$DB_ROUSER'@'%' IDENTIFIED BY '$DB_ROPASS'"

    # master の起動を待つ
    echo "-> Search Master Server..."
    RET=1
    while [[ RET -ne 0 ]]; do
      sleep 20
      mysql -h master -u $DB_ROUSER -p$DB_ROPASS -e "status" > /dev/null 2>&1
      RET=$?
    done
    
    echo "-> Found Master Server"
    # master の GTIDを取得する
    FILE=`mysql -u $DB_RWUSER -p$DB_RWPASS -h master -e "show master status\G" | grep File | awk '{print $2}'`
    POSITION=`mysql -u $DB_RWUSER -p$DB_RWPASS -h master -e "show master status\G" | grep Position | awk '{print $2}'`
    GTID=`mysql -u $DB_RWUSER -p$DB_RWPASS -h master -e "SELECT BINLOG_GTID_POS('$FILE', $POSITION) as GTID\G" | grep GTID | awk '{print $2}'`

    # レプリケーション設定
    mysql -uroot -h 127.0.0.1 -p$DB_ROOTPASS -e "SET GLOBAL gtid_slave_pos = '$GTID';CHANGE MASTER TO MASTER_HOST='master', MASTER_USER='$DB_RWUSER', MASTER_PASSWORD='$DB_RWPASS', MASTER_USE_GTID = slave_pos;"
    mysql -uroot -h 127.0.0.1 -p$DB_ROOTPASS -e "START SLAVE;"; mysqladmin -uroot -p$DB_ROOTPASS shutdown;

    echo "-> Start Slave"
fi
