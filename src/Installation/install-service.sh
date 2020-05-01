#!/bin/bash


set -e

sudo echo "running,10,stap1">/etc/osbox/setup.state

sleep 10

sudo echo "running,10,stap2">/etc/osbox/setup.state

sleep 10

sudo echo "running,10,stap3">/etc/osbox/setup.state

sleep 10

sudo echo "running,10,stap4">/etc/osbox/setup.state

sleep 5

sudo echo "running,10,stap5">/etc/osbox/setup.state

sleep 5

echo "running,10,stap6">/etc/osbox/setup.state

sleep 5

echo "running,10,stap7">/etc/osbox/setup.state

sleep 2

echo "running,10,stap8">/etc/osbox/setup.state

sleep 2

echo "running,10,stap9">/etc/osbox/setup.state

sleep 2

echo "finished,10,finished">/etc/osbox/setup.state
