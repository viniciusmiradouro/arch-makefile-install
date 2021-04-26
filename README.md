# arch-makefile-install

## Introduction

WIP. Please read the file.

This script is meant for UEFI systems only.

## Instructions

2. Boot into the arch live environment
3. Load your keyboard layout
4. Install git and make
5. clone this repo ``# git clone https://github.com/viniciusmiradouro/arch-makefile-install``
6. cd into the repo ``# cd arch-makefile-install``
7. Edit the script according to your needs
8. Run ``# make minimal-sys-install`` or ``# make full-sys-install``
    1. For help, just run ``# make``
9. Generate locales with ``# locale-gen``
10. Enable the networkmanager service ``# systemctl enable NetworkManager``
11. Set the root password
12. Add an user with the command ``# useradd -mG wheel {username}``
13. Set a password for the user
14. Configure the sudoers file
15. Install grub ``# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB``
16. Make grub config ``# grub-mkconfig -o /boot/grub/grub.cfg``
16. Exit the chroot with ctrl+d
17. Reboot
