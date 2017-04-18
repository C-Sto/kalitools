#!/bin/bash

# CHANGE YOUR PASSWORD
passwd

# ofc
apt-get update
apt-get -y upgrade

#32 bit headers asdfasdfasfd WHY ISNT THIS IN BY DEFAULT?!!?
apt-get -y install lib32stdc++6 libc6-i386

# pwntools
apt-get -y install python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential
pip install --upgrade pip
pip install --upgrade pwntools

#gdb-peda
apt-get -y install gdb-peda

# wireshark sux
apt-get -y remove wireshark-common
apt-get -y install wireshark

# get a better r2 idk if it works? https://securityblog.gr/3791/install-latest-radare2-on-kali/
apt-get -y purge radare2
# probably should work out how to make this automatically the most recent but whatever
apt-get -y install valac libvala-0.34-dev swig
pip install r2pipe
pip install --upgrade xdot
cd ~/
git clone https://github.com/radare/radare2
cd radare2
sys/install.sh
cd ~/
#   valabind
apt-get purge valabind
git clone https://github.com/radare/valabind
cd valabind
make
make install PREFIX=/usr
cd ~/
#   r2 bindings
git clone https://github.com/radare/radare2-bindings
cd radare2-bindings
./configure --prefix=/usr
cd python
make
make install
cd ~/

#autopsy
apt-get -y install autopsy

# caca
apt-get -y install caca-utils

# esptool
apt-get -y install esptool

# espeak
apt-get -y install espeak

# virtualenv
apt-get -y install virtualenv

# droidbox IDKLOL http://blog.dornea.nu/2014/08/05/android-dynamic-code-analysis-mastering-droidbox/
#apt-get -y install python-virtualenv libatlas-dev liblapack-dev libblas-dev
#cd ~/
# apparently you have to do some env stuff? idk
#mkdir droidenv
#virtualenv droidenv
#source droidenv/bin/activate
#pip install numpy scipy matplotlib
#wget https://droidbox.googlecode.com/files/DroidBox411RC.tar.gz

# jadx
cd ~/
git clone https://github.com/skylot/jadx.git
cd jadx
./gradlew dist

# cyberchef (run with cyberchef command)
mkdir /opt/cyberchef
wget https://gchq.github.io/CyberChef/cyberchef.htm -O /opt/cyberchef/cyberchef.htm
echo '#!/bin/bash' > /usr/local/bin/cyberchef
echo 'firefox /opt/cyberchef/cyberchef.htm' > /usr/local/bin/cyberchef
chmod +x /usr/local/bin/cyberchef

# cmatrix
apt-get -y install cmatrix

# apktool
apt-get -y install apktool

# qemu
apt-get -y install qemu qemu-kvm qemu-system qemu-system-arm qemu-system-common qemu-system-mips qemu-system-ppc qemu-system-sparc qemu-system-x86 qemu-utils

# die
mkdir /opt/die
wget https://www.dropbox.com/s/7v49w3jiey9rrjm/DIE_1.01_lin64.tar.gz?dl=1 -O /opt/die/DIE1.01.tar.gz
tar -xf /opt/die/DIE1.01.tar.gz -C /opt/die/
ln -s /opt/die/lin64/die /usr/local/bin/

# preeny
apt-get -y install libini-config-dev
cd ~/
git clone https://github.com/zardus/preeny.git
cd preeny
make
cd ~/

# thefuck
apt-get -y install thefuck

# bro
apt-get -y install bro

# bless
apt-get -y install bless

# empire
apt-get -y install empire

# hob0rules
cd ~/
mkdir hob0rules
cd hob0rules
wget https://raw.githubusercontent.com/praetorian-inc/Hob0Rules/master/d3adhob0.rule
wget https://raw.githubusercontent.com/praetorian-inc/Hob0Rules/master/hob064.rule
cd ~/

# magic wormhole
apt-get -y install magic-wormhole

# bloodhound
apt-get -y install apt-transport-https
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
apt-get update
apt-get -y install neo4j
cd ~/
git clone https://github.com/adaptivethreat/Bloodhound
# THIS SEEMS OK

#docker :rolleyes: adsfasdfsadf no idea
#apt-get -y install apt-transport-https ca-certificates curl software-properties-common
#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
#apt-get update
#apt-get -y install docker-ce

# vbox
apt-get -y install virtualbox

# voltron
apt-get -y install voltron

# snort
apt-get -y install snort

# yara
apt-get -y install yara

#ltrace
apt-get -y install ltrace

# cowsay
apt-get -y install cowsay

# irssi
apt-get -y install irssi

# lynx
apt-get -y install lynx

# beef
apt-get -y install beef

# afl
apt-get -y install afl

# gimp
apt-get -y install gimp

# masscan
apt-get -y install masscan

# unicorn
apt-get -y install unicornscan

# audacity
apt-get -y install audacity

# responder
apt-get -y install responder

# sshuttle
apt-get -y install sshuttle

# zsteg errors?
#gem install zsteg

# exiftool
gem install exiftool

# apt-get autogoodcleanremove
apt-get -y autoremove
apt-get -y autoclean
