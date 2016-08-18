FROM gabrieltakacs/alpine:latest
MAINTAINER Gabriel Takács <gtakacs@gtakacs.sk>

# Install nginx
RUN apk add nginx supervisor

# Install PHP 5.6
RUN apk --no-cache --update --repository=http://dl-4.alpinelinux.org/alpine/edge/testing add \
    php5 \
    php5-fpm \
    php5-xml \
    php5-pgsql \
    php5-mysqli \
    php5-pdo_mysql \
    php5-mcrypt \
    php5-opcache \
    php5-gd \
    php5-curl \
    php5-json \
    php5-phar \
    php5-openssl \
    php5-ctype \
    php5-mbstring \
    php5-zip \
    php5-dev \
    php5-xdebug

# Install composer
ENV COMPOSER_HOME=/composer
RUN mkdir /composer \
    && curl -sS https://getcomposer.org/installer | php \
    && mkdir -p /opt/composer \
    && mv composer.phar /opt/composer/composer.phar

# php5-fpm configuration
RUN adduser -s /sbin/nologin -D -G www-data www-data
COPY php5/php-fpm.conf /etc/php5/php-fpm.conf
COPY php5/php.ini /etc/php5/php.ini

# Configure xdebug
#RUN echo 'zend_extension="/usr/lib/php7/modules/xdebug.so"' >> /etc/php7/php.ini \
#    && echo "xdebug.remote_enable=on" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_autostart=off" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_connect_back=0" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_port=9001" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_handler=dbgp" >> /etc/php7/php.ini \
#    && echo "xdebug.remote_host=192.168.65.1" >> /etc/php7/php.ini
    # (Only for MAC users) Fill IP address from:
    # cat /Users/gtakacs/Library/Containers/com.docker.docker/Data/database/com.docker.driver.amd64-linux/slirp/host
    # Source topic on Docker forums: https://forums.docker.com/t/ip-address-for-xdebug/10460/22

# Copy Supervisor config file
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add nginx configuration files
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir /etc/nginx/vhosts

# Add run file
COPY run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 80 443

CMD ["/run.sh"]
