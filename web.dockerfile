FROM ubuntu:16.04

MAINTAINER quangpm@rikkeisoft.com
ENV DEBIAN_FRONTEND noninteractive
ENV http_proxy 'http://192.168.1.2:3128'
ENV https_proxy 'https://192.168.1.2:3128'

# Install, PHP
RUN apt-get clean && apt-get -y update && apt-get install -y locales curl software-properties-common git \
  && locale-gen en_US.UTF-8
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y --force-yes php7.1-bcmath php7.1-bz2 php7.1-cli php7.1-common php7.1-curl \
    php7.1-cgi php7.1-dev php7.1-fpm php7.1-gd php7.1-gmp php7.1-imap php7.1-intl \
    php7.1-json php7.1-ldap php7.1-mbstring php7.1-mcrypt php7.1-mysql \
    php7.1-odbc php7.1-opcache php7.1-pgsql php7.1-phpdbg php7.1-pspell \
    php7.1-readline php7.1-recode php7.1-soap php7.1-sqlite3 \
    php7.1-tidy php7.1-xml php7.1-xmlrpc php7.1-xsl php7.1-zip \
    php-tideways php-mongodb

RUN apt-get update

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN apt-get update

# Install web server nginx and supervisor for start service
RUN apt-get -y install nginx supervisor

RUN apt-get update

# Install "php-curl"
RUN apt-get -y install php-curl

# Install npm and nodejs
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

#BEGIN Configure cron job
RUN apt-get update && apt-get -y install cron

RUN touch /etc/cron.d/cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/cron

# Apply cron job
RUN crontab /etc/cron.d/cron

# Start service cron
RUN service cron start
#END Configure cron job

WORKDIR /var/www/html

# Expose apache.
EXPOSE 80 443

ADD conf.d/startup.sh /usr/bin/startup.sh
RUN chmod +x /usr/bin/startup.sh

COPY conf.d/default.conf /etc/nginx/sites-available/default
COPY conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Default command
CMD ["/bin/bash", "/usr/bin/startup.sh"]
