.DEFAULT_GOAL := help

# Defining commands

PACMAN := sudo pacman --noconfirm -S
SYSTEMD_ENABLE	:= sudo systemctl --now enable

# listing packages for installation

BASE := base base-devel linux-firmware networkmanager 
BASE += intel-ucode efibootmgr grub man-db man-pages
BASE += zsh acpi acpi_call-lts rsync ethtool
BASE += xf86-video-intel dosfstools linux-lts-headers
BASE += git neovim

PACMAN_PKGS := abook alacritty alsa-utils aspell-pt
PACMAN_PKGS += bat binutils bison bleachbit calc cmus
PACMAN_PKGS += cronie dash discord dunst entr exa fzf
PACMAN_PKGS += geogebra htop lf lynx m4 mpv msmtp neomutt
PACMAN_PKGS += newsboat nitrogen nodejs
PACMAN_PKGS += noto-fonts-emoji npm obs-studio pacmixer
PACMAN_PKGS += pandoc pass playerctl powerline-fonts
PACMAN_PKGS += pulseaudio-alsa python-pip python-slugify
PACMAN_PKGS += qutebrowser redshift reflector
PACMAN_PKGS += ripgrep scrot shellcheck
PACMAN_PKGS += smartmontools snapper starship
PACMAN_PKGS += stow stress surfraw
PACMAN_PKGS += sxiv texlive-most tlp
PACMAN_PKGS += transmission-cli udiskie udisks2
PACMAN_PKGS += unzip virtualbox wget
PACMAN_PKGS += xbindkeys xdg-user-dirs xdo
PACMAN_PKGS += xmobar xmonad xmonad-contrib
PACMAN_PKGS += xorg xorg-server youtube-dl
PACMAN_PKGS += zathura zathura-djvu zathura-pdf-poppler
PACMAN_PKGS += zsh-autosuggestions zsh-syntax-highlighting 

AUR_PKGS := betterlockscreen dashbinsh devour dockd
AUR_PKGS += snap-pac-grub mutt-wizard nerd-fonts-mononoki
AUR_PKGS += picom-jonaburg-git

help: ## Display this menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

partition: ## (RISKY) Partition disk
	sgdisk --zap-all /dev/sda # Deleting all partitions
	sgdisk --new=1::+512M /dev/sda # Making boot partition
	sgdisk -t=1:ef00 /dev/sda # Changing boot partition type
	sgdisk --change-name=1:"EFI system partition" /dev/sda
	sgdisk --new=2::+20G /dev/sda # Making root partition
	sgdisk --change-name=2:"Linux filesystem" /dev/sda
	sgdisk --new=3::+12G /dev/sda # Making swap partition
	sgdisk -t=3:8200 /dev/sda # Changing swap partition type
	sgdisk --change-name=3:"Linux swap" /dev/sda
	sgdisk --new=4:: /dev/sda # Making home partition
	sgdisk --change-name=4:"Linux filesystem" /dev/sda

format: ## (RISKY) Format partitions
	mkfs.fat -F32 /dev/sda1 # Formating boot partition as fat32
	mkfs.ext4 /dev/sda2 # Formating root partition as ext4
	mkswap /dev/sda3 # Formating swap partition
	swapon /dev/sda3 # Activating swap
	mkfs.ext4 /dev/sda4 # Formating home partition as ext4

prepare-disk: partition format ## (RISKY) Partition and format disks

mount-partitions: ## Mount partitions
	mount /dev/sda2 /mnt
	mkdir /mnt/boot
	mkdir /mnt/home
	mount /dev/sda1 /mnt/boot
	mount /dev/sda4 /mnt/home
	
update-mirrors: ## Update the mirrors with reflector
	reflector --country Brazil --age 12 --sort rate --save /etc/pacman.d/mirrorlist

install-base: ## Install basic packages
	pacstrap /mnt $(BASE)

basic-config: ## Configure a basic system
	# Generating the filesystem tab
	genfstab -U /mnt >> /mnt/etc/fstab
	# Setting time zone
	ln -sf /mnt/usr/share/zoneinfo/America/Sao_Paulo /mnt/etc/localtime
	# Setting the locale
	echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
	locale-gen
	echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
	# Setting the keyboard layout
	echo "LANG=br-abnt2" >> /mnt/etc/vconsole.conf
	# Setting the hostname
	echo "euclid" >> /mnt/etc/hostname
	# Configuring networking
	echo "127.0.0.1        localhost" >> /mnt/etc/hosts
	echo "::1              localhost" >> /mnt/etc/hosts
	echo "127.0.1.1        euclid.localdomain euclid" >> /mnt/etc/hosts
	# Activating Internet
	$(SYSTEMD_ENABLE) networkmanager

install-pkgs: ## Install nonbasic packages
	$(PACMAN) $(PACMAN_PKGS)

install-grub: ## Install grub and make config
	grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=GRUB
	grub-mkconfig -o /mnt/boot/grub/grub.cfg

full-install: prepare-disk mount-partitions update-mirrors install-base basic-config install-grub ## Complete Installation
