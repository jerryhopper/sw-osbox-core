create table if not exists installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);
insert into installog ( f ) VALUES( 'database schema created.' );
create table if not exists configuration (id TEXT PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);
insert into configuration (id,f) VALUES ('ROLE','UNCONFIGURED');
