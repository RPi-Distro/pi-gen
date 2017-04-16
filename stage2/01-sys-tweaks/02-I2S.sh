#!/bin/bash

: <<'DISCLAIMER'

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

This script is licensed under the terms of the MIT license.
Unless otherwise noted, code reproduced herein
was written for this script.

- The Pimoroni Crew - (modified by Adafruit!)

DISCLAIMER

# script control variables

productname="i2s amplifier" # the name of the product to install
scriptname="i2samp" # the name of this script
spacereq=1 # minimum size required on root partition in MB
debugmode="no" # whether the script should use debug routines
debuguser="none" # optional test git user to use in debug mode
debugpoint="none" # optional git repo branch or tag to checkout
forcesudo="no" # whether the script requires to be ran with root privileges
promptreboot="no" # whether the script should always prompt user to reboot
mininstall="no" # whether the script enforces minimum install routine
customcmd="yes" # whether to execute commands specified before exit
armhfonly="yes" # whether the script is allowed to run on other arch
armv6="yes" # whether armv6 processors are supported
armv7="yes" # whether armv7 processors are supported
armv8="yes" # whether armv8 processors are supported
raspbianonly="no" # whether the script is allowed to run on other OSes
osreleases=( "Raspbian" ) # list os-releases supported
oswarning=( "Debian" "Kano" "Mate" "PiTop" "Ubuntu" ) # list experimental os-releases
osdeny=( "Darwin" "Kali" ) # list os-releases specifically disallowed

FORCE=$1
DEVICE_TREE=true
ASK_TO_REBOOT=false
CURRENT_SETTING=false
UPDATE_DB=false

BOOTCMD=/boot/cmdline.txt
CONFIG=/boot/config.txt
APTSRC=/etc/apt/sources.list
INITABCONF=/etc/inittab
BLACKLIST=/etc/modprobe.d/raspi-blacklist.conf
LOADMOD=/etc/modules
DTBODIR=/boot/overlays

# function define

prompt() {
        read -r -p "$1 [y/N] " response < /dev/tty
        if [[ $response =~ ^(yes|y|Y)$ ]]; then
            true
        else
            false
        fi
}

success() {
    echo -e "$(tput setaf 2)$1$(tput sgr0)"
}

inform() {
    echo -e "$(tput setaf 6)$1$(tput sgr0)"
}

warning() {
    echo -e "$(tput setaf 1)$1$(tput sgr0)"
}

newline() {
    echo ""
}

progress() {
    count=0
    until [ $count -eq $1 ]; do
        echo -n "..." && sleep 1
        ((count++))
    done
    echo
}
sudocheck() {
    if [ $(id -u) -ne 0 ]; then
        echo -e "Install must be run as root. Try 'sudo ./$scriptname'\n"
        exit 1
    fi
}

sysclean() {
    sudo apt-get clean && sudo apt-get autoclean
    sudo apt-get -y autoremove &> /dev/null
}

sysupdate() {
    if ! $UPDATE_DB; then
        echo "Updating apt indexes..." && progress 3 &
        sudo apt-get update 1> /dev/null || { warning "Apt failed to update indexes!" && exit 1; }
        echo "Reading package lists..."
        progress 3 && UPDATE_DB=true
    fi
}

sysupgrade() {
    sudo apt-get upgrade
    sudo apt-get clean && sudo apt-get autoclean
    sudo apt-get -y autoremove &> /dev/null
}

sysreboot() {
    warning "Some changes made to your system require"
    warning "your computer to reboot to take effect."
    newline
    if prompt "Would you like to reboot now?"; then
        sync && sudo reboot
    fi
}

arch_check() {
    IS_ARMHF=false
    IS_ARMv6=false

    if uname -m | grep "armv.l" > /dev/null; then
        IS_ARMHF=true
        if uname -m | grep "armv6l" > /dev/null; then
            IS_ARMv6=true
        fi
    fi
}

