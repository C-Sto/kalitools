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
echo -e "$(date '+%X') ${BLUE}BLOCKING${GREEN}[+]${RESET} Apt updating, make sure nothing odd is in the output if custom mirrors are being used"
apt-get update || echo -e "${RED}[!]${RESET} apt update error!" 2> error1.log
#node lol
curl -sL https://deb.nodesource.com/setup_7.x | bash -
# hmm
echo -e "$(date '+%X') ${BLUE}BLOCKING${GREEN}[+]${RESET} Upgrading pip"
pip -q install --upgrade pip >> ~/installLog.log || echo -e "${RED}[!]${RESET} pip update error!" 2> error2.log

#gdb-peda
echo -e $(
if [ -e /opt/peda ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} Peda installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing gdb-peda"
  cd /opt/
  git clone -q https://github.com/longld/peda.git >> ~/installLog.log && echo "source /opt/peda/peda.py" >> ~/.gdbinit || echo -e "${RED}[!]${RESET} Install error!" 2> error3.log
  cd ~/
fi
) &

# esptool
echo $(
if [ -e /opt/esptool ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} esptool installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing esptool"
  cd /opt/
  git clone https://github.com/espressif/esptool.git
  cd esptool
  python setup.py install
fi
) &

# jadx
echo -e $(
if [ -e /opt/jadx ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} jadx installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing jadx"
  cd /opt
  git clone -q https://github.com/skylot/jadx.git >> ~/installLog.log
  cd jadx
  ./gradlew dist &> ~/installLog.log || echo -e "${RED}[!]${RESET} jadx Install error!" 2> error4.log
fi
) &

# cyberchef (run with cyberchef command)
echo -e $(
if [ -e /usr/local/bin/cyberchef ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} cyberchef installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing cyberchef"
  mkdir /opt/cyberchef
  wget -q https://gchq.github.io/CyberChef/cyberchef.htm -O /opt/cyberchef/cyberchef.htm
  echo '#!/bin/bash' > /usr/local/bin/cyberchef
  echo 'firefox /opt/cyberchef/cyberchef.htm' > /usr/local/bin/cyberchef
  chmod +x /usr/local/bin/cyberchef
fi
) &

# empire
echo -e $(
if [ -e /usr/local/bin/empire ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} Empire installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing Empire"
  cd /opt/
  git clone https://github.com/EmpireProject/Empire.git &> ~/installLog.log
  cd Empire
  cd setup
  echo | bash install.sh &> ~/installLog.log || echo -e "${RED}[!]${RESET} Empire Install error!" 2> error5.log
  cd ~/
  cat > /usr/local/bin/empire << EOF
#!/bin/bash
cd /opt/Empire && ./empire
EOF
  chmod +x /usr/local/bin/empire
fi
) &

# die
echo -e $(
if [ -e /usr/local/bin/die ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} die installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing Detect it Easy (run as die)"
  mkdir /opt/die
  wget -q https://www.dropbox.com/s/7v49w3jiey9rrjm/DIE_1.01_lin64.tar.gz?dl=1 -O /opt/die/DIE1.01.tar.gz || echo -e "${RED}[!]${RESET} Can't get DIE!"
  tar -xf /opt/die/DIE1.01.tar.gz -C /opt/die/
  ln -s /opt/die/lin64/die /usr/local/bin/
fi
) &

# hob0rules
echo -e $(
if [ -e ~/hob0rules ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} hob0rules installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing hob0rules"
  cd ~/
  mkdir hob0rules
  cd hob0rules
  wget -q --show-progress https://raw.githubusercontent.com/praetorian-inc/Hob0Rules/master/d3adhob0.rule || echo -e "${RED}[!]${RESET} Get error!" 2> error6.log
  wget -q --show-progress https://raw.githubusercontent.com/praetorian-inc/Hob0Rules/master/hob064.rule || echo -e "${RED}[!]${RESET} Get error!" 2> error7.log
  cd ~/
fi
) &

# sublist3r
echo -e $(
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
) &

# privesc
echo -e $(
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
) &

# gittools
echo -e $(
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
) &

# vlan hopper (frogger)
echo -e $(
if [ -e /usr/local/bin/frogger ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} frogger installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing frogger/vlan hopper (use as frogger)"
  cd /opt/
  git clone -q https://github.com/nccgroup/vlan-hopping.git >> ~/installLog.log
  chmod +x vlan-hopping/frogger.sh
  ln -s /opt/vlan-hopping/frogger.sh /usr/local/bin/frogger
fi
) &

