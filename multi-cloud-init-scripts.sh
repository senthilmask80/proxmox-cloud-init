#!/bin/bash

#Create template
#args:
# vm_id
# vm_name
# file name in the current directory
function create_template() {
    #Print all of the configuration
    echo "Creating template $2 ($1)"

    #Create new VM 
    #Feel free to change any of these to your liking
    qm create $1 --name $2 --ostype l26 
    #Set networking to default bridge
    qm set $1 --net0 virtio,bridge=vmbr0
    #Set display to serial
    qm set $1 --serial0 socket --vga serial0
    #Set memory, cpu, type defaults
    #If you are in a cluster, you might need to change cpu type
    qm set $1 --memory 1024 --cores 4 --cpu host
    #Set boot device to new file
    qm set $1 --scsi0 ${storage}:0,import-from="$(pwd)/$3",discard=on
    #Set scsi hardware as default boot disk using virtio scsi single
    qm set $1 --boot order=scsi0 --scsihw virtio-scsi-single
    #Enable Qemu guest agent in case the guest has it available
    qm set $1 --agent enabled=1,fstrim_cloned_disks=1
        #Add cloud-init device
    qm set $1 --ide2 ${storage}:cloudinit
    #Set CI ip config
    #IP6 = auto means SLAAC (a reliable default with no bad effects on non-IPv6 networks
    #IP = DHCP means what it says, so leave that out entirely on non-IPv4 networks to avoid DHCP delays
    qm set $1 --ipconfig0 "ip6=auto,ip=dhcp"
    #Import the ssh keyfile
    qm set $1 --sshkeys ${ssh_keyfile}
    #If you want to do password-based auth instaed
    #Then use this option and comment out the line above
    #qm set $1 --cipassword password
    #Add the user
    qm set $1 --ciuser ${username}
    #Resize the disk to 8G, a reasonable minimum. You can expand it more later.
    #If the disk is already bigger than 8G, this will fail, and that is okay.
    qm disk resize $1 scsi0 8G
    #Make it a template
    qm template $1

    #Remove file when done
    rm $3
}

#Path to your ssh authorized_keys file
#Alternatively, use /etc/pve/priv/authorized_keys if you are already authorized
#on the Proxmox system
export ssh_keyfile=/root/id_rsa.pub
#Username to create on VM template
export username=thyan

#Name of your storage
export storage=local-lvm

#The images that I've found premade
#Feel free to add your own

## Debian
#Debian Buster (10) (really old at this point)
wget "https://cloud.debian.org/images/cloud/buster/latest/debian-10-genericcloud-amd64.qcow2"
create_template 9000 "temp-debian-10" "debian-10-genericcloud-amd64.qcow2"
#Debian Bullseye (11) (oldstable)
wget "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
create_template 9001 "temp-debian-11" "debian-11-genericcloud-amd64.qcow2" 
#Debian Bookworm (12) (stable)
wget "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
create_template 9002 "temp-debian-12" "debian-12-genericcloud-amd64.qcow2"
#Debian Trixie (13) (testing) dailies
wget "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-genericcloud-amd64-daily.qcow2"
create_template 9003 "temp-debian-13-daily" "debian-13-genericcloud-amd64-daily.qcow2"
#Debian Sid (unstable)
wget "https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-genericcloud-amd64-daily.qcow2"
create_template 9009 "temp-debian-sid" "debian-sid-genericcloud-amd64-daily.qcow2" 

## Ubuntu
#Ubuntu 20.04 (Focal Fossa) LTS
wget "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
create_template 9011 "temp-ubuntu-20-04" "ubuntu-20.04-server-cloudimg-amd64.img" 
#Ubuntu 22.04 (Jammy Jellyfish) LTS
wget "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
create_template 9012 "temp-ubuntu-22-04" "ubuntu-22.04-server-cloudimg-amd64.img" 
#Ubuntu 23.10 (Manic Minotaur)
wget "https://cloud-images.ubuntu.com/releases/23.10/release/ubuntu-23.10-server-cloudimg-amd64.img"
create_template 9013 "temp-ubuntu-23-10" "ubuntu-23.10-server-cloudimg-amd64.img"
#As 23.10 has *just released*, the next LTS (24.04) is not in dailies yet

## Fedora 37
#Image is compressed, so need to uncompress first
wget "https://download.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/x86_64/images/Fedora-Cloud-Base-37-1.7.x86_64.raw.xz"
xz -d -v Fedora-Cloud-Base-37-1.7.x86_64.raw.xz
create_template 9021 "temp-fedora-37" "Fedora-Cloud-Base-37-1.7.x86_64.raw"
## Fedora 38
wget "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.raw.xz"
xz -d -v Fedora-Cloud-Base-38-1.6.x86_64.raw.xz
create_template 9022 "temp-fedora-38" "Fedora-Cloud-Base-38-1.6.x86_64.raw"