os_check() {
    IS_RASPBIAN=false
    IS_MACOSX=false
    IS_SUPPORTED=false
    IS_EXPERIMENTAL=false

    if [ -f /etc/os-release ]; then
        if cat /etc/os-release | grep "Raspbian" > /dev/null; then
            IS_RASPBIAN=true && IS_SUPPORTED=true
        fi
        if command -v apt-get > /dev/null; then
            for os in ${osreleases[@]}; do
                if cat /etc/os-release | grep $os > /dev/null; then
                    IS_SUPPORTED=true && IS_EXPERIMENTAL=false
                fi
            done
            for os in ${oswarning[@]}; do
                if cat /etc/os-release | grep $os > /dev/null; then
                    IS_SUPPORTED=false && IS_EXPERIMENTAL=true
                fi
            done
            for os in ${osdeny[@]}; do
                if cat /etc/os-release | grep $os > /dev/null; then
                    IS_SUPPORTED=false && IS_EXPERIMENTAL=false
                fi
            done
        fi
    fi
    if [ -d ~/.kano-settings ] || [ -d ~/.kanoprofile ]; then
        IS_RASPBIAN=false
        for os in ${oswarning[@]}; do
            if [ $os == "Kano" ]; then
                IS_SUPPORTED=false && IS_EXPERIMENTAL=true
            fi
        done
        for os in ${osdeny[@]}; do
            if [ $os == "Kano" ]; then
                IS_SUPPORTED=false && IS_EXPERIMENTAL=false
            fi
        done
    fi
    if [ -f ~/.pt-dashboard-config ] || [ -d ~/.pt-dashboard ]; then
        IS_RASPBIAN=false
        for os in ${oswarning[@]}; do
            if [ $os == "PiTop" ]; then
                IS_SUPPORTED=false && IS_EXPERIMENTAL=true
            fi
        done
        for os in ${osdeny[@]}; do
            if [ $os == "PiTop" ]; then
                IS_SUPPORTED=false && IS_EXPERIMENTAL=false
            fi
        done
    fi
    if [ -d ~/.config/ubuntu-mate ]; then
        for os in ${osdeny[@]}; do
            if [ $os == "Mate" ]; then
                IS_SUPPORTED=false && IS_EXPERIMENTAL=false
            fi
        done
    fi
    if uname -s | grep "Darwin" > /dev/null; then
        IS_MACOSX=true
        for os in ${osdeny[@]}; do
            if [ $os == "Darwin" ]; then
                IS_SUPPORTED=false && IS_EXPERIMENTAL=false
            fi
        done
    fi
}

raspbian_check() {
    IS_SUPPORTED=false
    IS_EXPERIMENTAL=false

    if [ -f /etc/os-release ]; then
        if cat /etc/os-release | grep "/sid" > /dev/null; then
            IS_SUPPORTED=false && IS_EXPERIMENTAL=true
        elif cat /etc/os-release | grep "stretch" > /dev/null; then
            IS_SUPPORTED=false && IS_EXPERIMENTAL=true
        elif cat /etc/os-release | grep "jessie" > /dev/null; then
            IS_SUPPORTED=true && IS_EXPERIMENTAL=false
        elif cat /etc/os-release | grep "wheezy" > /dev/null; then
            IS_SUPPORTED=true && IS_EXPERIMENTAL=false
        else
            IS_SUPPORTED=false && IS_EXPERIMENTAL=false
        fi
    fi
}

: <<'MAINSTART'

Perform all global variables declarations as well as function definition
above this section for clarity, thanks!

MAINSTART

# checks and init

arch_check
os_check

if [ $debugmode != "no" ]; then
    echo "USER_HOME is $USER_HOME" && newline
    echo "IS_RASPBIAN is $IS_RASPBIAN"
    echo "IS_MACOSX is $IS_MACOSX"
    echo "IS_SUPPORTED is $IS_SUPPORTED"
    echo "IS_EXPERIMENTAL is $IS_EXPERIMENTAL"
    newline
fi

if ! $IS_ARMHF; then
    warning "This hardware is not supported, sorry!"
    warning "Config files have been left untouched"
    newline && exit 1
fi

if $IS_ARMv8 && [ $armv8 == "no" ]; then
    warning "Sorry, your CPU is not supported by this installer"
    newline && exit 1
elif $IS_ARMv7 && [ $armv7 == "no" ]; then
    warning "Sorry, your CPU is not supported by this installer"
    newline && exit 1
elif $IS_ARMv6 && [ $armv6 == "no" ]; then
    warning "Sorry, your CPU is not supported by this installer"
    newline && exit 1
fi

