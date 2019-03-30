#!/bin/sh

cat /dev/urandom | tr -dc 'a-zA-Z0-9_' | fold -w 43 | head -n 1 > /root/LFS_JWT_SECRET
cat /dev/urandom | tr -dc 'a-zA-Z0-9_' | fold -w 43 | head -n 1 > /root/SECRET_KEY

LFS_JWT_SECRET=`cat /root/LFS_JWT_SECRET`
SECRET_KEY=`cat /root/SECRET_KEY`

# Read MySQL Config
DB=`cat /root/dbname`
USER=`cat /root/dbuser`
PASS=`cat /root/dbpassword`

CFG=/usr/local/etc/gitea/conf/app.ini

sed -i .bak -e "s/DBNAME/${DB}/" ${CFG}
sed -i .bak -e "s/DBUSER/${USER}/" ${CFG}
sed -i .bak -e "s/DBPASS/${PASS}/" ${CFG}

sed -i .bak -e "s/ChangeMeBeforeRunning/${SECRET_KEY}/" ${CFG}
sed -i .bak -e "s/LFS_JWT_SECRET_PLACEHOLDER/${LFS_JWT_SECRET}/" ${CFG}

sysrc gitea_enable=yes
service gitea start
