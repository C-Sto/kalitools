#!/bin/bash

# Thanks GotMilk for pretty things :D
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal
# Fix display (also from gotmilks install script)
export DISPLAY=:0.0
export TERM=xterm

##### Read command line arguments (based on the gotmilk install script)
while [[ "${#}" -gt 0 && ."${1}" == .-* ]]; do
  opt="${1}";
  shift;
  case "$(echo ${opt} | tr '[:upper:]' '[:lower:]')" in
    -|-- ) break 2;;

    -m|--mirror )
      MIRROR="${1}"; shift;;
    -m=*|--mirror=* )
      MIRROR="${opt#*=}";;
    *) echo -e ' '${RED}'[!]'${RESET}" Unknown option: ${RED}${x}${RESET}" 1>&2 \
      && exit 1;;
   esac
done

if [ ${MIRROR} ]; then
  # check for the mirror already existing in the file, indicates this has been done before..
  if grep $MIRROR /etc/apt/sources.list; then
    echo -e "${YELLOW}[!]${RESET} Mirror appears to exist in sources.list file, taking no further action"
  else
    # inevitably, something will go wrong... try to minimize the damage
    echo -e "${GREEN}[+]${RESET} Adding mirror to sources.list.."
    cp /etc/apt/sources.list /etc/apt/sources.list.backup
    sed -i -e "1ideb ftp://$MIRROR/kali kali-rolling main non-free contrib" /etc/apt/sources.list
  fi
fi

# CHANGE YOUR PASSWORD FROM TOOR PLEASE
ALG=$(cat /etc/shadow | grep "root" | cut -d \$ -f 2)
if [ "$ALG" == "6" ]; then
  SALT=$(cat /etc/shadow | grep "root" | cut -d \$ -f 3)
  HASH=$(cat /etc/shadow | grep "root" | cut -d \$ -f 4)
  HASH=$(echo $HASH | cut -d \: -f 1)
  TOORHASH=$(echo "toor" | mkpasswd -P 0 -m sha-512 -S $SALT)
  TOORHASH=$(echo $TOORHASH | cut -d \$ -f 4)
  if [ "$TOORHASH" == "$HASH" ]; then
    echo -e "${RED}[!] ROOT PASSWORD IS DEFAULT!${RESET}"
    passwd
  fi
else
  echo -e "${RED}[!] Hashing algorithm not \$6\$! Pls fix this manually. Changing password anyway${RESET}"
  passwd
fi
# unintended password disclosure is the best
ALG=
SALT=
HASH=

# ofc
echo -e "${GREEN}[+]${RESET} Apt updating, make sure nothing odd is in the output if custom mirrors are being used"
apt-get update || echo -e "${RED}[!]${RESET} apt update error!"
# hmm
#apt --fix-broken install
echo -e "${GREEN}[+]${RESET} Upgrading pip"
pip -q install --upgrade pip >> installLog.log || echo -e "${RED}[!]${RESET} pip update error!"

#32 bit headers asdfasdfasfd WHY ISNT THIS IN BY DEFAULT?!!?
echo -e "${GREEN}[+]${RESET} Installing x86 support"
apt-get -qq -y install lib32stdc++6 libc6-i386 >> installLog.log|| echo -e "${RED}[!]${RESET} Install error!"

# exfat for usb's
echo -e "${GREEN}[+]${RESET} Installing exfat-fuse"
apt-get -qq -y install exfat-fuse >> installLog.log > installLog.log >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# ntpdate because VM's + time is hard
echo -e "${GREEN}[+]${RESET} Installing ntp things"
apt-get -qq -y install ntpdate >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
ntpdate -s pool.ntp.org

# speaking of VM's, vmware tools pls
echo -e "${GREEN}[+]${RESET} Installing vmware tools"
apt-get -qq -y install open-vm-tools-desktop >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# pwntools
echo -e "${GREEN}[+]${RESET} Installing pwntools"
apt-get -qq -y install python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
pip install --upgrade pip >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
pip install --upgrade pwntools >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

#gdb-peda
echo -e "${GREEN}[+]${RESET} Installing gdb-peda"
cd /opt/
git clone https://github.com/longld/peda.git
echo "source /opt/peda/peda.py" >> ~/.gdbinit

