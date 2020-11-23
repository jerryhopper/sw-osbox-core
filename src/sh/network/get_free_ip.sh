#!/bin/bash


IFS=$'\r\n'
var=($(osbox network scan|grep Down))
#echo $var[1]
unset IFS


echo "${var[-2]}"|awk -F ' ' '{print $2}'



exit