if [ $raspbianonly == "yes" ] && ! $IS_RASPBIAN;then
        warning "This script is intended for Raspbian on a Raspberry Pi!"
        newline && exit 1
fi

if $IS_RASPBIAN; then
    raspbian_check
    if ! $IS_SUPPORTED && ! $IS_EXPERIMENTAL; then
        newline && warning "--- Warning ---" && newline
        echo "The $productname installer"
        echo "does not work on this version of Raspbian."
        echo "Check https://github.com/$gitusername/$gitreponame"
        echo "for additional information and support"
        newline && exit 1
    fi
fi

if ! $IS_SUPPORTED && ! $IS_EXPERIMENTAL; then
        warning "Your operating system is not supported, sorry!"
        newline && exit 1
fi

if $IS_EXPERIMENTAL; then
    warning "Support for your operating system is experimental. Please visit"
    warning "forums.adafruit.com if you experience issues with this product."
    newline
fi

if [ $forcesudo == "yes" ]; then
    sudocheck
fi

newline
echo "This script will install everything needed to use"
echo "$productname"
newline

newline
echo "Checking hardware requirements..."

if [ -e $CONFIG ] && grep -q "^device_tree=$" $CONFIG; then
    DEVICE_TREE=false
fi

if $DEVICE_TREE; then

    newline
    echo "Adding Device Tree Entry to $CONFIG"

    if [ -e $CONFIG ] && grep -q "^dtoverlay=hifiberry-dac$" $CONFIG; then
        echo "dtoverlay already active"
    else
        echo "dtoverlay=hifiberry-dac" | sudo tee -a $CONFIG
        ASK_TO_REBOOT=true
    fi

    if [ -e $BLACKLIST ]; then
        newline
        echo "Commenting out Blacklist entry in "
        echo "$BLACKLIST"
        sudo sed -i -e "s|^blacklist[[:space:]]*i2c-bcm2708.*|#blacklist i2c-bcm2708|" \
                    -e "s|^blacklist[[:space:]]*snd-soc-pcm512x.*|#blacklist snd-soc-pcm512x|" \
                    -e "s|^blacklist[[:space:]]*snd-soc-wm8804.*|#blacklist snd-soc-wm8804|" $BLACKLIST &> /dev/null
    fi
else
    newline
    echo "No Device Tree Detected, not supported"
    newline
    exit 1
fi

if [ -e $CONFIG ] && grep -q -E "^dtparam=audio=on$" $CONFIG; then
    bcm2835off="no"
    newline
    echo "Disabling default sound driver"
    sudo sed -i "s|^dtparam=audio=on$|#dtparam=audio=on|" $CONFIG &> /dev/null
    if [ -e $LOADMOD ] && grep -q "^snd-bcm2835" $LOADMOD; then
        sudo sed -i "s|^snd-bcm2835|#snd-bcm2835|" $LOADMOD &> /dev/null
    fi
    ASK_TO_REBOOT=true
elif [ -e $LOADMOD ] && grep -q "^snd-bcm2835" $LOADMOD; then
    bcm2835off="no"
    newline
    echo "Disabling default sound module"
    sudo sed -i "s|^snd-bcm2835|#snd-bcm2835|" $LOADMOD &> /dev/null
    ASK_TO_REBOOT=true
else
    newline
    echo "Default sound driver currently not loaded"
    bcm2835off="yes"
fi

echo "Configuring sound output"
if [ -e /etc/asound.conf ]; then
    if [ -e /etc/asound.conf.old ]; then
        sudo rm -f /etc/asound.conf.old
    fi
    sudo mv /etc/asound.conf /etc/asound.conf.old
fi
sudo echo -e "pcm.\041default {\n type hw\n card 0\n}" > ~/asound.conf
sudo echo -e "ctl.\041default {\n type hw\n card 0\n}" >> ~/asound.conf
sudo mv ~/asound.conf /etc/asound.conf

if [ $bcm2835off == "yes" ]; then
    newline
    echo "We can now test your $productname"
    warning "Set your speakers at a low volume!"
    if confirm "Do you wish to test your system now?"; then
        echo "Testing..."
        speaker-test -l5 -c2 -t wav
    fi
fi
newline
success "All done!"
newline
echo "Enjoy your new $productname!"
newline



exit 0