# wireshark sux
echo -e "${GREEN}[+]${RESET} Removing, then installing wireshark again, to avoid segfault things"
apt-get -qq -y remove wireshark-common >> installLog.log || echo -e "${RED}[!]${RESET} Uninstall error!"
apt-get -qq -y install wireshark >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# get a better r2 idk if it works? https://securityblog.gr/3791/install-latest-radare2-on-kali/
echo -e "${GREEN}[+]${RESET} Getting a better r2"
apt-get -qq -y purge radare2 >> installLog.log || echo -e "${RED}[!]${RESET} Uninstall error!"
# probably should work out how to make this automatically the most recent but whatever
apt-get -qq -y install valac libvala-0.34-dev swig >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
pip install r2pipe >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
pip install --upgrade xdot >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd /opt
git clone https://github.com/radare/radare2
cd radare2
sys/install.sh >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd ~/
#   valabind
cd /opt/
apt-get purge valabind >> installLog.log || echo -e "${RED}[!]${RESET} Uninstall error!"
git clone https://github.com/radare/valabind
cd valabind
make >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
make install PREFIX=/usr >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd ~/
#   r2 bindings
git clone https://github.com/radare/radare2-bindings
cd radare2-bindings
./configure --prefix=/usr >> installLog.log || echo -e "${RED}[!]${RESET} Config error!"
cd python
make >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
make install >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd ~/

#autopsy
echo -e "${GREEN}[+]${RESET} Installing autopsy"
apt-get -qq -y install autopsy >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# caca
echo -e "${GREEN}[+]${RESET} Installing caca-utils"
apt-get -qq -y install caca-utils >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# esptool
echo -e "${GREEN}[+]${RESET} Installing esptool"
apt-get -qq -y install esptool >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# espeak
echo -e "${GREEN}[+]${RESET} Installing espeak"
apt-get -qq -y install espeak >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# virtualenv
echo -e "${GREEN}[+]${RESET} Installing virtualenv"
apt-get -qq -y install virtualenv >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# droidbox IDKLOL http://blog.dornea.nu/2014/08/05/android-dynamic-code-analysis-mastering-droidbox/
#apt-get -qq -y install python-virtualenv libatlas-dev liblapack-dev libblas-dev
#cd ~/
# apparently you have to do some env stuff? idk
#mkdir droidenv
#virtualenv droidenv
#source droidenv/bin/activate
#pip install numpy scipy matplotlib
#wget https://droidbox.googlecode.com/files/DroidBox411RC.tar.gz

# jadx
echo -e "${GREEN}[+]${RESET} Installing jadx"
cd /opt
git clone https://github.com/skylot/jadx.git
cd jadx
./gradlew dist >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# cyberchef (run with cyberchef command)
echo -e "${GREEN}[+]${RESET} Installing cyberchef"
mkdir /opt/cyberchef
wget https://gchq.github.io/CyberChef/cyberchef.htm -O /opt/cyberchef/cyberchef.htm
echo '#!/bin/bash' > /usr/local/bin/cyberchef
echo 'firefox /opt/cyberchef/cyberchef.htm' > /usr/local/bin/cyberchef
chmod +x /usr/local/bin/cyberchef

# cmatrix
echo -e "${GREEN}[+]${RESET} Installing cmatrix"
apt-get -qq -y install cmatrix >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# apktool
echo -e "${GREEN}[+]${RESET} Installing apktool"
apt-get -qq -y install apktool >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# qemu
echo -e "${GREEN}[+]${RESET} Installing qemu and friends"
apt-get -qq -y install qemu qemu-kvm qemu-system qemu-system-arm \
qemu-system-common qemu-system-mips qemu-system-ppc \
qemu-system-sparc qemu-system-x86 qemu-utils \
|| echo -e "${RED}[!]${RESET} Install error!"

# die
echo -e "${GREEN}[+]${RESET} Installing Detect it Easy (run as die)"
mkdir /opt/die
wget https://www.dropbox.com/s/7v49w3jiey9rrjm/DIE_1.01_lin64.tar.gz?dl=1 -O /opt/die/DIE1.01.tar.gz >> installLog.log || echo -e "${RED}[!]${RESET} Can't get DIE!"
tar -xf /opt/die/DIE1.01.tar.gz -C /opt/die/
ln -s /opt/die/lin64/die /usr/local/bin/

# preeny
echo -e "${GREEN}[+]${RESET} Installing preeny to homedir"
apt-get -qq -y install libini-config-dev >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd ~/
git clone https://github.com/zardus/preeny.git
cd preeny
make >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd ~/

