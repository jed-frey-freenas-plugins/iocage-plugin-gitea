#!/bin/sh

## MySQL
# Config
setenv CFG /usr/local/etc/mysql/my.cnf
cp ${CFG}.sample ${CFG}
sed -i .bak -e 's/^\[mysqld\]$/[mysqld]\\
skip-networking/' ${CFG}

echo "- MySQL Config Diff" >> ${LOG}
diff ${CFG} ${CFG}.sample >> ${LOG}


# Enable the service & disable networking.
echo "- Enable MySQL" >> ${LOG}
sysrc -f /etc/rc.conf mysql_enable="YES"
sysrc -f /etc/rc.conf mysql_args="--skip-networking"

# Start the service
echo "- Start MySQL" >> ${LOG}
service mysql-server start

USER="gitea"
DB="gitea"

# Save the config values
echo "$DB" > /root/dbname
echo "$USER" > /root/dbuser
export LC_ALL=C
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 > /root/dbpassword
PASS=`cat /root/dbpassword`

echo "Database User: $USER"
echo "Database Password: $PASS"

# Configure mysql
mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('${PASS}') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
CREATE USER '${USER}'@'localhost' IDENTIFIED BY '${PASS}';
CREATE DATABASE `${DB}` DEFAULT CHARACTER SET `utf8mb4` COLLATE `utf8mb4_unicode_ci`;
GRANT ALL PRIVILEGES ON *.* TO '${USER}'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB}.* TO '${USER}'@'localhost';
FLUSH PRIVILEGES;
EOF