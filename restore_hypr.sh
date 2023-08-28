#!/bin/bash

software_list=(

    xorg-xwayland 

    qt5-wayland 
    qt5ct
    qt6-wayland 
    qt6ct
    qt5-svg
    qt5-quickcontrols2
    qt5-graphicaleffects

    glfw-wayland 

    pipewire 
    wireplumber 

    xdg-desktop-portal-hyprland
    gtk3
    hyprland-git 
    rofi
    waybar-hyprland-git
    kitty
    swww
    mako
    sddm-git
    sddm-theme-corners-git

    fcitx5
    fcitx5-chinese-addons
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-pinyin-zhwiki
    fcitx5-qt

    cliphist 
    wl-clipboard

    pacman-contrib
    jq 

    ttf-maple
    nerd-fonts-sarasa-term
    ttf-apple-emoji

    slurp 
    grim 
    swappy 

    libnotify

    obs-studio

    polkit-kde-agent

    udiskie

    bluez 
    bluez-utils 
    blueman

    swaylock-effects

    thunar

    ristretto 
    mpv

    network-manager-applet

    btop

    yesplaymusic
    firefox
    neovide-git
    clash-for-windows-bin
    bob
    unzip
    dconf
    dconf-editor
    fd
    fish
    fuse2
    git 
    lazygit
    xmake
    npm
    ripgrep
    obsidian
)



# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"

######
# functions go here

# function that would show a progress bar to the user
show_progress() {
    while ps | grep $1 &> /dev/null;
    do
        echo -n "."
        sleep 2
    done
    echo -en "Done!\n"
    sleep 2
}

# function that will test for a package and if not found it will attempt to install it
install_software() {
    # First lets see if the package is there
    if paru -Q $1 &>> /dev/null ; then
        echo -e "$COK - $1 is already installed."
    else
        # no package found so installing
        echo -en "$CNT - Now installing $1 ."
        paru -S --noconfirm $1 &>> $INSTLOG &
        show_progress $!
        # test to make sure package installed
        if paru -Q $1 &>> /dev/null ; then
            echo -e "\e[1A\e[K$COK - $1 was installed."
        else
            # if this is hit then a package is missing, exit to review log
            echo -e "\e[1A\e[K$CER - $1 install had failed, please check the install.log"
            exit
        fi
    fi
}

# clear the screen
clear


# attempt to discover if this is a VM or not
echo -e "$CNT - Checking for Physical or VM..."
ISVM=$(hostnamectl | grep Chassis)
echo -e "Using $ISVM"
if [[ $ISVM == *"vm"* ]]; then
    echo -e "$CWR - Please note that VMs are not fully supported and if you try to run this on
    a Virtual Machine there is a high chance this will fail."
    sleep 1
fi

#### Check for package manager ####
if [ ! -f /sbin/paru ]; then  
    echo -en "$CER - Please install paru."
    exit
fi


### Install all of the above pacakges ####
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install the packages? (y,n) ' INST
if [[ $INST == "Y" || $INST == "y" ]]; then

    # Prep Stage - Bunch of needed items
    echo -e "$CNT - Prep Stage - Installing needed components, this may take a while..."
    for SOFTWR in ${software_list[@]}; do
        install_software $SOFTWR 
    done

    # Start the bluetooth service
    echo -e "$CNT - Starting the Bluetooth Service..."
    sudo systemctl enable --now bluetooth.service &>> $INSTLOG
    sleep 2

    # Enable the sddm login manager service
    echo -e "$CNT - Enabling the SDDM Service..."
    sudo systemctl enable sddm &>> $INSTLOG
    sleep 2
    
    # Clean out other portals
    echo -e "$CNT - Cleaning out conflicting xdg portals..."
    paru -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk &>> $INSTLOG
else
    exit
fi


### Copy Config Files ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to copy config files? (y,n) ' CFG
if [[ $CFG == "Y" || $CFG == "y" ]]; then
    echo -e "$CNT - Copying config files..."
    cp -r hypr ~/.config/
    cp -r kitty ~/.config/
    cp -r mako ~/.config/
    cp -r rofi ~/.config/
    cp -r swaylock ~/.config/
    cp -r swww ~/.config/
    cp -r waybar ~/.config/

    sudo mkdir /etc/sddm.conf.d
    echo -e "[Theme]\nCurrent=corners" | sudo tee -a /etc/sddm.conf.d/theme.conf &>> $INSTLOG
fi


### Script is done ###
echo -e "$CNT - Script had completed!"

read -rep $'[\e[1;33mACTION\e[0m] - Would you like to start Hyprland now? (y,n) ' HYP
if [[ $HYP == "Y" || $HYP == "y" ]]; then
    exec sudo systemctl start sddm &>> $INSTLOG
else
    exit
fi