# thefuck
echo -e "${GREEN}[+]${RESET} Installing thefuck"
apt-get -qq -y install python3-dev python3-pip >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
pip install --user thefuck >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# bro
echo -e "${GREEN}[+]${RESET} Installing bro"
apt-get -qq -y install bro >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# bless
echo -e "${GREEN}[+]${RESET} Installing bless"
apt-get -qq -y install bless >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# empire
echo -e "${GREEN}[+]${RESET} Installing empire"
apt-get -qq -y install empire >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# hob0rules
echo -e "${GREEN}[+]${RESET} Installing hob0rules"
cd ~/
mkdir hob0rules
cd hob0rules
wget https://raw.githubusercontent.com/praetorian-inc/Hob0Rules/master/d3adhob0.rule >> installLog.log || echo -e "${RED}[!]${RESET} Get error!"
wget https://raw.githubusercontent.com/praetorian-inc/Hob0Rules/master/hob064.rule >> installLog.log || echo -e "${RED}[!]${RESET} Get error!"
cd ~/

# magic wormhole
echo -e "${GREEN}[+]${RESET} Installing magic wormhole"
apt-get -qq -y install magic-wormhole >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# bloodhound
echo -e "${GREEN}[+]${RESET} Installing bloodhound"
apt-get -qq -y install apt-transport-https >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
apt-get -qq update
apt-get -qq -y install neo4j >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd ~/
git clone https://github.com/adaptivethreat/Bloodhound
# THIS SEEMS OK

#docker :rolleyes: adsfasdfsadf this is very ugly
echo -e "${GREEN}[+]${RESET} Installing docker.. hold on tight"
echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/backports.list && apt-get -qq update
apt-get -qq -y install apt-transport-https ca-certificates >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > /etc/apt/sources.list.d/docker.list && apt-get -qq update
apt-get -qq -y install docker-engine docker && service docker start

# voltron
echo -e "${GREEN}[+]${RESET} Installing voltron"
apt-get -qq -y install voltron >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# snort
echo -e "${GREEN}[+]${RESET} Installing snort"
apt-get -qq -y install snort >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# yara
echo -e "${GREEN}[+]${RESET} Installing yara"
apt-get -qq -y install yara >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

#ltrace
echo -e "${GREEN}[+]${RESET} Installing ltrace"
apt-get -qq -y install ltrace >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# cowsay
echo -e "${GREEN}[+]${RESET} Installing cowsay"
apt-get -qq -y install cowsay >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# irssi
echo -e "${GREEN}[+]${RESET} Installing irssi"
apt-get -qq -y install irssi >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# lynx
echo -e "${GREEN}[+]${RESET} Installing lynx"
apt-get -qq -y install lynx >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# beef
echo -e "${GREEN}[+]${RESET} Installing beef"
apt-get -qq -y install beef >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# afl
echo -e "${GREEN}[+]${RESET} Installing afl"
apt-get -qq -y install afl >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# gimp
echo -e "${GREEN}[+]${RESET} Installing gimp"
apt-get -qq -y install gimp >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# masscan
echo -e "${GREEN}[+]${RESET} Installing masscan"
apt-get -qq -y install masscan >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# unicorn
echo -e "${GREEN}[+]${RESET} Installing unicorn"
apt-get -qq -y install unicornscan >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# audacity
echo -e "${GREEN}[+]${RESET} Installing audacity"
apt-get -qq -y install audacity >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# responder
echo -e "${GREEN}[+]${RESET} Installing responder"
apt-get -qq -y install responder >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# sshuttle
echo -e "${GREEN}[+]${RESET} Installing sshuttle"
apt-get -qq -y install sshuttle >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# zsteg (rake is magic fixer of the error..ok? ruby rules)
echo -e "${GREEN}[+]${RESET} Installing zsteg"
gem install rake >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
gem install zsteg >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# exiftool
echo -e "${GREEN}[+]${RESET} Installing exiftool"
apt install exiftool >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# golang
echo -e "${GREEN}[+]${RESET} Installing golang, and setting up environment in homedir/golang"
apt-get -qq -y install golang >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd ~/
mkdir golang
export GOPATH=~/golang/
export PATH=$PATH:$GOPATH/bin
echo "export GOPATH=~/golang/" >> .bashrc
echo "export PATH=$PATH:$GOPATH/bin" >> .bashrc

# glugger
echo -e "${GREEN}[+]${RESET} Installing glugger"
cd ~/
go get github.com/zxsecurity/glugger >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# atom
echo -e "${GREEN}[+]${RESET} Installing atom (the best text editor)"
cd ~/Downloads
wget https://github.com/atom/atom/releases/download/$(curl https://github.com/atom/atom/releases/latest | cut -d / -f 8 - | cut -d \" -f 1 -)/atom-amd64.deb
dpkg --install atom-amd64.deb >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
rm atom-amd64.deb
cd ~/

