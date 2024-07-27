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
create_template 900 "temp-debian-10" "debian-10-genericcloud-amd64.qcow2"
#Debian Bullseye (11) (oldstable)
wget "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
create_template 901 "temp-debian-11" "debian-11-genericcloud-amd64.qcow2" 
#Debian Bookworm (12) (stable)
wget "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
create_template 902 "temp-debian-12" "debian-12-genericcloud-amd64.qcow2"
#Debian Trixie (13) (testing) dailies
wget "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-genericcloud-amd64-daily.qcow2"
create_template 903 "temp-debian-13-daily" "debian-13-genericcloud-amd64-daily.qcow2"
#Debian Sid (unstable)
wget "https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-genericcloud-amd64-daily.qcow2"
create_template 909 "temp-debian-sid" "debian-sid-genericcloud-amd64-daily.qcow2" 

## Ubuntu
#Ubuntu 20.04 (Focal Fossa) LTS
wget "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
create_template 910 "temp-ubuntu-20-04" "ubuntu-20.04-server-cloudimg-amd64.img" 
#Ubuntu 22.04 (Jammy Jellyfish) LTS
wget "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
create_template 911 "temp-ubuntu-22-04" "ubuntu-22.04-server-cloudimg-amd64.img" 
#Ubuntu 23.10 (Manic Minotaur)
wget "https://cloud-images.ubuntu.com/releases/23.10/release/ubuntu-23.10-server-cloudimg-amd64.img"
create_template 912 "temp-ubuntu-23-10" "ubuntu-23.10-server-cloudimg-amd64.img"
#As 23.10 has *just released*, the next LTS (24.04) is not in dailies yet

## Fedora 37
#Image is compressed, so need to uncompress first
wget "https://download.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/x86_64/images/Fedora-Cloud-Base-37-1.7.x86_64.raw.xz"
xz -d -v Fedora-Cloud-Base-37-1.7.x86_64.raw.xz
create_template 920 "temp-fedora-37" "Fedora-Cloud-Base-37-1.7.x86_64.raw"
## Fedora 38
wget "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.raw.xz"
xz -d -v Fedora-Cloud-Base-38-1.6.x86_64.raw.xz
create_template 921 "temp-fedora-38" "Fedora-Cloud-Base-38-1.6.x86_64.raw"

## Rocky Linux
#Rocky 8 latest
wget "http://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud.latest.x86_64.qcow2"
create_template 930 "temp-rocky-8" "Rocky-8-GenericCloud.latest.x86_64.qcow2"
#Rocky 9 latest
wget "http://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
create_template 931 "temp-rocky-9" "Rocky-9-GenericCloud.latest.x86_64.qcow2"

## Alpine Linux
#Alpine 3.19.1
wget "https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/cloud/nocloud_alpine-3.19.1-x86_64-bios-cloudinit-r0.qcow2"
create_template 940 "temp-alpine-3.19" "nocloud_alpine-3.19.1-x86_64-bios-cloudinit-r0.qcow2"

#Almalinux 8 latest
wget "https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
create_template 950 "temp-almalinux-8" "AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
#AlmaLinux 9 latest
wget "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
create_template 951 "temp-almalinux-9" "AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"

## Centos
#Centos 6 latest
wget "https://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2"
create_template 960 "temp-centos-6" "CentOS-6-x86_64-GenericCloud.qcow2"
#Centos 7 latest
wget "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
create_template 961 "temp-centos-7" "CentOS-7-x86_64-GenericCloud.qcow2"
#Centos 8-stream latest
wget "https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
create_template 962 "temp-centos-8-stream" "CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2"
#Centos 8 latest
wget "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
create_template 963 "temp-centos-8" "CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
#Centos 9-stream latest
wget "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2"
create_template 964 "temp-centos-9-stream" "CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2"

## Plesk
# Plesk almalinux 9.18
wget "https://autoinstall.plesk.com/images/plesk-almalinux-9-18.0.62.qcow2"
create_template 970 "temp-plesk-alma-918" "plesk-almalinux-9-18.0.62.qcow2"
# Plesk almalinux 9 latest
wget "https://autoinstall.plesk.com/images/plesk-almalinux-9-latest.qcow2"
create_template 971 "temp-plesk-alma-9" "plesk-almalinux-9-latest.qcow2"
# Plesk almalinux latest
wget "https://autoinstall.plesk.com/images/plesk-almalinux-latest.qcow2"
create_template 972 "temp-plesk-alma" "plesk-almalinux-latest.qcow2"
# Plesk centos 7.18
wget "https://autoinstall.plesk.com/images/plesk-centos-7-18.0.54.qcow2"
create_template 973 "temp-plesk-centos-718" "plesk-centos-7-18.0.54.qcow2"
# Plesk centos 7 latest
wget "https://autoinstall.plesk.com/images/plesk-centos-7-latest.qcow2"
create_template 974 "temp-plesk-centos-7" "plesk-centos-7-latest.qcow2"
# Plesk centos latest
wget "https://autoinstall.plesk.com/images/plesk-centos-latest.qcow2"
create_template 975 "temp-plesk-centos" "plesk-centos-latest.qcow2"
# Plesk ubuntu 22-18
wget "https://autoinstall.plesk.com/images/plesk-ubuntu-22-18.0.62.qcow2"
create_template 976 "temp-plesk-ubuntu-22-18" "plesk-ubuntu-22-18.0.62.qcow2"
# Plesk ubuntu 22 latest
wget "https://autoinstall.plesk.com/images/plesk-ubuntu-22-latest.qcow2"
create_template 977 "temp-plesk-ubuntu-22" "plesk-ubuntu-22-latest.qcow2"
# Plesk ubuntu latest
wget "https://autoinstall.plesk.com/images/plesk-ubuntu-latest.qcow2"
create_template 978 "temp-plesk-ubuntu" "plesk-ubuntu-latest.qcow2"


