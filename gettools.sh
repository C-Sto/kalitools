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
# Make headless for automated goodness (thanks pritch)
export DEBIAN_FRONTEND=noninteractive

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
    -s|--sage )
      SAGE="${1}"; shift;;
    -s=*|--sage=* )
      SAGE="${opt#*=}";;
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
    echo -e "$(date '+%X') ${GREEN}[+]${RESET} Adding mirror to sources.list.."
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
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Apt updating, make sure nothing odd is in the output if custom mirrors are being used"
apt-get update || echo -e "${RED}[!]${RESET} apt update error!"
# hmm
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Upgrading pip"
pip -q install --upgrade pip >> ~/installLog.log || echo -e "${RED}[!]${RESET} pip update error!"

# node
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing node (lol)"
curl -sL https://deb.nodesource.com/setup_7.x | bash - >> ~/installLog.log
apt-get -qq install -y nodejs >> ~/installLog.log || echo -e "${RED}[!]${RESET} Node Install error!"

# wireshark sux
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Removing, then installing wireshark again, to avoid segfault things"
apt-get -qq -y purge wireshark-common >> ~/installLog.log && apt-get -qq -y install wireshark >> ~/installLog.log || echo -e "${RED}[!]${RESET} Wireshark uninstall error!"

#32 bit headers, snort and wireshark - interactive,  asdfasdfasfd WHY ISNT THIS IN BY DEFAULT?!!?
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing x86 support"
apt-get -qq -y install lib32stdc++6 libc6-i386 >> ~/installLog.log || echo -e "${RED}[!]${RESET} Headers Install error!"

# exfat for usb's
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing exfat-fuse"
apt-get -qq -y install exfat-fuse >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# ntpdate because VM's + time is hard
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing ntp things"
apt-get -qq -y install ntpdate >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
ntpdate -s pool.ntp.org

# speaking of VM's, vmware tools pls
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing vmware tools"
apt-get -qq -y install open-vm-tools-desktop >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# pwntools
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing pwntools"
apt-get -qq -y install python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
pip -q install --upgrade pip >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
pip -q install --upgrade pwntools >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

#gdb-peda
if [ -e /opt/peda ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} Peda installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing gdb-peda"
  cd /opt/
  git clone -q https://github.com/longld/peda.git >> ~/installLog.log && echo "source /opt/peda/peda.py" >> ~/.gdbinit || echo -e "${RED}[!]${RESET} Install error!"
  cd ~/
fi

# get a better r2 idk if it works? https://securityblog.gr/3791/install-latest-radare2-on-kali/
if [ -e /opt/radare2-bindings ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} Good r2 installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Getting a better r2"
  apt-get -qq -y purge radare2 >> ~/installLog.log || echo -e "${RED}[!]${RESET} Uninstall error!"
  # probably should work out how to make this automatically the most recent but whatever
  apt-get -qq -y install valac libvala-0.34-dev swig >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  pip -q install r2pipe >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  pip -q install --upgrade xdot >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd /opt
  git clone -q https://github.com/radare/radare2
  cd radare2
  # &> directs _all_ output into the log, no errors will show (tons of build stuff is spewed out, so this is good to keep it clean)
  sys/install.sh &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd ~/
  #   valabind
  cd /opt/
  apt-get purge valabind >> ~/installLog.log || echo -e "${RED}[!]${RESET} Uninstall error!"
  git clone -q https://github.com/radare/valabind
  cd valabind
  make -s &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  make -s install PREFIX=/usr &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd ~/
  #   r2 bindings
  cd /opt
  git clone -q https://github.com/radare/radare2-bindings
  cd radare2-bindings
  ./configure --prefix=/usr >> ~/installLog.log || echo -e "${RED}[!]${RESET} Config error!"
  cd python
  make -s &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  make -s install &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd ~/
fi

#autopsy
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing autopsy"
apt-get -qq -y install autopsy >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# caca
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing caca-utils"
apt-get -qq -y install caca-utils >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# esptool
if [ -e /opt/esptool ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} cyberchef installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing esptool"
  cd /opt/
  git clone -q https://github.com/espressif/esptool.git >> ~/installLog.log
  cd esptool
  python setup.py install >> ~/installLog.log 2>>installLog.log || echo -e "${RED}[!]${RESET} ESPTool install error!"
fi

# espeak
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing espeak"
apt-get -qq -y install espeak >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# virtualenv
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing virtualenv"
apt-get -qq -y install virtualenv >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

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
if [ -e /opt/jadx ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} jadx installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing jadx"
  cd /opt
  git clone -q https://github.com/skylot/jadx.git >> ~/installLog.log
  cd jadx
  ./gradlew dist &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