# sublime (latest release is 2016, whatever)
echo -e "${GREEN}[+]${RESET} Installing sublime (the inferior text editor)"
cd ~/Downloads
wget https://download.sublimetext.com/sublime-text_build-3126_amd64.deb
dpkg --install sublime-text_build-3126_amd64.deb >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
rm sublime-text_build-3126_amd64.deb
cd ~/

# privesc
echo -e "${GREEN}[+]${RESET} Getting privesc scripts, storing in homedir/Privesc"
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
echo -e "${GREEN}[+]${RESET} Installing sublist3r"
cd /opt/
git clone https://github.com/aboul3la/Sublist3r.git
ln -s /opt/Sublist3r/sublist3r.py /usr/local/bin/sublist3r
chmod +x /opt/Sublist3r/sublist3r.py
cd ~/

# RSACtfTool (needs libnum and gmpy)
echo -e "${GREEN}[+]${RESET} Installing RSACtfTool"
pip install gmpy >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd /opt/
git clone git clone https://github.com/hellman/libnum.git
python libnum/setup.py install >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
git clone https://github.com/Ganapati/RsaCtfTool.git
ln -s /opt/RsaCtfTool/RsaCtfTool.py /usr/local/bin/rsactftool
cd ~/

# gittools
echo -e "${GREEN}[+]${RESET} Installing gittools (gitdumper, gitextractor, gitfinder)"
cd /opt/
git clone https://github.com/internetwache/GitTools.git
ln -s /opt/GitTools/Dumper/gitdumper.sh /usr/local/bin/gitdumper
ln -s /opt/GitTools/Extractor/extractor.sh /usr/local/bin/gitextractor
ln -s /opt/GitTools/Finder/gitfinder.sh /usr/local/bin/gitfinder
cd ~/

# do the right extraction (dtrx)
echo -e "${GREEN}[+]${RESET} Installing dtrx"
apt-get -qq -y install dtrx >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# node
echo -e "${GREEN}[+]${RESET} Installing node (lol)"
apt-get -qq -y install npm nodejs >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# vlan hopper (frogger)
echo -e "${GREEN}[+]${RESET} Installing frogger/vlan hopper (use as frogger)"
cd /opt/
git clone https://github.com/nccgroup/vlan-hopping.git
chmod +x vlan-hopping/frogger.sh
ln -s /opt/vlan-hopping/frogger.sh /usr/local/bin/frogger

# fastcoll
echo -e "${GREEN}[+]${RESET} Installing fastcoll (the good one)"
cd /opt/
git clone https://github.com/upbit/clone-fastcoll.git
cd clone-fastcoll
make >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
ln -s /opt/clone-fastcoll/fastcoll /usr/local/bin/fastcoll
cd ~/

# figlet
echo -e "${GREEN}[+]${RESET} Installing figlet"
apt-get -qq -y install figlet >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# dnscat2
echo -e "${GREEN}[+]${RESET} Installing dnscat2"
cd /opt/
git clone https://github.com/iagox86/dnscat2.git
cd dnscat2/client/
make >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
ln -s $(pwd)/dnscat /usr/local/bin/dnscat
cd ~/

# factordb
echo -e "${GREEN}[+]${RESET} Installing factordb cli"
pip install factordb-pycli >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# tcpxtract
echo -e "${GREEN}[+]${RESET} Installing tcpxtract"
apt-get install tcpxtract >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# foresight (rng prediction)
echo -e "${GREEN}[+]${RESET} Installing foresight"
cd /opt/
git clone https://github.com/ALSchwalm/foresight.git
cd foresight
python setup.py install >> installLog.log || echo -e "${RED}[!]${RESET} Install error!"
cd ~/

# sysinternals
echo -e "${GREEN}[+]${RESET} Getting sysinternals suite, storing with other windows binaries"
cd /usr/share/windows-binaries
wget https://download.sysinternals.com/files/SysinternalsSuite.zip
dtrx -n SysinternalsSuite.zip
rm SysinternalsSuite.zip

echo -e "${GREEN}[+]${RESET} Upgrading any leftovers.."
apt-get -qq -y upgrade

# apt-get autogoodcleanremove
echo -e "${GREEN}[+]${RESET} autoremoving, autocleaning, rebooting"
apt-get -qq -y autoremove
apt-get -qq -y autoclean

# reboot because yes
reboot
