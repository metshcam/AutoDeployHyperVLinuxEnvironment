####
## HyperV: Create virtual differencing disk, with existing parent drive (centos8)
## Service: steamcmd 
## Game:    Valheim Sandstorm
## Requires: Windows 10,HyperV,existing virtual switch, openssh
####

hostname='valheim'
domain='domain.com'
game='valheim'
gameid='896660'
username='steam'
userhomepath='/home/'${username}
installations='glibc.i686 libstdc++.i686 policycoreutils-python-utils'

## Game Server Variables
## Game specific variables
##

serverowner='somefunnyname'
serverpassword='password'
serverport='2456' 

## Set hostname
##
    hostnamectl set-hostname ${hostname}'.'${domain}

## Firewall settings
## Valheim
    sourceIP='0.0.0.0/24'
    firewall-cmd --zone=public --add-source=${sourceIP}
    firewall-cmd --zone=public --add-port=2456-2458/tcp
    firewall-cmd --zone=public --add-port=2456-2458/udp
    
## Set firewall and reload    
    firewall-cmd --runtime-to-permanent
    firewall-cmd --reload
    
## Add firewall entries
## Allow all
## To-do: work on port range
## Create rich rules
    #firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.0.0" port protocol="tcp" port="22" accept'

## Add service User
##  
    useradd ${username}

## Change service user password
## Removed as service user will use ssh key from host
    #echo -e "steam\nsteam" | passwd steam

## Install steamcmd dependencies
##
    yum -y install ${installations}
    
## Set permissions on SSH folder and authorized_keys
##
    chmod 700 /root/.ssh/
    chmod 600 /root/.ssh/authorized_keys

## Create SSH path for new user, and copy host public RSA key (from Copy-VMFile; /root/hyperv/)
## Set proper permissions on new user's SSH folder and file
##
    mkdir -p ${userhomepath}'/.ssh/'
    cat /root/.ssh/authorized_keys >> ${userhomepath}'/.ssh/authorized_keys'
    chmod 700 ${userhomepath}'/.ssh'
    chmod 600 ${userhomepath}'/.ssh/authorized_keys'

## Disallow passwords over SSH
## Force only public key auth
## 
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

## Disable root login over SSH
## Enable this when done testing
## sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

## Restart SSH server
##
    systemctl restart sshd.service

## Create preconfigured game server settings
## Prepopulate the folder to move files for Valheim configuration
## e.g.
##  mkdir -p $userhomepath'/steamcmd/'$game'/Valheim/Saved/Config/LinuxServer/'

    mkdir -p ${userhomepath}'/steamcmd/'${game}/

## Download and extract steamcmd to service user home
##
    curl -o ${userhomepath}'/steamcmd/steamcmd_linux.tar.gz' -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
    tar -zxvf ${userhomepath}'/steamcmd/steamcmd_linux.tar.gz' -C ${userhomepath}'/steamcmd/'

## Build the launch and update files for your game server
## Removed: no need to move more files with little text
    #mv '/root/hyperv/valheim_update.sh' $userhomepath'/steamcmd/'${game}'_update'
    #mv '/root/hyperv/valheim_launch.sh' $userhomepath'/steamcmd/'${game}'_launch'

## Build the update file for your game server
## 
    echo 'login anonymous
force_install_dir '${userhomepath}'/steamcmd/'${game}'
app_update '${gameid}'
quit' > ${userhomepath}'/steamcmd/'${game}'_update'

## Build the launch file for your game server
## Game server info:
## 
    echo '#!/bin/bash

export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH='${userhomepath}'/steamcmd/'${game}'/linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

'${userhomepath}'/steamcmd/steamcmd.sh +runscript '${userhomepath}'/steamcmd/'${game}'_update

'${userhomepath}'/steamcmd/'${game}'/valheim_server.x86_64 -name "'${serverowner}' '${game}' server" -port '${serverport}' -world "Dedicated" -password "'${serverpassword}'" -public 1

export LD_LIBRARY_PATH=$templdpath' > $userhomepath'/steamcmd/'${game}'_launch'

## Make files executable
##
    chmod +x ${userhomepath}'/steamcmd/'${game}'_update'
    chmod +x ${userhomepath}'/steamcmd/'${game}'_launch'

## Make all the files are owned by the user before running the installer
##
    chown -R ${username}':'${username} ${userhomepath}'/'
    
## Run the steamcmd.sh installer and use the game update file
## bug: doesnt seem to always for for every game
    runuser -l ${username} -c "${userhomepath}/steamcmd/steamcmd.sh +runscript ${userhomepath}/steamcmd/${game}_update"

## Create steamcmd service file
## Use gameid from steam to build server
##
    touch '/etc/systemd/system/steamcmd_'${gameid}'.service'

## Copy game server configuration into new file 
##
    echo "
## /etc/systemd/system/steamcmd_${gameid}.service
[Unit]
Description=My steamcmd ${game} Server
After=network.target network-online.target

[Service]
User=${username}
WorkingDirectory=${userhomepath}/steamcmd/

ExecStart=${userhomepath}/steamcmd/${game}_launch

TimeoutStartSec=infinity
## Restart=always
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
## END OF FILE
" > '/etc/systemd/system/steamcmd_'${gameid}'.service'

## Set executable and permissions on systemd service file
##
    chmod 0644 '/etc/systemd/system/steamcmd_'${gameid}'.service'

## Disable SELinux
##
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

## Enable steamcmd game service
##
    systemctl enable 'steamcmd_'${gameid}'.service'

## Save SELinux module for service
##
##    grep steamcmd /var/log/audit/audit.log | audit2allow -M steamcmd

## Import steamcmd.pp and .te
##
##    semodule -i steamcmd.pp

## Enable SELinux
##
## setenforce 1

## Restart
##
    reboot