fi

# cyberchef (run with cyberchef command)
if [ -e /usr/local/bin/cyberchef ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} cyberchef installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing cyberchef"
  mkdir /opt/cyberchef
  wget -q --show-progress https://gchq.github.io/CyberChef/cyberchef.htm -O /opt/cyberchef/cyberchef.htm
  echo '#!/bin/bash' > /usr/local/bin/cyberchef
  echo 'firefox /opt/cyberchef/cyberchef.htm' > /usr/local/bin/cyberchef
  chmod +x /usr/local/bin/cyberchef
fi

# cmatrix
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing cmatrix"
apt-get -qq -y install cmatrix >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# apktool
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing apktool"
apt-get -qq -y install apktool >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# qemu
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing qemu and friends"
apt-get -qq -y install qemu qemu-kvm qemu-system qemu-system-arm \
qemu-system-common qemu-system-mips qemu-system-ppc \
qemu-system-sparc qemu-system-x86 qemu-utils &> ~/installLog.log\
|| echo -e "${RED}[!]${RESET} Install error!"

# die
if [ -e /usr/local/bin/die ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} die installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing Detect it Easy (run as die)"
  mkdir /opt/die
  wget -q --show-progress https://www.dropbox.com/s/7v49w3jiey9rrjm/DIE_1.01_lin64.tar.gz?dl=1 -O /opt/die/DIE1.01.tar.gz || echo -e "${RED}[!]${RESET} Can't get DIE!"
  tar -xf /opt/die/DIE1.01.tar.gz -C /opt/die/
  ln -s /opt/die/lin64/die /usr/local/bin/
fi

# preeny
if [ -e ~/preeny ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} preeny installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing preeny to homedir"
  apt-get -qq -y install libini-config-dev >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd ~/
  git clone -q https://github.com/zardus/preeny.git >> ~/installLog.log
  cd preeny
  make -s >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd ~/
fi

# thefuck
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing thefuck"
apt-get -qq -y install python3-dev python3-pip >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
pip3 -q install --user thefuck >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
echo "eval $(thefuck --alias)" >> ~/.bashrc
source ~/.bashrc

# bro
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing bro"
apt-get -qq -y install bro >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# bless
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing bless"
apt-get -qq -y install bless >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# empire
if [ -e /usr/local/bin/empire ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} Empire installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing Empire"
  cd /opt/
  git clone https://github.com/EmpireProject/Empire.git &> ~/installLog.log
  cd Empire
  cd setup
  echo | bash install.sh &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd ~/
  cat > /usr/local/bin/empire << EOF
#!/bin/bash
cd /opt/Empire && ./empire
EOF
  chmod +x /usr/local/bin/empire
fi

# hob0rules
if [ -e ~/hob0rules ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} hob0rules installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing hob0rules"
  cd ~/
  mkdir hob0rules
  cd hob0rules
  wget -q --show-progress https://raw.githubusercontent.com/praetorian-inc/Hob0Rules/master/d3adhob0.rule || echo -e "${RED}[!]${RESET} Get error!"
  wget -q --show-progress https://raw.githubusercontent.com/praetorian-inc/Hob0Rules/master/hob064.rule || echo -e "${RED}[!]${RESET} Get error!"
  cd ~/
fi

# magic wormhole
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing magic wormhole"
apt-get -qq -y install magic-wormhole >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# bloodhound
if [ -e ~/Bloodhound ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} bloodhound installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing bloodhound"
  npm install -g electron-packager || echo -e "${RED}[!]${RESET} electron-packager Install error!"
  git clone https://github.com/adaptivethreat/Bloodhound
  cd Bloodhound
  npm install || echo -e "${RED}[!]${RESET} Bloodhound install error!"
  npm run linuxbuild || echo -e "${RED}[!]${RESET} Bloodhound build error!"
  # THIS SEEMS OK
fi

#docker :rolleyes: adsfasdfsadf this is very ugly
if [ -e /etc/apt/sources.list.d/docker.list ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} docker installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing docker.. hold on tight"
  apt-get -qq -y install apt-transport-https \
      ca-certificates software-properties-common \
      curl apt-transport-https >> ~/installLog.log
  sudo echo \
    "deb [arch=amd64] \
    https://download.docker.com/linux/debian \
    stretch stable" > \
    /etc/apt/sources.list.d/docker.list >> ~/installLog.log || echo -e "${RED}[!]${RESET} Docker install error!"
  apt-get update >> ~/installLog.log || echo -e "${RED}[!]${RESET} Docker install error!"
  apt-get -qq -y install docker-ce >> ~/installLog.log && service docker start  || echo -e "${RED}[!]${RESET} Docker install error!"
