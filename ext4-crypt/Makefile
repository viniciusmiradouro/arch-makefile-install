.DEFAULT_GOAL := help

# Defining commands

PACMAN := sudo pacman --noconfirm -S
SYSTEMD_ENABLE	:= sudo systemctl --now enable
PARU := paru -S --noconfirm

# listing packages for installation

BASE_PKGS := base base-devel linux-firmware networkmanager 
BASE_PKGS += intel-ucode efibootmgr grub man-db man-pages
BASE_PKGS += zsh acpi acpi_call-lts rsync ethtool
BASE_PKGS += xf86-video-intel dosfstools linux-lts-headers
BASE_PKGS += git neovim mtools

FULL_PKGS := abook alacritty alsa-utils aspell-pt
FULL_PKGS += bat binutils bison bleachbit calc cmus
FULL_PKGS += cronie dash discord dunst entr exa fzf
FULL_PKGS += geogebra htop lynx m4 mpv msmtp neomutt
FULL_PKGS += newsboat nitrogen nodejs
FULL_PKGS += noto-fonts-emoji npm obs-studio 
FULL_PKGS += pandoc pass playerctl powerline-fonts
FULL_PKGS += pulseaudio-alsa python-pip python-slugify
FULL_PKGS += qutebrowser redshift reflector
FULL_PKGS += ripgrep scrot shellcheck
FULL_PKGS += smartmontools snapper starship
FULL_PKGS += stow stress surfraw acpid 
FULL_PKGS += sxiv texlive-most tlp
FULL_PKGS += transmission-cli udiskie udisks2
FULL_PKGS += unzip virtualbox wget
FULL_PKGS += xbindkeys xdg-user-dirs xdo
FULL_PKGS += xmobar xmonad xmonad-contrib firewalld 
FULL_PKGS += xorg xorg-server youtube-dl
FULL_PKGS += zathura zathura-djvu zathura-pdf-poppler
FULL_PKGS += zsh-autosuggestions zsh-syntax-highlighting 
FULL_PKGS += acpi acpi_call-lts github-cli lightdm lxappearance-gtk3
FULL_PKGS += qt5ct

AUR_PKGS := betterlockscreen dashbinsh devour dockd
AUR_PKGS += snap-pac-grub mutt-wizard nerd-fonts-mononoki
AUR_PKGS += picom-jonaburg-git pacmixer reflector-mirrorlist-update 
AUR_PKGS += dockd kmonad lightdm-webkit-theme-aether

help: ## Display this menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

partition: ## (RISKY) Partition disk
	sgdisk --zap-all /dev/sda # Deleting all partitions
	sgdisk --new=1::+512M /dev/sda # Making boot partition
	sgdisk -t=1:ef00 /dev/sda # Changing boot partition type
	sgdisk --change-name=1:"EFI system partition" /dev/sda
	sgdisk --new=2:: /dev/sda # Making Encrypted partiton
	sgdisk -t=2:8e00 /dev/sda # Changing swap partition type
	sgdisk --change-name=2:"Linux LVM" /dev/sda

encrypt: ## (RISKY) Encrypt main partition
	cryptsetup luksFormat /dev/sda2
	cryptsetup luksOpen /dev/sda2 cryptlvm

lvmcreate: ## (RISKY) Create logical volumes
	pvcreate /dev/mapper/cryptlvm
	vgcreate vg1 /dev/mapper/cryptlvm
	lvcreate -L 5G vg1 -n root
	lvcreate -L 512M vg1 -n swap
	lvcreate -l 100%FREE vg1 -n home
	
format: ## (RISKY) Format partitions
	mkfs.fat -F32 /dev/sda1 # Formating boot partition as fat32
	mkfs.ext4 /dev/vg1/root # Formating root partition as ext4
	mkswap /dev/vg1/swap # Formating swap partition
	swapon /dev/vg1/swap # Activating swap
	mkfs.ext4 /dev/vg1/home # Formating home partition as ext4

mount-partitions: ## Mount partitions
	mount /dev/vg1/root /mnt
	mkdir /mnt/boot
	mkdir /mnt/home
	mount /dev/sda1 /mnt/boot
	mount /dev/vg1/home /mnt/home
	
update-mirrors: ## Update the mirrors with reflector
	reflector -c Brazil --sort rate --save /etc/pacman.d/mirrorlist

install-base: ## Install basic packages and generate fstab
	pacstrap /mnt $(BASE_PKGS)
	genfstab -U /mnt >> /mnt/etc/fsbtab

cp-make-root: ## Copies this makefile to every users home
	cp Makefile /mnt

chroot:
	arch-chroot /mnt

base-config: ## Configure a basic system
	# Setting time zone
	ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
	# Setting the locale
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
	echo "LANG=en_US.UTF-8" >> /etc/locale.conf
	locale-gen
	# Setting the keyboard layout
	echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
	# Setting the hostname
	echo "euclid" >> /etc/hostname
	# Configuring networking
	echo "127.0.0.1        localhost" >> /etc/hosts
	echo "::1              localhost" >> /etc/hosts
	echo "127.0.1.1        euclid.localdomain euclid" >> /etc/hosts

install-full-pkgs: ## Install optional packages
	$(PACMAN) $(FULL_PKGS)

install-grub: ## install grub for a uefi system
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg

enable-services: ## Enable basic services
	$(SYSTEMD_ENABLE) NetworkManager
	$(SYSTEMD_ENABLE) tlp
	$(SYSTEMD_ENABLE) acpid
	$(SYSTEMD_ENABLE) reflector.service
	$(SYSTEMD_ENABLE) reflector.timer
	$(SYSTEMD_ENABLE) firewalld

install-paru: ## install the yaourt paru
	git clone https://aur.archlinux.org/paru.git
	cd paru
	makepkg -si --noconfirm
	cd ..
	rm -rf paru

install-aur: ## Installing packages from the arch user respository
	$(PARU) $(AUR_PKGS)	

cp-make-home: ## Copies this makefile to every users home
	cp Makefile /mnt/home/*/

clone-dots: ## clone my private dotfiles
	git clone https://github.com/viniciusmiradouro/.dotfiles	

# prepare-disk: partition format ## (RISKY) Partition and format disks

# sys-install: prepare-disk mount-partitions update-mirrors install-base cp-make-root chroot cp-make-home ## Minimal complete Installation

# setup-system: base-config  install-full-pkgs install-grub enable-services ## System setup to do in a chroot
# 	echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wheel
