
#!/bin/sh
mkdir /tmp/TableX
mount -t tmpfs none /tmp/TableX -o size=1024M
debootstrap --arch=armhf --foreign xenial /tmp/TableX
cp /usr/bin/qemu-arm-static /tmp/TableX/usr/bin
cp /etc/resolv.conf /tmp/TableX
> config.sh
cat <<+ > config.sh
#!/bin/sh
/debootstrap/debootstrap --second-stage
export LANG=C
echo "deb http://ports.ubuntu.com/ xenial main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Europe/Berlin" > /etc/timezone
echo TableX > /etc/hostname
echo "127.0.0.1       TableX localhost" >> /etc/hosts
cat <<END > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
apt-get update
apt-get -y upgrade -y
apt-get install -y locales software-properties-common -y isc-dhcp-client ubuntu-minimal ssh cifs-utils screen wireless-tools iw curl libncurses5-dev cpufrequtils rcs aptitude make bc lzop man-db ntp usbutils pciutils lsof most sysfsutils linux-firmware lxde

locale-gen en_GB.UTF-8
locale-gen es_ES.UTF-8
export LC_ALL="en_GB.UTF-8"
update-locale LC_ALL=en_GB.UTF-8 LANG=en_GB.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
dpkg-reconfigure -f noninteractive tzdata

END
+
chmod +x config.sh
cp config.sh /tmp/TableX/home
sudo mount -o bind /dev /tmp/TableX/dev
sudo mount -o bind /dev/pts /tmp/TableX/dev/pts
sudo mount -t sysfs /sys /tmp/TableX/sys
sudo mount -t proc /proc /tmp/TableX/proc
chroot /tmp/TableX /usr/bin/qemu-arm-static /bin/sh -i ./home/config.sh
exit
sudo tar -czvf Tablex.tar.gz  /tmp/TableX/ 