fi

# voltron
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing voltron"
apt-get -qq -y install voltron >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# yara
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing yara"
apt-get -qq -y install yara >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

#ltrace
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing ltrace"
apt-get -qq -y install ltrace >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# cowsay
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing cowsay"
apt-get -qq -y install cowsay >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# irssi
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing irssi"
apt-get -qq -y install irssi >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# lynx
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing lynx"
apt-get -qq -y install lynx >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# beef
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing beef"
apt-get -qq -y install beef >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# afl
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing afl"
apt-get -qq -y install afl >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# gimp
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing gimp"
apt-get -qq -y install gimp >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# masscan
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing masscan"
apt-get -qq -y install masscan >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# unicorn
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing unicorn"
apt-get -qq -y install unicornscan >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# audacity
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing audacity"
apt-get -qq -y install audacity >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# responder
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing responder"
apt-get -qq -y install responder >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# sshuttle
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing sshuttle"
apt-get -qq -y install sshuttle >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# zsteg (rake is magic fixer of the error..ok? ruby rules)
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing zsteg"
gem install rake >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
gem install zsteg >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# exiftool
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing exiftool"
apt-get -q -y install exiftool >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# golang
if [ -e ~/golang ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} golang installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing golang, and setting up environment in homedir/golang"
  apt-get -qq -y install golang >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd ~/
  mkdir golang
  export GOPATH=~/golang
  export PATH=$PATH:$GOPATH/bin
  echo "export GOPATH=~/golang" >> .bashrc
  echo "export PATH=$PATH:$GOPATH/bin" >> .bashrc
fi

# glugger
if [ -e /root/golang/bin/gluggerl ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} glugger installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing glugger"
  cd ~/
  go get github.com/zxsecurity/glugger >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
fi

# atom
if [ -e /usr/bin/atom ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} atom installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing atom (the best text editor)"
  cd ~/Downloads
  apt-get -qq -y install gvfs-bin >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  wget -q --show-progress https://github.com/atom/atom/releases/download/$(curl -s https://github.com/atom/atom/releases/latest | cut -d / -f 8 - | cut -d \" -f 1 -)/atom-amd64.deb
  dpkg --install atom-amd64.deb >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  rm atom-amd64.deb
  cd ~/
fi

# sublime (latest release is 2016, whatever)
if [ -e /usr/bin/subl ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} sublime installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing sublime (the inferior text editor)"
  cd ~/Downloads
  wget -q --show-progress https://download.sublimetext.com/sublime-text_build-3126_amd64.deb
  dpkg --install sublime-text_build-3126_amd64.deb >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  rm sublime-text_build-3126_amd64.deb
  cd ~/
fi

# privesc
if [ -e ~/Privesc ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} privesc scripts installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Getting privesc scripts, storing in homedir/Privesc"
  cd ~/
  mkdir Privesc
  cd Privesc
  mkdir Linux
  cd Linux
  wget -q --show-progress https://www.securitysift.com/download/linuxprivchecker.py
  git clone -q https://github.com/rebootuser/LinEnum.git >> ~/installLog.log
  git clone -q https://github.com/fozzysac/linuxprivesc >> ~/installLog.log && python ./linuxprivesc/setup.py install
  git clone -q https://github.com/PenturaLabs/Linux_Exploit_Suggester.git >> ~/installLog.log
  git clone -q https://github.com/pentestmonkey/unix-privesc-check.git >> ~/installLog.log
  cd ..
  mkdir Windows
  cd Windows
  git clone -q https://github.com/pentestmonkey/windows-privesc-check.git >> ~/installLog.log
  git clone -q https://github.com/GDSSecurity/Windows-Exploit-Suggester.git >> ~/installLog.log
  cd ~/
fi

# sublist3r
if [ -e /usr/local/bin/sublist3r ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} sublist3r installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing sublist3r"
  cd /opt/
  git clone -q https://github.com/aboul3la/Sublist3r.git >> ~/installLog.log
  ln -s /opt/Sublist3r/sublist3r.py /usr/local/bin/sublist3r
  chmod +x /opt/Sublist3r/sublist3r.py
  cd ~/
fi