# fastcoll
echo -e $(
if [ -e /usr/local/bin/fastcoll ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} fastcoll installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing fastcoll (the good one)"
  cd /opt/
  git clone -q https://github.com/upbit/clone-fastcoll.git >> ~/installLog.log
  cd clone-fastcoll
  make -s >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error9.log
  ln -s /opt/clone-fastcoll/fastcoll /usr/local/bin/fastcoll
  cd ~/
fi
) &

# dnscat2
echo -e $(
if [ -e /usr/local/bin/dnscat ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} dnscat installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing dnscat2"
  cd /opt/
  git clone -q https://github.com/iagox86/dnscat2.git >> ~/installLog.log
  cd dnscat2/client/
  make -s &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error10.log
  ln -s $(pwd)/dnscat /usr/local/bin/dnscat
  cd ~/
fi
) &

# RSACtfTool (needs libnum and gmpy)
echo -e $(
if [ -e /usr/local/bin/rsactftool ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} rsactftool installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing RSACtfTool"
  pip -q install gmpy >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error11.log
  cd /opt/
  git clone -q https://github.com/hellman/libnum.git >> ~/installLog.log
  cd libnum
  python setup.py install >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error12.log
  cd /opt/
  git clone -q https://github.com/Ganapati/RsaCtfTool.git >> ~/installLog.log
  ln -s /opt/RsaCtfTool/RsaCtfTool.py /usr/local/bin/rsactftool
  cd ~/
fi
) &

# sysinternals
echo -e $(
if [ -e /usr/share/windows-binaries/SysinternalsSuite ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} sysinternals installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Getting sysinternals suite, storing with other windows binaries"
  cd /usr/share/windows-binaries
  mkdir SysinternalsSuite
  cd SysinternalsSuite
  wget -q https://download.sysinternals.com/files/SysinternalsSuite.zip
  unzip SysinternalsSuite.zip
  rm SysinternalsSuite.zip
  cd ~/
fi
) &

# sage
echo -e $(
# we don't want to re-install if it's already installed, 1.2gb download is kinda brutal
if [ -e /usr/usr/local/bin/sage ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} Sage installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing sage... this may take a while!"
  wget -q --show-progress http://mirror.aarnet.edu.au/pub/sage/linux/64bit/sage-7.6-Debian_GNU_Linux_8-x86_64.tar.bz2
  tar jxf sage-7.6-Debian_GNU_Linux_8-x86_64.tar.bz2
  mv SageMath/ /opt/
  rm sage*
  ln -s /opt/SageMath/sage /usr/local/bin/sage
fi
) &

#factordb
pip install factordb-pycli &

# pwntools
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing pwntools"
pip -q install --upgrade pwntools &

# purging
echo -e "$(date '+%X') ${BLUE}BLOCKING${GREEN}[+]${RESET} Purging"
apt-get -qq -y purge wireshark-common radare2 valabind >> ~/installLog.log || echo -e "${RED}[!]${RESET} Uninstall error!" 2> error13.log

# Stuff that is deps
echo -e "$(date '+%X') ${BLUE}BLOCKING ${GREEN}[+]${RESET} Apt thingsing.."
apt-get -qq -y install dtrx nodejs figlet tcpxtract golang gvfs-bin libini-config-dev python3-dev python3-pip bro \
python2.7 python-pip python-dev git libssl-dev valac libvala-0.34-dev swig \
cowsay irssi lynx beef afl gimp masscan unicornscan audacity responder sshuttle exiftool \
bless magic-wormhole apt-transport-https qemu-system-arm ltrace yara voltron \
libffi-dev build-essential cmatrix apktool qemu qemu-kvm qemu-system  \
qemu-system-common qemu-system-mips qemu-system-ppc qemu-system-sparc \
qemu-system-x86 qemu-utils ntpdate virtualenv espeak autopsy caca-utils \
open-vm-tools-desktop exfat-fuse lib32stdc++6 libc6-i386 wireshark dnsmasq \
|| touch error14.log
ntpdate -s pool.ntp.org &

# get a better r2 idk if it works? https://securityblog.gr/3791/install-latest-radare2-on-kali/
echo -e $(
if [ -e /opt/radare2-bindings ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} Good r2 installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Getting a better r2"
  # probably should work out how to make this automatically the most recent but whatever
  pip -q install r2pipe >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error15.log
  pip -q install --upgrade xdot >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error16.log
  cd /opt
  git clone -q https://github.com/radare/radare2
  cd radare2
  # &> directs _all_ output into the log, no errors will show (tons of build stuff is spewed out, so this is good to keep it clean)
  sys/install.sh &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error17.log
  cd ~/
  #   valabind
  cd /opt/
  git clone -q https://github.com/radare/valabind
  cd valabind
  make -s &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error18.log
  make -s install PREFIX=/usr &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error19.log
  cd ~/
  #   r2 bindings
  cd /opt
  git clone -q https://github.com/radare/radare2-bindings
  cd radare2-bindings
  ./configure --prefix=/usr >> ~/installLog.log || echo -e "${RED}[!]${RESET} Config error!" 2> error20.log
  cd python
  make -s &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error21.log
  make -s install &> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error22.log
  cd ~/
fi
) &

