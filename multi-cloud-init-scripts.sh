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
## Fedora 39
wget "https://mirrors.tuna.tsinghua.edu.cn/fedora/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
xz -d -v Fedora-Cloud-Base-39-1.5.x86_64.qcow2
create_template 9023 "temp-fedora-39" "Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
## Fedora 40
wget "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"
xz -d -v Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2
create_template 9024 "temp-fedora-40" "Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"

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
tar -xvf kali-linux-2024.2-cloud-genericcloud-amd64.tar.xz
create_template 9081 "temp-kali-genericcloud" "kali-linux-2024.2-cloud-genericcloud-amd64"
# Kali Linux latest x64
wget "https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-qemu-amd64.7z"
7z x kali-linux-2024.2-qemu-amd64.7z
create_template 9082 "temp-kali-x64" "kali-linux-2024.2-qemu-amd64"
# Kali Linux weekly x64
wget "https://cdimage.kali.org/kali-weekly/kali-linux-2024-W30-qemu-amd64.7z"
7z x kali-linux-2024-W30-qemu-amd64.7z
create_template 9083 "temp-kali-x64-weekly" "kali-linux-2024-W30-qemu-amd64"
# Kali Linux latest x32
wget "https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-qemu-i386.7z"
7z x kali-linux-2024.2-qemu-i386.7z
create_template 9084 "temp-kali-x32bit" "kali-linux-2024.2-qemu-i386"

## gentoo linux
wget "https://distfiles.gentoo.org/experimental/amd64/openstack/gentoo-openstack-amd64-default-latest.qcow2"
create_template 9091 "temp-gentoo" "gentoo-openstack-amd64-default-latest.qcow2"

##  CloudLinux
# CloudLinux 9.4 x86_64 QEMU/KVM cloud image (build 20240628)
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-9.4-x86_64-openstack-20240628.qcow2"
create_template 9101 "temp-cloudlinux-94" "cloudlinux-9.4-x86_64-openstack-20240628.qcow2"
#  CloudLinux 8.10 x86_64 QEMU/KVM cloud image (build 20240628)
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-8.10-x86_64-openstack-20240628.qcow2"
create_template 9102 "temp-cloudlinux-810" "cloudlinux-8.10-x86_64-openstack-20240628.qcow2"
# CloudLinux 9.4 x86_64 QEMU/KVM cloud image with cPanel v120 + ALT-PHP, MySQL Governor and CageFS (build 20240712) 
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-9.4-x86_64-cpanel-openstack-20240712.qcow2"
create_template 9103 "temp-cloudlinux-94-cpanel" "cloudlinux-9.4-x86_64-cpanel-openstack-20240712.qcow2"
# CloudLinux 8.10 x86_64 QEMU/KVM cloud image with cPanel v120 + ALT-PHP, MySQL Governor and CageFS (build 20240712)
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-8.10-x86_64-cpanel-openstack-20240712.qcow2"
create_template 9104 "temp-cloudlinux-810-cpanel" "cloudlinux-8.10-x86_64-cpanel-openstack-20240712.qcow2"
# CloudLinux solo 8.8 x86_64 QEMU/KVM cloud image (build 20230620)
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-solo-8.8-x86_64-openstack-20230620.qcow2"
create_template 9105 "temp-cloudlinux-88-solo" "cloudlinux-solo-8.8-x86_64-openstack-20230620.qcow2"
# CloudLinux 7.9 x86_64 QEMU/KVM cloud image (build 20230616)
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-7.9-x86_64-openstack-20230616.qcow2"
create_template 9106 "temp-cloudlinux-79" "cloudlinux-7.9-x86_64-openstack-20230616.qcow2"
# CloudLinux solo 8.8 x86_64 QEMU/KVM cloud image with cPanel 11.112.0.3 + ALT-PHP, MySQL Governor and CageFS (build 20230622) 
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-solo-8.8-x86_64-cpanel-openstack-20230622.qcow2"
create_template 9107 "temp-cloudlinux-88-cpanel" "cloudlinux-solo-8.8-x86_64-cpanel-openstack-20230622.qcow2"
# CloudLinux 7.9 x86_64 QEMU/KVM cloud image with cPanel 11.110.0.7 + ALT-PHP, MySQL Governor and CageFS (build 20230621) 
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-7.9-x86_64-cpanel-openstack-20230621.qcow2"
create_template 9108 "temp-cloudlinux-79-cpanel" "cloudlinux-7.9-x86_64-cpanel-openstack-20230621.qcow2"
#  CloudLinux 8.8 x86_64 QEMU/KVM cloud image with Plesk 18.0.53 (build 20230626) 
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-8.8-x86_64-plesk-openstack-20230626.qcow2"
create_template 9109 "temp-cloudlinux-88-plesk" "cloudlinux-8.8-x86_64-plesk-openstack-20230626.qcow2"
# CloudLinux 8.8 x86_64 QEMU/KVM cloud image with DirectAdmin 1.649 + ALT-PHP, MySQL Governor and CageFS (build 20230622) 
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-8.8-x86_64-directadmin-openstack-20230622.qcow2"
create_template 9110 "temp-cloudlinux-88-directadmin" "cloudlinux-8.8-x86_64-directadmin-openstack-20230622.qcow2"
# CloudLinux 7.9 x86_64 QEMU/KVM cloud image with Plesk 18.0.53 (build 20230626) 
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-7.9-x86_64-plesk-openstack-20230626.qcow2"
create_template 9111 "temp-cloudlinux-79-plesk" "cloudlinux-7.9-x86_64-plesk-openstack-20230626.qcow2"
# CloudLinux 6.10 x86_64 QEMU/KVM cloud image (build 20220412) [DEPRECATED] 
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-6.10-x86_64-openstack-20220412.qcow2"
create_template 9112 "temp-cloudlinux-610" "cloudlinux-6.10-x86_64-openstack-20220412.qcow2"
# CloudLinux 6.10 x86_64 QEMU/KVM cloud image with cPanel 11.102.0.10 + ALT-PHP, MySQL Governor and CageFS (build 20220414) [DEPRECATED] 
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-6.10-x86_64-cpanel-openstack-20220414.qcow2"
create_template 9113 "temp-cloudlinux-610-cpanel" "cloudlinux-6.10-x86_64-cpanel-openstack-20220414.qcow2"
#  CloudLinux 6.10 x86_64 QEMU/KVM cloud image with Plesk 17.8.11 (build 20220412) [DEPRECATED] 
wget "https://download.cloudlinux.com/cloudlinux/images/cloudlinux-6.10-x86_64-plesk-openstack-20220412.qcow2"
create_template 9114 "temp-cloudlinux-610-plesk" "cloudlinux-6.10-x86_64-plesk-openstack-20220412.qcow2"