# gittools
if [ -e /usr/local/bin/gitdumper ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} gittools installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing gittools (gitdumper, gitextractor, gitfinder)"
  cd /opt/
  git clone -q https://github.com/internetwache/GitTools.git >> ~/installLog.log
  ln -s /opt/GitTools/Dumper/gitdumper.sh /usr/local/bin/gitdumper
  ln -s /opt/GitTools/Extractor/extractor.sh /usr/local/bin/gitextractor
  ln -s /opt/GitTools/Finder/gitfinder.sh /usr/local/bin/gitfinder
  cd ~/
fi

# do the right extraction (dtrx)
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing dtrx"
apt-get -qq -y install dtrx >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# vlan hopper (frogger)
if [ -e /usr/local/bin/frogger ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} frogger installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing frogger/vlan hopper (use as frogger)"
  cd /opt/
  git clone -q https://github.com/nccgroup/vlan-hopping.git >> ~/installLog.log
  chmod +x vlan-hopping/frogger.sh
  ln -s /opt/vlan-hopping/frogger.sh /usr/local/bin/frogger
fi

# fastcoll
if [ -e /usr/local/bin/fastcoll ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} fastcoll installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing fastcoll (the good one)"
  cd /opt/
  git clone -q https://github.com/upbit/clone-fastcoll.git >> ~/installLog.log
  cd clone-fastcoll
  make -s >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  ln -s /opt/clone-fastcoll/fastcoll /usr/local/bin/fastcoll
  cd ~/
fi

# figlet
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing figlet"
apt-get -qq -y install figlet >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# dnscat2
if [ -e /usr/local/bin/dnscat ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} dnscat installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing dnscat2"
  cd /opt/
  git clone -q https://github.com/iagox86/dnscat2.git >> ~/installLog.log
  cd dnscat2/client/
  make -s &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  ln -s $(pwd)/dnscat /usr/local/bin/dnscat
  cd ~/
fi

# factordb
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing factordb cli"
pip install factordb-pycli >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# tcpxtract
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing tcpxtract"
apt-get -qq -y install tcpxtract >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"

# RSACtfTool (needs libnum and gmpy)
if [ -e /usr/local/bin/rsactftool ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} rsactftool installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing RSACtfTool"
  pip -q install gmpy >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd /opt/
  git clone -q https://github.com/hellman/libnum.git >> ~/installLog.log
  cd libnum
  python setup.py install >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!"
  cd /opt/
  git clone -q https://github.com/Ganapati/RsaCtfTool.git >> ~/installLog.log
  ln -s /opt/RsaCtfTool/RsaCtfTool.py /usr/local/bin/rsactftool
  cd ~/
fi

# sysinternals
if [ -e /usr/share/windows-binaries/SysinternalsSuite ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} sysinternals installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Getting sysinternals suite, storing with other windows binaries"
  cd /usr/share/windows-binaries
  wget -q --show-progress https://download.sysinternals.com/files/SysinternalsSuite.zip
  dtrx -n SysinternalsSuite.zip
  rm SysinternalsSuite.zip
  cd ~/
fi

# sage
# we don't want to re-install if it's already installed, 1.2gb download is kinda brutal
if [ ${SAGE} ]; then
  if [ -e /usr/local/bin/sage ]; then
    echo "$(date '+%X') ${YELLOW}[+]${RESET} Sage installed already"
  else
    echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing sage... this may take a while!"
    wget -q --show-progress http://mirror.aarnet.edu.au/pub/sage/linux/64bit/sage-7.6-Debian_GNU_Linux_8-x86_64.tar.bz2
    tar jxf sage-7.6-Debian_GNU_Linux_8-x86_64.tar.bz2
    mv SageMath/ /opt/
    rm sage*
    ln -s /opt/SageMath/sage /usr/local/bin/sage
  fi
fi

# dnsmasq
apt-get -qq -y install dnsmasq >> ~/installLog.log

#angr
if [ -e /usr/local/bin/angr ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} Sage installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing angr..."
  docker pull angr/angr
  cat > /usr/local/bin/angr << EOF
#!/bin/bash
docker run -it angr/angr
EOF
  chmod +x /usr/local/bin/angr
fi

echo -e "$(date '+%X') ${GREEN}[+]${RESET} Upgrading any leftovers.."
echo "[+] Upgrading leftovers" >> ~/installLog.log
apt-get -qq -y upgrade  >> ~/installLog.log || echo -e "${RED}[!]${RESET} Upgrade error!"

# apt-get autogoodcleanremove
echo -e "$(date '+%X') ${GREEN}[+]${RESET} autoremoving, autocleaning, rebooting"
apt-get -qq -y autoremove
apt-get -qq -y autoclean

# reboot because yes
#reboot
