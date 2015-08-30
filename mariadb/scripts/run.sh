#!/bin/bash

VOLUME_HOME="/var/lib/mysql/"

if [ -e ${VOLUME_HOME}/.init ]; then
    echo " -> Installation detected in $VOLUME_HOME"
    echo " -> Installing MariaDB"
    mysql_install_db > /dev/null 2>&1
    chown mysql.mysql -R ${VOLUME_HOME}
    /setup.sh
    rm -rf ${VOLUME_HOME}/.init
    echo " -> Done!"
else  
    echo "-> Booting on existing volume!"
fi

exec mysqld_safe