# golang ( has deps)
echo -e $(
if [ -e ~/golang ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} golang installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing golang, and setting up environment in homedir/golang"
  cd ~/
  mkdir golang
  export GOPATH=~/golang
  export PATH=$PATH:$GOPATH/bin
  echo "export GOPATH=~/golang" >> .bashrc
  echo "export PATH=$PATH:$GOPATH/bin" >> .bashrc
fi

# glugger (requires go, duh)
if [ -e /root/golang/bin/gluggerl ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} glugger installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing glugger"
  cd ~/
  go get github.com/zxsecurity/glugger >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error8.log
fi

) &

# preeny (has dep)
echo -e $(
if [ -e ~/preeny ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} preeny installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing preeny to homedir"
  cd ~/
  git clone -q https://github.com/zardus/preeny.git >> ~/installLog.log
  cd preeny
  make -s >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error23.log
  cd ~/
fi
) &

# thefuck ( has dep )
echo -e $(
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing thefuck"
pip3 -q install --user thefuck >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error24.log
echo "eval $(thefuck --alias)" >> ~/.bashrc
source ~/.bashrc
) &

# bloodhound ( Has deps, blocks )
echo -e $(
if [ -e ~/Bloodhound ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} bloodhound installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing bloodhound"
  npm install -g electron-packager
  git clone https://github.com/adaptivethreat/Bloodhound
  cd Bloodhound
  npm install
  npm run linuxbuild
  # THIS SEEMS OK
fi

#docker :rolleyes: adsfasdfsadf this is very ugly
if [ -e /etc/apt/sources.list.d/docker.list ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} docker installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing docker.. hold on tight"
  echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/backports.list && apt-get -qq update
  apt-get -qq -y install apt-transport-https ca-certificates >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error26.log
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > /etc/apt/sources.list.d/docker.list && apt-get -qq update
  apt-get -qq --allow-unauthenticated -y install docker-engine docker >> ~/installLog.log && service docker start || echo -e "${RED}[!]${RESET} Install error!" 2> error27.log
fi

#angr (must come after docker )
echo -e $(
if [ -e /usr/local/bin/angr ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} angr installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing angr..."
  docker run -it angr/angr
  cat > /usr/local/bin/angr << EOF
#!/bin/bash
docker run -it angr/angr
EOF
chmod +x /usr/local/bin/angr
fi
) &

# sublime (latest release is 2016, whatever) (must not be run at same time as apt)
if [ -e /usr/bin/subl ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} sublime installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing sublime (the inferior text editor)"
  cd ~/Downloads
  wget -q --show-progress https://download.sublimetext.com/sublime-text_build-3126_amd64.deb
  dpkg --install sublime-text_build-3126_amd64.deb >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error29.log
  rm sublime-text_build-3126_amd64.deb
  cd ~/
fi
# atom ( has deps )
if [ -e /usr/bin/atom ]; then
  echo "$(date '+%X') ${YELLOW}[+]${RESET} atom installed already"
else
  echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing atom (the best text editor)"
  cd ~/Downloads
  wget -q --show-progress https://github.com/atom/atom/releases/download/$(curl -s https://github.com/atom/atom/releases/latest | cut -d / -f 8 - | cut -d \" -f 1 -)/atom-amd64.deb
  dpkg --install atom-amd64.deb >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error1.log
  rm atom-amd64.deb
  cd ~/
fi

echo -e "$(date '+%X') ${GREEN}[+]${RESET} Upgrading any leftovers.."
apt-get -qq -y upgrade || echo -e "${RED}[!]${RESET} Upgrade error!" 2> error30.log

# apt-get autogoodcleanremove
echo -e "$(date '+%X') ${GREEN}[+]${RESET} autoremoving, autocleaning, rebooting"
apt-get -qq -y autoremove
apt-get -qq -y autoclean
) &

# zsteg (rake is magic fixer of the error..ok? ruby rules)
echo -e "$(date '+%X') ${GREEN}[+]${RESET} Installing zsteg"
echo -e $(gem install rake && gem install zsteg) & >> ~/installLog.log || echo -e "${RED}[!]${RESET} Install error!" 2> error28.log

# reboot because yes
#reboot
