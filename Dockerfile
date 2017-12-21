FROM php:7.1-fpm

ENV NGINX_VERSION 1.11.1

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    gcc \
    autoconf \
    automake \
    libtool \
    libpcre3 \
    libpcre3-dev \
    make \
    wget \
    unzip \
    git \
    cmake \
    python-pip \
  && rm -rf /var/lib/apt/lists/*


 

#Add user
RUN groupadd -r www && \
    useradd -M -s /sbin/nologin -r -g www www

#Download nginx & php
RUN mkdir -p /home/nginx-php && cd /home/nginx-php && \
    wget -c -O nginx.tar.gz http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz

#Make install nginx
RUN cd /home/nginx-php && \
    tar -zxvf nginx.tar.gz && \
    cd nginx-$NGINX_VERSION && \
    ./configure --prefix=/usr/local/nginx \
    --user=www --group=www \
    --error-log-path=/var/log/nginx_error.log \
    --http-log-path=/var/log/nginx_access.log \
    --pid-path=/var/run/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --with-http_gzip_static_module && \
    make && make install

# ADD ./php-fpm.conf /usr/local/php/etc/php-fpm.conf
# ADD ./www.conf /usr/local/php/etc/php-fpm.d/www.conf

ADD php.ini /usr/local/etc/php/php.ini

# Install zip extension
RUN docker-php-ext-install zip
# Install mb string exention
RUN docker-php-ext-install mbstring
# Install the PHP mcrypt extention
RUN docker-php-ext-install mcrypt
# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql
# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql
# Install the PHP gd library
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd
# Install mongo
RUN pecl install mongodb &&\
    echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/ext-mongodb.ini

RUN curl -s http://getcomposer.org/installer | php && mv ./composer.phar /usr/local/bin/composer

#Install supervisor
RUN easy_install supervisor && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /var/run/sshd && \
    mkdir -p /var/run/supervisord

#Add supervisord conf
ADD supervisord.conf /etc/supervisord.conf

#Remove zips
RUN cd / && rm -rf /home/nginx-php

#Create web folder
VOLUME ["/usr/local/nginx/conf/ssl", "/usr/local/nginx/conf/vhost"]
RUN mkdir -p /data/www && chown -R www:www /data/www

# ADD xdebug.ini /usr/local/php/etc/php.d/xdebug.ini

#Update nginx config
ADD nginx.conf /usr/local/nginx/conf/nginx.conf

#Start
ADD start.sh ./start.sh
RUN chmod +x ./start.sh

#Set port
EXPOSE 80 443

WORKDIR /data/www
ADD index.php /data/www/public
#Start it
ENTRYPOINT ["./start.sh"]
