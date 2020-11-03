#!/bin/bash



sqlite3 -batch /etc/osbox/osbox.db "create table if not exists dbversion (id TEXT PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"




_updatefiles="./updates/*.sql"

for f in $_updatefiles
do
    #echo "$f"
    filename=$(basename -- "$f")
    extension="${filename##*.}"
    filename="${filename%.*}"
    #echo $filename
    test=$(sqlite3 -batch /etc/osbox/osbox.db "SELECT id FROM dbversion WHERE id='$filename';")



    if [ "$filename" == "$test" ]; then
        echo "$filename already applied"
    else
        echo "Applying update $filename"
        sqlite3 -batch /etc/osbox/osbox.db "$(<"/usr/local/osbox/project/sw-osbox-core/src/sh/database/updates/$filename.sql")"
        if [ "$?" == "1" ]; then
          echo "Update error"
          exit 1
        else
          echo "ok"
          sqlite3 -batch /etc/osbox/osbox.db "INSER INTO dbversion (id) VALUES ( '$filename' );"
        fi
    fi

done

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
