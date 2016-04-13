#!/bin/bash

: 'configure httpd.conf for php' && {
    sudo sed -i \
        -e 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/g' \
        /etc/httpd/conf/httpd.conf
    sudo tee -a /etc/httpd/conf/httpd.conf <<-EOF > /dev/null
        LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
        LoadModule php7_module modules/libphp7.so
        Include conf/extra/php7_module.conf
	EOF
}

: 'deploy sample php file' && {
    sudo tee /srv/http/index.php <<-EOF >/dev/null
        <?php
            phpinfo();
	EOF
    sudo chmod 644 /srv/http/index.php
}

: 'install composer' && {
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo sed \
        -i \
        -e '$aextension=intl.so' \
        /etc/php/php.ini
}

: 'setup mysql' && {
    sudo mysql_install_db \
        --user=mysql \
        --basedir=/usr \
        --datadir=/var/lib/mysql
}

: 'setup mysql root password' && {
    sudo systemctl start mysqld.service
    mysql -u root -e "delete from mysql.user where host <> 'localhost' or user <> 'root';"
    mysql -u root -e "SET PASSWORD FOR root@localhost=PASSWORD('root');"
    sudo systemctl stop mysqld.service
}

: 'add mysql settings to php.ini' && {
    sudo tee -a /etc/php/php.ini <<-EOF > /dev/null
        extension=pdo_mysql.so
        extension=mysqli.so
	EOF
}

: 'configure phpmyadmin' && {
    sudo tee -a /etc/php/php.ini <<-EOF > /dev/null
        extension=mcrypt.so
	EOF
    sudo tee /etc/httpd/conf/extra/phpmyadmin.conf <<-EOF >/dev/null
        Alias /phpmyadmin "/usr/share/webapps/phpMyAdmin"
        <Directory "/usr/share/webapps/phpMyAdmin">
            DirectoryIndex index.php
            AllowOverride All
            Options FollowSymlinks
            Require all granted
        </Directory>
	EOF
    sudo tee -a /etc/httpd/conf/httpd.conf <<-EOF > /dev/null
        Include conf/extra/phpmyadmin.conf
	EOF
}

: 'enable & start service' && {
    sudo systemctl enable httpd
    sudo systemctl enable mysqld.service
    sudo systemctl start httpd
    sudo systemctl start mysqld.service
}
