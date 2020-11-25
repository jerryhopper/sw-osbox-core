#!/bin/bash



#sqlite3 -batch /etc/osbox/osbox.db "create table if not exists dbversion (id TEXT PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
if [ ! -f /etc/osbox/osbox.db ];then
    touch /etc/osbox/osbox.db
    chmod 0666 /etc/osbox/osbox.db
fi
if [ ! -w /etc/osbox/osbox.db ];then
    chmod 0666 /etc/osbox/osbox.db
fi






shopt -s nullglob
_updatefiles="/usr/local/osbox/project/sw-osbox-core/src/sh/database/updates/*.sql"
#_updatefiles=(*.sql)

#echo $_updatefiles

for f in $_updatefiles
do
    filename=$(basename -- "$f")
    extension="${filename##*.}"
    filename="${filename%.*}"
    if [ "$filename" != "$(sqlite3 -batch /etc/osbox/osbox.db "SELECT id FROM dbversion WHERE id='$filename';")" ]; then
        echo "Applying update $filename"
        sqlite3 -batch /etc/osbox/osbox.db "$(<"/usr/local/osbox/project/sw-osbox-core/src/sh/database/updates/$filename.sql")"
        if [ "$?" == "1" ]; then
          echo "Database update error."
          exit 1
        else
          echo "Database update ok."
          sqlite3 -batch /etc/osbox/osbox.db "INSERT INTO dbversion (id) VALUES ( '$filename' );"
        fi
    else
      echo "Update $filename already applied."
    fi
done

echo "Done!"
exit 0

# get latest version
#sqlite3 -batch /etc/osbox/osbox.db "select * FROM dbversion order by id limit 1"



# create table if not exists TableName (col1 typ1, ..., colN typN)
# SELECT COUNT(*) AS CNTREC FROM pragma_table_info('tablename') WHERE name='column_name'


# SELECT name FROM sqlite_master WHERE type='table' AND name='{table_name}';
#sqlite3 -batch /etc/osbox/osbox.db "SELECT name FROM sqlite_master WHERE type='table' AND name='{table_name}';"

#sqlite3 -batch /etc/osbox/osbox.db "CREATE table installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
#sqlite3 -batch /etc/osbox/osbox.db "INSERT INTO table ( installog ) VALUES( 'osbox.db created' );"



#sqlite3 -batch /etc/osbox/osbox.db "SELECT COUNT(*) AS CNTREC FROM pragma_table_info('installog') WHERE name='column_name';"
#echo $?


# table status
# columns:  role,owner-email


#sqlite3 -batch /etc/osbox/osbox.db "create table if not exists role (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,role TEXT);"
#echo $?
