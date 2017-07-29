#!/bin/sh
echo " Instalando dependencias"
sleep 3
apt-get update
apt-get install -y build-essential bin86 kernel-package libqt4-dev wget libncurses5 libncurses5-dev qt4-dev-tools libqt4-dev zlib1g-dev gcc-arm-linux-gnueabihf git debootstrap u-boot-tools device-tree-compiler libusb-1.0-0-dev android-tools-adb android-tools-fastboot qemu-user-static
echo " Creando imagen"
sleep 3
dd if=/dev/zero of=rootfs.img bs=1 count=0 seek=3000M
mkfs.ext4 -b 4096 -F rootfs.img
mount -o loop rootfs.img /mnt
echo "Iniciando proceso deboostrap"
sleep 3
debootstrap --arch=armhf --foreign trusty /mnt
cp /usr/bin/qemu-arm-static /mnt/usr/bin
cp /etc/resolv.conf /mnt/etc
> config.sh
cat <<+ > config.sh
#!/bin/sh
echo " Configurando debootstrap segunda fase"
sleep 3
/debootstrap/debootstrap --second-stage
export LANG=C
echo "deb http://ports.ubuntu.com/ trusty main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Europe/Berlin" > /etc/timezone
echo "TableX" >> /etc/hostname
echo "127.0.0.1 TableX localhost
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" >> /etc/hosts
echo "auto lo
iface lo inet loopback" >> /etc/network/interfaces
echo "/dev/mmcblk0p1 /	   ext4	    errors=remount-ro,noatime,nodiratime 0 1" >> /etc/fstab
echo "tmpfs    /tmp        tmpfs    nodev,nosuid,mode=1777 0 0" >> /etc/fstab
echo "tmpfs    /var/tmp    tmpfs    defaults    0 0" >> /etc/fstab
sync			
cat <<END > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
END

apt-get update
apt-get upgrade -y
apt-get install -y locales dialog software-properties-common makedev isc-dhcp-client ubuntu-minimal ssh cifs-utils screen gedit wireless-tools iw curl libncurses5-dev cpufrequtils rcs aptitude make bc lzop man-db ntp usbutils pciutils lsof most sysfsutils linux-firmware git build-essential autoconf libtool debhelper dh-autoreconf fakeroot pkg-config automake xutils-dev libx11-dev libxext-dev libdrm-dev x11proto-dri2-dev libxfixes-dev lubuntu-desktop onboard vlc
echo "Reconfigurando parametros locales"
sleep 3
locale-gen en_GB.UTF-8
locale-gen es_ES.UTF-8
export LC_ALL="es_ES.UTF-8"
update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
dpkg-reconfigure -f noninteractive tzdata
passwd
exit
+
chmod +x config.sh 
cp config.sh /mnt/home
echo "Montando directorios"
sleep 3
sudo mount -o bind /dev /mnt/dev
sudo mount -o bind /dev/pts /mnt/dev/pts
sudo mount -t sysfs /sys /mnt/sys
sudo mount -t proc /proc /mnt/proc
chroot /mnt /usr/bin/qemu-arm-static /bin/sh -i ./home/config.sh && umount && /mnt/{sys,proc,dev/pts,dev}
exit
