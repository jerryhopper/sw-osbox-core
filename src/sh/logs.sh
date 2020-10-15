#/bin/bash

if [ -f /etc/osbox/osbox.db ];then

    sqlite3 -batch /etc/osbox/osbox.db "select * from installog ORDER BY id DESC;"

fi
