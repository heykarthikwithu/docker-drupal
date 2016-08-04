FROM debian:jessie
MAINTAINER Karthik Kumar D K <heykarthikwithu@gmail.com>

# update the package sources

RUN apt-get update --fix-missing && apt-get install -y curl wget git htop supervisor vim openssh-server software-properties-common

ADD docker-utils/php5/linode.list /etc/apt/sources.list.d/
ADD docker-utils/nginx/nginx.list /etc/apt/sources.list.d/

RUN wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key && apt-key update && apt-get update --fix-missing

# we use the enviroment variable to stop debconf from asking questions..
RUN apt-get install -y mysql-client php5 php5-cli php5-common php5-gd php5-mcrypt php5-fpm php5-curl php5-memcached php5-xdebug php5-xhprof php5-mysql php-pear apache2 nginx libapache2-mod-fastcgi

RUN a2enmod rewrite headers fastcgi actions

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/compose

RUN php -r "readfile('http://files.drush.org/drush.phar');" > drush && chmod +x drush && mv drush /usr/bin/

RUN wget https://phar.phpunit.de/phpunit.phar && chmod +x phpunit.phar && mv phpunit.phar /usr/bin/phpunit

RUN wget -O mailhog https://github.com/mailhog/MailHog/releases/download/v0.2.0/MailHog_linux_amd64 && chmod +x mailhog && mv mailhog /usr/bin/
RUN wget -O mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 && chmod +x mhsendmail && mv mhsendmail /usr/bin/

# package install is finished, clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# install custom config files
ADD docker-utils/nginx/conf.d/*.conf /etc/nginx/conf.d/
ADD docker-utils/nginx/ssl/ /etc/nginx/ssl/
ADD docker-utils/php5/php.ini /etc/php5/fpm/php.ini
ADD docker-utils/php5/20-xdebug.ini /etc/php5/fpm/conf.d/20-xdebug.ini
ADD docker-utils/apache2/ports.conf /etc/apache2/
ADD docker-utils/apache2/mods-enabled/*.conf /etc/apache2/mods-enabled/
ADD docker-utils/apache2/sites/* /etc/apache2/sites-enabled/
ADD docker-utils/supervisord/*.conf /etc/supervisor/conf.d/

ADD docker-utils/ /docker-utils/
RUN chmod u+x /docker-utils/scripts/*.sh

# Get rid of nginx and apache default site files
RUN rm -rf /etc/nginx/conf.d/default
RUN a2dissite 000-default

RUN mkdir -p /var/run/sshd
RUN mkdir -p ~/.ssh/

ADD docker-utils/drush/* ~/.drush/

# clean up tmp files (we don't need them for the image)
RUN rm -rf /tmp/* /var/tmp/*

CMD ["/docker-utils/scripts/start-services.sh"]
