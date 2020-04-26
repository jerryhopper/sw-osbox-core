#!/bin/bash


source /usr/local/osbox/lib/bashfunc/is_root
source /usr/local/osbox/lib/bashfunc/is_command


# set the enviroment variable.
PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d

# start the scheduler proces.
/usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini -f /usr/local/osbox/project/sw-osbox-core/src/osbox-scheduler.php