## A collection of prebuilt BSD cloud images
## These unofficial images are tested on OpenStack and NoCloud (with Virt-Lightning).
##  They come with Cloud-init, and so they should support all the main Cloud providers.

## freebsd
# freebsd 13.3 ufs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/13.3/2024-05-06/ufs/freebsd-13.3-ufs-2024-05-06.qcow2"
create_template 9501 "freebsd-13.3-ufs-2024-05-06.qcow2"
# freebsd 13.3 zfs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/13.3/2024-05-06/zfs/freebsd-13.3-zfs-2024-05-06.qcow2"
create_template 9502 "freebsd-13.3-zfs-2024-05-06.qcow2"
# freebsd 14.0 ufs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/14.0/2024-05-04/ufs/freebsd-14.0-ufs-2024-05-04.qcow2"
create_template 9503 "freebsd-14.0-ufs-2024-05-04.qcow2"
# freebsd 14.0 zfs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/14.0/2024-05-06/zfs/freebsd-14.0-zfs-2024-05-06.qcow2"
create_template 9504 "freebsd-14.0-zfs-2024-05-06.qcow2"

# NetBSD 
# NetBSD 8.2 
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/netbsd/8.2/netbsd-8.2.qcow2"
create_template 9511 "netbsd-8.2.qcow2"
# NetBSD 9.3
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/netbsd/9.3/2023-04-23/ufs/netbsd-9.3-2023-04-23.qcow2"
create_template 9512 "netbsd-9.3-2023-04-23.qcow2"

# OpenBSD 7.4
wget "https://github.com/hcartiaux/openbsd-cloud-image/releases/download/v7.4_2024-05-15-16-35/openbsd-min.qcow2"
create_template 9521 "openbsd-min.qcow2"
# OpenBSD 7.5
wget "https://github.com/hcartiaux/openbsd-cloud-image/releases/download/v7.5_2024-05-13-15-25/openbsd-min.qcow2"
create_template 9522 "openbsd-min.qcow2"

# DragonFlyBSD 6.2.2 ufs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/dragonflybsd/6.2.2/2022-09-06/ufs/dragonflybsd-6.2.2-ufs-2022-09-06.qcow2"
create_template 9531 "dragonflybsd-6.2.2-ufs-2022-09-06.qcow2"
# DragonFlyBSD 6.2.2 Hammer2 file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/dragonflybsd/6.2.2/2022-09-06/hammer2/dragonflybsd-6.2.2-hammer2-2022-09-06.qcow2"
create_template 9532 "dragonflybsd-6.2.2-hammer2-2022-09-06.qcow2"
# DragonFlyBSD 6.4.0 ufs file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/dragonflybsd/6.4.0/2023-04-23/ufs/dragonflybsd-6.4.0-ufs-2023-04-23.qcow2"
create_template 9533 "dragonflybsd-6.4.0-ufs-2023-04-23.qcow2"
# DragonFlyBSD 6.4.0 hammer2 file system
wget "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/dragonflybsd/6.4.0/2023-04-23/hammer2/dragonflybsd-6.4.0-hammer2-2023-04-23.qcow2"
create_template 9534 "dragonflybsd-6.4.0-hammer2-2023-04-23.qcow2"

## Collection of Windows prebuilt 
## Download Windows Server 2012 R2 Standard Evaluation for OpenStack
https://cloudbase.it/euladownload.php?h=kvm/

