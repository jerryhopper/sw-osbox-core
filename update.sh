#!/bin/bash


#PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d
PHP_INI_SCAN_DIR=/usr/local/osbox/bin/conf.d /usr/local/osbox/bin/osboxd -c /usr/local/osbox/bin/osboxd.ini /usr/local/osbox/bin/composer.phar --working-dir=/usr/local/osbox/project/sw-osbox-core update

