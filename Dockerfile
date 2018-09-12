FROM php:7.2-fpm-alpine

RUN apk add --update --no-cache \
        zlib \
        libjpeg-turbo-dev \
        libpng-dev \
        freetype-dev \
        libmcrypt-dev \
		openssl-dev \
		autoconf \
		g++ \
		gcc \
		make
        
# GD,PDOMYSQL,ZIP
RUN docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2

RUN	docker-php-ext-install gd \
                    pdo_mysql \
                    zip

# Mcrypt:
RUN pecl install mcrypt-1.0.1 \ 
	&& docker-php-ext-enable mcrypt

# MongoDB:
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb
	
# XDEBUG
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-2.6.1 \
    && docker-php-ext-enable xdebug

ADD ./php.ini /usr/local/etc/php/conf.d
ADD ./php.pool.conf /usr/local/etc/php-fpm.d/

WORKDIR /var/www/html
ADD index.php /var/www/html/public/index.php
RUN deluser www-data && adduser -D -H -u 1000 -s /bin/bash www-data

#install composer
RUN curl -s http://getcomposer.org/installer | php && mv ./composer.phar /usr/local/bin/composer

#install nginx
RUN apk add nginx
COPY nginx.conf /etc/nginx/nginx.conf

#supervisor
RUN apk add --update --no-cache --virtual .build-dep \
	python \
	py-pip \
	&& pip install supervisor

RUN mkdir -p /var/log/supervisor && \
    mkdir -p /var/run/sshd && \
    mkdir -p /var/run/supervisord

ADD supervisord.conf /etc/supervisord.conf
ADD start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 9000 443 80

STOPSIGNAL SIGTERM

CMD ["sh","/start.sh"]

# CMD ["nginx", "-g", "daemon off;"]