## whonix
# whonix latest
wget "https://download.whonix.org/libvirt/17.2.0.1/Whonix-Xfce-17.2.0.1.Intel_AMD64.qcow2.libvirt.xz"
xz -d -v Whonix-Xfce-17.2.0.1.Intel_AMD64.qcow2.libvirt.xz
create_template 9601 "temp-whonix" "Whonix-Xfce-17.2.0.1.Intel_AMD64.qcow2"

## Plesk
# Plesk almalinux 9.18
wget "https://autoinstall.plesk.com/images/plesk-almalinux-9-18.0.62.qcow2"
create_template 9611 "temp-plesk-alma-918" "plesk-almalinux-9-18.0.62.qcow2"
# Plesk almalinux 9 latest
wget "https://autoinstall.plesk.com/images/plesk-almalinux-9-latest.qcow2"
create_template 9612 "temp-plesk-alma-9" "plesk-almalinux-9-latest.qcow2"
# Plesk almalinux latest
wget "https://autoinstall.plesk.com/images/plesk-almalinux-latest.qcow2"
create_template 9613 "temp-plesk-alma" "plesk-almalinux-latest.qcow2"
# Plesk centos 7.18
wget "https://autoinstall.plesk.com/images/plesk-centos-7-18.0.54.qcow2"
create_template 9614 "temp-plesk-centos-718" "plesk-centos-7-18.0.54.qcow2"
# Plesk centos 7 latest
wget "https://autoinstall.plesk.com/images/plesk-centos-7-latest.qcow2"
create_template 9615 "temp-plesk-centos-7" "plesk-centos-7-latest.qcow2"
# Plesk centos latest
wget "https://autoinstall.plesk.com/images/plesk-centos-latest.qcow2"
create_template 9616 "temp-plesk-centos" "plesk-centos-latest.qcow2"
# Plesk ubuntu 22-18
wget "https://autoinstall.plesk.com/images/plesk-ubuntu-22-18.0.62.qcow2"
create_template 9617 "temp-plesk-ubuntu-22-18" "plesk-ubuntu-22-18.0.62.qcow2"
# Plesk ubuntu 22 latest
wget "https://autoinstall.plesk.com/images/plesk-ubuntu-22-latest.qcow2"
create_template 9618 "temp-plesk-ubuntu-22" "plesk-ubuntu-22-latest.qcow2"
# Plesk ubuntu latest
wget "https://autoinstall.plesk.com/images/plesk-ubuntu-latest.qcow2"
create_template 9619 "temp-plesk-ubuntu" "plesk-ubuntu-latest.qcow2"

## apache cloudstack
# apache cloudstack 4.15
wget "http://download.cloudstack.org/systemvm/4.15/systemvmtemplate-4.15.0-kvm.qcow2.bz2"
xz -d -v systemvmtemplate-4.15.0-kvm.qcow2.bz2
create_template 9621 "temp-apache-cloudstack" "systemvmtemplate-4.15.0-kvm.qcow2"

## Open Build Service
# openbuildservice latest
wget "https://download.opensuse.org/repositories/OBS:/Server:/2.10/images/obs-server.x86_64-qcow2.qcow2"
create_template 9624 "temp-obs-latest" "obs-server.x86_64-qcow2.qcow2"

## Home Assistant OS 
## HAOS 12.4
wget "https://github.com/home-assistant/operating-system/releases/download/12.4/haos_ova-12.4.qcow2.xz"
xz -d -v haos_ova-12.4.qcow2.xz
create_template 9625 "temp-HAOS" "haos_ova-12.4.qcow2"

## Cirros
## CirrOS is a minimal Linux distribution that was designed for use as a test image on clouds such as OpenStack Compute.
wget "https://download.cirros-cloud.net/0.6.2/cirros-0.6.2-x86_64-disk.img"
qemu-img convert -f qcow2 -O raw ccirros-0.6.2-x86_64-disk.img cirros-0.6.2-x86_64-disk.raw
create_template 9626 "temp-cirros" "cirros-0.6.2-x86_64-disk.raw"

## Zabbix Appliance
wget "https://cdn.zabbix.com/zabbix/appliances/stable/7.0/7.0.1/zabbix_appliance-7.0.1-qcow2.tar.gz"
xz -d -v zabbix_appliance-7.0.1-qcow2.tar.gz
create_template 9627 "temp-zabbix" "zabbix_appliance-7.0.1-qcow2"

## NethServer 8 provides an image built upon the stable foundation Rocky Linux 9
wget "https://distfeed.nethserver.org/ns8-images/ns8-rocky-linux-9-ns8-stable.qcow2"
create_template 9628 "temp-NethServer" "ns8-rocky-linux-9-ns8-stable.qcow2"

## Sophos Firewall
wget "https://download.sophos.com/network/SophosFirewall/installers/VI-20.0.1_MR-1.KVM-342.zip"
unzip VI-20.0.1_MR-1.KVM-342.zip
create_template 9631 "temp-sophos" "VI-20.0.1_MR-1.KVM-342.qcow2"

