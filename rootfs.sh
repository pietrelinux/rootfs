
#!/bin/sh
dd if=/dev/zero of=ubuntu.img bs=1MB count=0 seek=4096
mke2fs -F ubuntu.img
sudo mount -o loop ubuntu.img /mnt
debootstrap --arch=armhf --foreign trusty /mnt
cp /usr/bin/qemu-arm-static /mnt/usr/bin
cp /etc/resolv.conf /mnt/etc
> config.sh
cat <<+ > config.sh
#!/bin/sh
/debootstrap/debootstrap --second-stage
export LANG=C
echo "deb http://ports.ubuntu.com/ trusty main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Europe/Berlin" > /etc/timezone
echo TableX > /etc/hostname
echo "127.0.0.1       TableX localhost" >> /etc/hosts

apt-get update
apt-get -y upgrade -y
apt-get install -y locales software-properties-common -y isc-dhcp-client ubuntu-minimal ssh cifs-utils screen gedit wireless-tools iw curl libncurses5-dev cpufrequtils rcs aptitude make bc lzop man-db ntp usbutils pciutils lsof most sysfsutils linux-firmware lubuntu-desktop

locale-gen en_GB.UTF-8
locale-gen es_ES.UTF-8
export LC_ALL="en_GB.UTF-8"
update-locale LC_ALL=en_GB.UTF-8 LANG=en_GB.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
dpkg-reconfigure -f noninteractive tzdata
cat <<END > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
END
+

chmod +x config.sh
cp config.sh /mnt/home
sudo mount -o bind /dev /mnt/dev
sudo mount -o bind /dev/pts /mnt/dev/pts
sudo mount -t sysfs /sys /mnt/tmp/sys
sudo mount -t proc /proc /mnt/proc
chroot /mnt /usr/bin/qemu-arm-static /bin/sh -i ./home/config.sh
exit
umount /mnt
tar -czvf Tablex.tar.gz  ubuntu.img 
sudo umount /mnt/dev/pts
sudo umount /mnt/sys
sudo umount /mnt/proc
sudo umount /mnt/dev
sudo umount /mnt
