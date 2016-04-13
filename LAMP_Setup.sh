#!/bin/bash

: 'configure httpd.conf for php' && {
    sudo sed \
        -i \
        -e 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/g' \
        -e '$aLoadModule mpm_prefork_module modules/mod_mpm_prefork.so' \
        -e '$aLoadModule php7_module modules/libphp7.so' \
        -e '$aInclude conf/extra/php7_module.conf' \
        /etc/httpd/conf/httpd.conf
}

: 'deploy sample php file' && {
    sudo tee /srv/http/index.php << EOF >/dev/null
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
    sudo sed \
        -i \
        -e '$aextension=pdo_mysql.so' \
        -e '$aextension=mysqli.so' \
        /etc/php/php.ini
}

: 'configure phpmyadmin' && {
    sudo sed \
        -i \
        -e '$aextension=mcrypt.so' \
        /etc/php/php.ini
    sudo tee /etc/httpd/conf/extra/phpmyadmin.conf << EOF >/dev/null
        Alias /phpmyadmin "/usr/share/webapps/phpMyAdmin"
        <Directory "/usr/share/webapps/phpMyAdmin">
            DirectoryIndex index.php
            AllowOverride All
            Options FollowSymlinks
            Require all granted
        </Directory>
EOF
    sudo sed \
        -i \
        -e '$aInclude conf/extra/phpmyadmin.conf' \
        /etc/httpd/conf/httpd.conf
}

: 'enable & start service' && {
    sudo systemctl enable httpd
    sudo systemctl enable mysqld.service
    sudo systemctl start httpd
    sudo systemctl start mysqld.service
}
