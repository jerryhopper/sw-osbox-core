#!/bin/bash

echo "status.sh"
if [ -f /etc/osbox/dev ]; then
    echo "Development version"
else
    echo "Production version"
fi

#rm /etc/osbox/osbox.db

if [ ! -f /etc/osbox/osbox.db ];then

    echo "no /etc/osbox/osbox.db"
    touch /etc/osbox/osbox.db
    sqlite3 -batch /etc/osbox/osbox.db "create table installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
    sqlite3 -batch /etc/osbox/osbox.db "insert INTO installog ( f ) VALUES( 'osbox.db created' );"

fi