## Rocky Linux
#Rocky 8 latest
wget "http://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud.latest.x86_64.qcow2"
create_template 9031 "temp-rocky-8" "Rocky-8-GenericCloud.latest.x86_64.qcow2"
#Rocky 9 latest
wget "http://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
create_template 9032 "temp-rocky-9" "Rocky-9-GenericCloud.latest.x86_64.qcow2"

## Alpine Linux
#Alpine 3.19.1
wget "https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/cloud/nocloud_alpine-3.19.1-x86_64-bios-cloudinit-r0.qcow2"
create_template 9041 "temp-alpine-3.19" "nocloud_alpine-3.19.1-x86_64-bios-cloudinit-r0.qcow2"

#Almalinux 8 latest
wget "https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
create_template 9051 "temp-almalinux-8" "AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
#AlmaLinux 9 latest
wget "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
create_template 9052 "temp-almalinux-9" "AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"

## Centos
#Centos 6 latest
wget "https://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2"
create_template 9061 "temp-centos-6" "CentOS-6-x86_64-GenericCloud.qcow2"
#Centos 7 latest
wget "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
create_template 9062 "temp-centos-7" "CentOS-7-x86_64-GenericCloud.qcow2"
#Centos 8-stream latest
wget "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
create_template 9063 "temp-centos-8-stream" "CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
#Centos 8 latest
wget "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
create_template 9064 "temp-centos-8" "CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
#Centos 9-stream latest
wget "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2"
create_template 9065 "temp-centos-9-stream" "CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2"

# arch Linux
# arch Linux latest
wget "https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2"
create_template 9071 "temp-arch-latest" "Arch-Linux-x86_64-cloudimg.qcow2"

## Kali Linux 
# Kali Linux Generic Cloud Image for x64
wget "https://kali.download/cloud-images/kali-2024.2/kali-linux-2024.2-cloud-genericcloud-amd64.tar.xz"
xz -d -v kali-linux-2024.2-cloud-genericcloud-amd64.tar.xz
create_template 9081 "temp-kali-genericcloud" "kali-linux-2024.2-cloud-genericcloud-amd64"
# Kali Linux latest x64
wget "https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-qemu-amd64.7z"
xz -d -v kali-linux-2024.2-qemu-amd64.7z
create_template 9082 "temp-kali-x64" "kali-linux-2024.2-qemu-amd64"
# Kali Linux weekly x64
wget "https://cdimage.kali.org/kali-weekly/kali-linux-2024-W30-qemu-amd64.7z"
xz -d -v kali-linux-2024-W30-qemu-amd64.7z
create_template 9083 "temp-kali-x64-weekly" "kali-linux-2024-W30-qemu-amd64"
# Kali Linux latest x32
wget "https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-qemu-i386.7z"
create_template 9084 "temp-kali-x32bit" "kali-linux-2024.2-qemu-i386"

## gentoo linux
wget "https://distfiles.gentoo.org/experimental/amd64/openstack/gentoo-openstack-amd64-default-latest.qcow2"
create_template 9091 "temp-gentoo" "gentoo-openstack-amd64-default-latest.qcow2"

## A collection of prebuilt BSD cloud images
## These unofficial images are tested on OpenStack and NoCloud (with Virt-Lightning).
##  They come with Cloud-init, and so they should support all the main Cloud providers.

## freebsd
# freebsd 13.3 ufs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/13.3/2024-05-06/ufs/freebsd-13.3-ufs-2024-05-06.qcow2"
create_template 9101 "freebsd-13.3-ufs-2024-05-06.qcow2"
# freebsd 13.3 zfs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/13.3/2024-05-06/zfs/freebsd-13.3-zfs-2024-05-06.qcow2"
create_template 9102 "freebsd-13.3-zfs-2024-05-06.qcow2"
# freebsd 14.0 ufs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/14.0/2024-05-04/ufs/freebsd-14.0-ufs-2024-05-04.qcow2"
create_template 9103 "freebsd-14.0-ufs-2024-05-04.qcow2"
# freebsd 14.0 zfs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/14.0/2024-05-06/zfs/freebsd-14.0-zfs-2024-05-06.qcow2"
create_template 9104 "freebsd-14.0-zfs-2024-05-06.qcow2"

# NetBSD 
# NetBSD 8.2 
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/netbsd/8.2/netbsd-8.2.qcow2"
create_template 9111 "netbsd-8.2.qcow2"
# NetBSD 9.3
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/netbsd/9.3/2023-04-23/ufs/netbsd-9.3-2023-04-23.qcow2"
create_template 9112 "netbsd-9.3-2023-04-23.qcow2"

