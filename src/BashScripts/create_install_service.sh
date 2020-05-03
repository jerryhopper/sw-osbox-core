#!/bin/bash


MODULE="$1"


echo "[Unit]">/etc/systemd/system/osbox-install.service
echo "Description=Osbox-install at Boot">>/etc/systemd/system/osbox-install.service
echo "# Order 3">>/etc/systemd/system/osbox-install.service
echo "After=osbox.service network.target">>/etc/systemd/system/osbox-install.service
echo "">>/etc/systemd/system/osbox-install.service
echo "[Service]">>/etc/systemd/system/osbox-install.service
echo "Type=simple">>/etc/systemd/system/osbox-install.service
echo "User=root">>/etc/systemd/system/osbox-install.service
echo "RemainAfterExit=no">>/etc/systemd/system/osbox-install.service
echo "#StandardOutput=tty">>/etc/systemd/system/osbox-install.service
echo "ExecStart=/usr/local/osbox/project/$MODULE/src/Installation/install-service.sh">>/etc/systemd/system/osbox-install.service
echo "">>/etc/systemd/system/osbox-install.service
echo "[Install]">>/etc/systemd/system/osbox-install.service
echo "WantedBy=multi-user.target">>/etc/systemd/system/osbox-install.service
echo "">>/etc/systemd/system/osbox-install.service

chmod +x /usr/local/osbox/project/$MODULE/src/Installation/install-service.sh

systemctl enable osbox-install
