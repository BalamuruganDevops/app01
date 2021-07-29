#!/bin/sh

Ip=$(az vm show -g apps-rg -n appvm --query privateIps -d)


echo $Ip  >> /etc/ansible/hosts