# OpenBSD 7.4
wget "https://github.com/hcartiaux/openbsd-cloud-image/releases/download/v7.4_2024-05-15-16-35/openbsd-min.qcow2"
create_template 9121 "openbsd-min.qcow2"
# OpenBSD 7.5
wget "https://github.com/hcartiaux/openbsd-cloud-image/releases/download/v7.5_2024-05-13-15-25/openbsd-min.qcow2"
create_template 9122 "openbsd-min.qcow2"

# DragonFlyBSD 6.2.2 ufs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/dragonflybsd/6.2.2/2022-09-06/ufs/dragonflybsd-6.2.2-ufs-2022-09-06.qcow2"
create_template 9131 "dragonflybsd-6.2.2-ufs-2022-09-06.qcow2"
# DragonFlyBSD 6.2.2 Hammer2 file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/dragonflybsd/6.2.2/2022-09-06/hammer2/dragonflybsd-6.2.2-hammer2-2022-09-06.qcow2"
create_template 9132 "dragonflybsd-6.2.2-hammer2-2022-09-06.qcow2"
# DragonFlyBSD 6.4.0 ufs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/dragonflybsd/6.4.0/2023-04-23/ufs/dragonflybsd-6.4.0-ufs-2023-04-23.qcow2"
create_template 9133 "dragonflybsd-6.4.0-ufs-2023-04-23.qcow2"
# DragonFlyBSD 6.4.0 hammer2 file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/dragonflybsd/6.4.0/2023-04-23/hammer2/dragonflybsd-6.4.0-hammer2-2023-04-23.qcow2"
create_template 9134 "dragonflybsd-6.4.0-hammer2-2023-04-23.qcow2"

## whonix
# whonix latest
wget "https://download.whonix.org/libvirt/17.2.0.1/Whonix-Xfce-17.2.0.1.Intel_AMD64.qcow2.libvirt.xz"
xz -d -v Whonix-Xfce-17.2.0.1.Intel_AMD64.qcow2.libvirt.xz
create_template 8001 "temp-whonix" "Whonix-Xfce-17.2.0.1.Intel_AMD64.qcow2"

## Plesk
# Plesk almalinux 9.18
wget "https://autoinstall.plesk.com/images/plesk-almalinux-9-18.0.62.qcow2"
create_template 8011 "temp-plesk-alma-918" "plesk-almalinux-9-18.0.62.qcow2"
# Plesk almalinux 9 latest
wget "https://autoinstall.plesk.com/images/plesk-almalinux-9-latest.qcow2"
create_template 8012 "temp-plesk-alma-9" "plesk-almalinux-9-latest.qcow2"
# Plesk almalinux latest
wget "https://autoinstall.plesk.com/images/plesk-almalinux-latest.qcow2"
create_template 8013 "temp-plesk-alma" "plesk-almalinux-latest.qcow2"
# Plesk centos 7.18
wget "https://autoinstall.plesk.com/images/plesk-centos-7-18.0.54.qcow2"
create_template 8014 "temp-plesk-centos-718" "plesk-centos-7-18.0.54.qcow2"
# Plesk centos 7 latest
wget "https://autoinstall.plesk.com/images/plesk-centos-7-latest.qcow2"
create_template 8015 "temp-plesk-centos-7" "plesk-centos-7-latest.qcow2"
# Plesk centos latest
wget "https://autoinstall.plesk.com/images/plesk-centos-latest.qcow2"
create_template 8016 "temp-plesk-centos" "plesk-centos-latest.qcow2"
# Plesk ubuntu 22-18
wget "https://autoinstall.plesk.com/images/plesk-ubuntu-22-18.0.62.qcow2"
create_template 8017 "temp-plesk-ubuntu-22-18" "plesk-ubuntu-22-18.0.62.qcow2"
# Plesk ubuntu 22 latest
wget "https://autoinstall.plesk.com/images/plesk-ubuntu-22-latest.qcow2"
create_template 8018 "temp-plesk-ubuntu-22" "plesk-ubuntu-22-latest.qcow2"
# Plesk ubuntu latest
wget "https://autoinstall.plesk.com/images/plesk-ubuntu-latest.qcow2"
create_template 8019 "temp-plesk-ubuntu" "plesk-ubuntu-latest.qcow2"

# apache cloudstack
# apache cloudstack 4.15
wget "http://download.cloudstack.org/systemvm/4.15/systemvmtemplate-4.15.0-kvm.qcow2.bz2"
xz -d -v systemvmtemplate-4.15.0-kvm.qcow2.bz2
create_template 8021 "temp-apache-cloudstack" "systemvmtemplate-4.15.0-kvm.qcow2"


