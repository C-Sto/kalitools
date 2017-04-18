#!/bin/bash

# CHANGE YOUR PASSWORD
passwd

# ofc
apt-get update
apt-get -y upgrade
pip install --upgrade pip

#32 bit headers asdfasdfasfd WHY ISNT THIS IN BY DEFAULT?!!?
apt-get -y install lib32stdc++6 libc6-i386

# exfat for usb's
apt-get -y install exfat-fuse

# ntpdate because VM's + time is hard
apt-get -y install ntpdate
ntpdate -s pool.ntp.org

# speaking of VM's, vmware tools pls
apt-get -y install open-vm-tools-desktop

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
cd /opt
git clone https://github.com/radare/radare2
cd radare2
sys/install.sh
cd ~/

#   valabind
cd /opt/
apt-get purge valabind
git clone https://github.com/radare/valabind
cd valabind
make
make install PREFIX=/usr
cd ~/
#   r2 bindings
#git clone https://github.com/radare/radare2-bindings
#cd radare2-bindings
#./configure --prefix=/usr
#cd python
#make
#make install
#cd ~/

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
echo 'deb http://http.debian.net/debian wheezy-backports main' > /etc/apt/sources.list.d/backports.list && apt-get update
apt-get -y install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo debian-wheezy main' > /etc/apt/sources.list.d/docker.list && apt-get update
apt-get -y install docker-engine docker && service docker start

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

# zsteg (rake is magic fixer of the error..ok? ruby rules)
gem install rake
gem install zsteg

# exiftool
gem install exiftool

# golang
apt-get -y install golang
cd ~/
mkdir golang
export GOPATH=~/golang/
export PATH=$PATH:$GOPATH/bin
echo "export GOPATH=~/golang/" >> .bashrc
echo "export PATH=$PATH:$GOPATH/bin" >> .bashrc

# glugger
cd ~/
go get github.com/zxsecurity/glugger

# atom
cd ~/Downloads
wget https://github.com/atom/atom/releases/download/$(curl https://github.com/atom/atom/releases/latest | cut -d / -f 8 - | cut -d \" -f 1 -)/atom-amd64.deb
dpkg --install atom-amd64.deb
rm atom-amd64.deb
cd ~/

# sublime (latest release is 2016, whatever)
cd ~/Downloads
wget https://download.sublimetext.com/sublime-text_build-3126_amd64.deb
dpkg --install sublime-text_build-3126_amd64.deb
rm sublime-text_build-3126_amd64.deb
cd ~/

# privesc
mkdir Privesc
cd Privesc
mkdir Linux
cd Linux
wget https://www.securitysift.com/download/linuxprivchecker.py
git clone https://github.com/rebootuser/LinEnum.git
git clone https://github.com/PenturaLabs/Linux_Exploit_Suggester.git
git clone https://github.com/pentestmonkey/unix-privesc-check.git
cd ..
mkdir Windows
cd Windows
git clone https://github.com/pentestmonkey/windows-privesc-check.git
git clone https://github.com/GDSSecurity/Windows-Exploit-Suggester.git
cd ~/

# sublist3r
cd /opt/
git clone https://github.com/aboul3la/Sublist3r.git
ln -s /opt/Sublist3r/sublist3r.py /usr/local/bin/sublist3r
chmod +x /opt/Sublist3r/sublist3r.py
cd ~/

# RSACtfTool (needs libnum and gmpy)
pip install gmpy
cd /opt/
git clone git clone https://github.com/hellman/libnum.git
python libnum/setup.py install
git clone https://github.com/Ganapati/RsaCtfTool.git
ln -s /opt/RsaCtfTool/RsaCtfTool.py /usr/local/bin/rsactftool
cd ~/

# gittools
cd /opt/
git clone https://github.com/internetwache/GitTools.git
ln -s /opt/GitTools/Dumper/gitdumper.sh /usr/local/bin/gitdumper
ln -s /opt/GitTools/Extractor/extractor.sh /usr/local/bin/gitextractor
ln -s /opt/GitTools/Finder/gitfinder.sh /usr/local/bin/gitfinder
cd ~/

# do the right extraction (dtrx)
apt-get -y install dtrx

# node
apt-get -y install npm nodejs

# vlan hopper (frogger)
cd /opt/
git clone https://github.com/nccgroup/vlan-hopping.git
chmod +x vlan-hopping/frogger.sh
ln -s /opt/vlan-hopping/frogger.sh /usr/local/bin/frogger

# fastcoll
cd /opt/
git clone https://github.com/upbit/clone-fastcoll.git
cd clone-fastcoll
make
ln -s /opt/clone-fastcoll/fastcoll /usr/local/bin/fastcoll
cd ~/

# figlet
apt-get -y install figlet

# dnscat2
cd /opt/
git clone https://github.com/iagox86/dnscat2.git
cd dnscat2/client/
make
ln -s $(pwd)/dnscat /usr/local/bin/dnscat
cd ~/

# apt-get autogoodcleanremove
apt-get -y autoremove
apt-get -y autoclean

# reboot because yes
reboot
