#!/bin/bash
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;

 red='\e[1;31m'
               green='\e[0;32m'
               NC='\e[0m'
			   
               echo "Connect ocspanel.info..."
               sleep 1
               
			   echo "กำลังตรวจสอบ Permision..."
               sleep 1
               
			   echo -e "${green}ได้รับอนุญาตแล้ว...${NC}"
               sleep 1
			   
flag=0

if [ $USER != 'root' ]; then
	echo "คุณต้องเรียกใช้งานนี้เป็น root"
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;

if [[ -e /etc/debian_version ]]; then
	#OS=debian
	RCLOCAL='/etc/rc.local'
else
	echo "คุณไม่ได้เรียกใช้สคริปต์นี้ในระบบปฏิบัติการ Debian"
	exit
fi


# GO TO ROOT
cd

# text gambar
apt-get install boxes

# install lolcat
apt-get -y install ruby
gem install lolcat

clear
echo "
----------------------------------------------
[√] ยินดีต้อนรับเข้าสู่ : ระบบสคริป OcsSerNOoMzE
[√] Connect...
[√] Wellcome : กรุณาทำตามขั้นตอน... [ OK !! ]
----------------------------------------------
 " | lolcat
 sleep 3

MYIP=$(wget -qO- ipv4.icanhazip.com);

flag=0	

clear
echo "--------------- OCS PANELS INSTALLER FOR DEBIAN ---------------"

echo "         DEVELOPED BY SerNooMzE                 "
echo ""
echo ""
echo "ยินดีต้อนรับสู่ Osc Panel Auto Script : กรุณายืนยันการตั้งค่าต่าง ๆ ดังนี้"
echo "คุณสามารถใช้ข้อมูลของตัวเองได้เพียงแค่ กดลบ หรือ กด Enter ถ้าคุณเห็นด้วยกับข้อมูลของเรา"
echo ""
echo "1.ตั้งรหัสผ่านใหม่สำหรับ user root MySQL:"
read -p "Password baru: " -e -i 123456789 DatabasePass
echo ""
echo "2.ตั้งค่าชื่อฐานข้อมูลสำหรับ OCS Panels"
echo "โปรดใช้ตัวอัพษรปกติเท่านั้นห้ามมีอักขระพิเศษอื่นๆที่ไม่ใช่ขีดล่าง (_)"
read -p "Nama Database: " -e -i OCS_PANEL DatabaseName
echo ""
echo "ระบบ Ocs Script ต้องการ เราพร้อมที่จะติดตั้ง OCS"
read -n1 -r -p "กดปุ่ม Enter เพื่อดำเนินการต่อ ..."

apt-get remove --purge mysql\*
dpkg -l | grep -i mysql
apt-get clean

apt-get install -y libmysqlclient-dev mysql-client

service nginx stop
service php5-fpm stop
service php5-cli stop

apt-get -y --purge remove nginx php5-fpm php5-cli

#apt-get update
apt-get update -y

apt-get install build-essential expect -y

apt-get install -y mysql-server

#mysql_secure_installation
so1=$(expect -c "
spawn mysql_secure_installation; sleep 3
expect \"\";  sleep 3; send \"\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect eof; ")
echo "$so1"
#\r
#Y
#pass
#pass
#Y
#Y
#Y
#Y

chown -R mysql:mysql /var/lib/mysql/
chmod -R 755 /var/lib/mysql/

apt-get install -y nginx php5 php5-fpm php5-cli php5-mysql php5-mcrypt


# Install Web Server
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default

wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/sernoomze/Ocs-web/master/nginx.conf"
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/sernoomze/Ocs-web/master/vps.conf"
sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/fpm/php.ini
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf

mkdir -p /home/vps/public_html

useradd -m vps

mkdir -p /home/vps/public_html
echo "<?php phpinfo() ?>" > /home/vps/public_html/info.php
chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html

service php5-fpm restart
service nginx restart

#mysql -u root -p
so2=$(expect -c "
spawn mysql -u root -p; sleep 3
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"CREATE DATABASE IF NOT EXISTS $DatabaseName;EXIT;\r\"
expect eof; ")
echo "$so2"
#pass
#CREATE DATABASE IF NOT EXISTS OCS_PANEL;EXIT;

apt-get -y update && apt-get -y upgrade

apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python
wget https://prdownloads.sourceforge.net/webadmin/webmin_1.920_all.deb
dpkg --install webmin_1.920_all.deb
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf

rm -f webmin_1.920_all.deb

/usr/share/webmin/changepass.pl /etc/webmin root ninjanum

service webmin restart

apt-get -y --force-yes -f install libxml-parser-perl

echo "unset HISTFILE" >> /etc/profile


apt-get -y install zip unzip

cd /home/vps/public_html

rm -f index.html

wget https://raw.githubusercontent.com/sernoomze/Ocs-web/master/DeathSide_ocS.zip

unzip DeathSide_ocS.zip

rm -f DeathSide_ocS.zip


chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html


chmod 777 /home/vps/public_html/system/config
chmod 777 /home/vps/public_html/system/config/database-app.php
chmod 777 /home/vps/public_html/system/config/route.php

clear
echo ""
echo "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-"
echo ""
echo "เปิดเบราว์เซอร์และเข้าถึงที่อยู่ http://$MYIP และกรอกข้อมูล 2 ด้านล่าง!"
echo "Database:"
echo "- Database Host: localhost"
echo "- Database Name: $DatabaseName"
echo "- Database User: root"
echo "- Database Pass: $DatabasePass"
echo ""
echo "Admin Login:"
echo "- Username: ตั้งชื่อตามต้องการ"
echo "- Password New: ตั้ง pass ตามต้องการ"
echo "- Confirm Password New: ยืนยัน pass"
echo ""
echo "นำข้อมูลไปติดตั้งที่ Browser และรอให้เสร็จสิ้นจากนั้นปิด Browser และกลับมาที่นี่ (Putty) แล้วกด [ENTER]!"

sleep 3
echo ""
read -p "หากขั้นตอนข้างต้นเสร็จสิ้นโปรดกดปุ่ม [Enter] เพื่อดำเนินการต่อ ..."
echo ""

sleep 3
clear
echo "
----------------------------------------------
 Source : OcsSerNOoMzE
sleep 2
[√] กำลังเริ่มตรวจสอบ Mysql ..... [ OK !! ]
sleep 2
[√] กำลังเริ่มตรวจสอบ nginx ..... [ OK !! ]
sleep 2
[√] กำลังเริ่มตรวจสอบ webmin ..... [ OK !! ]
sleep 2
[√] กำลังเริ่มตรวจสอบ DeathSide_ocS ..... [ OK !! ]
sleep 2
[√] กำลังเริ่มตรวจสอบระบบ ..... [ OK !! ]
----------------------------------------------
 
sleep 4
# info
clear
echo "================ การติดตั้งเสร็จสิ้น พร้อมใช้งาน ================" | tee -a log-install.txt
echo "กรุณาเข้าสู่ระบบ OCS Panel ที่ http://$MYIP" | tee -a log-install.txt

echo "" | tee -a log-install.txt
#echo "บันทึกการติดตั้ง --> /root/log-install.txt" | tee -a log-install.txt
#echo "" | tee -a log-install.txt
echo "โปรดรีบูต VPS ของคุณ!" | tee -a log-install.txt
echo "=========================================================" | tee -a log-install.txt
cd ~/
