#!/bin/bash

echo "status.sh"
if [ -f /etc/osbox/dev ]; then
    echo "Development version"
else
    echo "Production version"
fi

#rm /etc/osbox/osbox.db

if [ -f /etc/osbox/osbox.db ];then

    sqlite3 -batch /etc/osbox/osbox.db "select * from installog ;"

fi
