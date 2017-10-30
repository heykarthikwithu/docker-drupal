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

##################### AEGIR
RUN apt-get update -qq && apt-get install -y -qq\
  apache2 \
  openssl \
  php5 \
  php5-cli \
  php5-gd \
  php5-mysql \
  php-pear \
  php5-curl \
  postfix \
  sudo \
  rsync \
  git-core \
  unzip \
  wget \
  mysql-client
ENV AEGIR_UID 1000 RUN echo "Creating user aegir with UID $AEGIR_UID and GID $AEGIR_GID"
RUN addgroup --gid $AEGIR_UID aegir
RUN adduser --uid $AEGIR_UID --gid $AEGIR_UID --system --home /var/aegir aegir
RUN adduser aegir www-data
RUN a2enmod rewrite
RUN a2enmod ssl
RUN ln -s /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf
RUN ln -s /etc/apache2/conf-available/aegir.conf /etc/apache2/conf-enabled/aegir.conf
COPY sudoers-aegir /etc/sudoers.d/aegir
RUN chmod 0440 /etc/sudoers.d/aegir
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- --quiet
RUN cp composer.phar /usr/local/bin/composer
RUN wget https://github.com/drush-ops/drush/releases/download/8.1.12/drush.phar -O - -q > /usr/local/bin/drush
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/drush
# Install fix-permissions and fix-ownership scripts
RUN wget http://cgit.drupalcode.org/hosting_tasks_extra/plain/fix_permissions/scripts/standalone-install-fix-permissions-ownership.sh
RUN bash standalone-install-fix-permissions-ownership.sh
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
COPY run-tests.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-tests.sh
#COPY docker-entrypoint-tests.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/docker-entrypoint-tests.sh
COPY docker-entrypoint-queue.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-queue.sh
# Prepare Aegir Logs folder.
RUN mkdir /var/log/aegir
RUN chown aegir:aegir /var/log/aegir
RUN echo 'Hello, Aegir.' > /var/log/aegir/system.log
# Don't install provision. Downstream tags will do this with the right version.
## Install Provision for all.
#ENV PROVISION_VERSION 7.x-3.x
#RUN mkdir -p /usr/share/drush/commands
#RUN drush dl --destination=/usr/share/drush/commands provision-$PROVISION_VERSION -y
ENV REGISTRY_REBUILD_VERSION 7.x-2.5
RUN drush dl --destination=/usr/share/drush/commands registry_rebuild-$REGISTRY_REBUILD_VERSION -y
USER aegir
RUN mkdir /var/aegir/config
RUN mkdir /var/aegir/.drush
# You may change this environment at run time. User UID 1 is created with this email address.
ENV AEGIR_CLIENT_EMAIL aegir@aegir.local.computer
ENV AEGIR_CLIENT_NAME admin
ENV AEGIR_PROFILE hostmaster
ENV AEGIR_VERSION 7.x-3.x
ENV PROVISION_VERSION 7.x-3.x
ENV AEGIR_WORKING_COPY 0
# Must be fixed across versions so we can upgrade containers.
ENV AEGIR_HOSTMASTER_ROOT /var/aegir/hostmaster
WORKDIR /var/aegir
# The Hostname of the database server to use
ENV AEGIR_DATABASE_SERVER database
# For dev images (7.x-3.x branch)
ENV AEGIR_MAKEFILE http://cgit.drupalcode.org/provision/plain/aegir.make
# For Releases:
# ENV AEGIR_MAKEFILE http://cgit.drupalcode.org/provision/plain/aegir-release.make?h=$AEGIR_VERSION
VOLUME /var/aegir
# docker-entrypoint.sh waits for mysql and runs hostmaster install
ENTRYPOINT ["docker-entrypoint.sh"]
##################### AEGIR

CMD ["/docker-utils/scripts/start-services.sh", "drush", "@hostmaster", "hosting-queued"]
