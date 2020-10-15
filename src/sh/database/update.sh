#!/bin/bash

# create table if not exists TableName (col1 typ1, ..., colN typN)
# SELECT COUNT(*) AS CNTREC FROM pragma_table_info('tablename') WHERE name='column_name'



#sqlite3 -batch /etc/osbox/osbox.db "CREATE table installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
#sqlite3 -batch /etc/osbox/osbox.db "INSERT INTO table ( installog ) VALUES( 'osbox.db created' );"

sqlite3 -batch /etc/osbox/osbox.db "create table if not exists installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
echo $?


sqlite3 -batch /etc/osbox/osbox.db "SELECT COUNT(*) AS CNTREC FROM pragma_table_info('installog') WHERE name='column_name';"
echo $?


# table status
# columns:  role,owner-email


sqlite3 -batch /etc/osbox/osbox.db "create table if not exists role (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,role TEXT);"
echo $?
