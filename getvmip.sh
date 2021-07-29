#!/bin/sh

Ip=$(az vm list-ip-addresses --resource-group apprg --name appvm --query '[].virtualMachine.network.publicIpAddresses[0].ipAddress')


echo $Ip  >> /etc/ansible/hosts

