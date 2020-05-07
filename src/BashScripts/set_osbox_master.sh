#!/bin/bash

# set avahi to master
# set ssl ON





echo "<?xml version=\"1.0\" standalone='no'?><!--*-nxml-*-->">/etc/avahi/services/osbox.service
echo "<!DOCTYPE service-group SYSTEM \"avahi-service.dtd\">">>/etc/avahi/services/osbox.service
echo "<service-group>">>/etc/avahi/services/osbox.service
echo "  <name replace-wildcards=\"yes\">Configured OsBox device on %h</name>">>/etc/avahi/services/osbox.service
echo "  <service protocol=\"ipv4\">">>/etc/avahi/services/osbox.service
echo "    <type>_osboxmaster._tcp</type>">>/etc/avahi/services/osbox.service
echo "    <domain-name>local</domain-name>">>/etc/avahi/services/osbox.service
echo "    <port>9501</port>">>/etc/avahi/services/osbox.service
echo "    <txt-record>ssl=true</txt-record>">>/etc/avahi/services/osbox.service
echo "  </service>">>/etc/avahi/services/osbox.service
echo "</service-group>">>/etc/avahi/services/osbox.service
