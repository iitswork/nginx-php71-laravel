FROM muchrm/science-php

# XDEBUG
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-2.6.1 \
    && docker-php-ext-enable xdebug

#install composer
RUN curl -s http://getcomposer.org/installer | php && mv ./composer.phar /usr/local/bin/composer

#install nginx
RUN apk add nginx
COPY nginx.conf /etc/nginx/nginx.conf

#supervisor
RUN apk add --no-cache supervisor

ADD supervisord.conf /etc/supervisord.conf

EXPOSE 443 80

STOPSIGNAL SIGTERM

WORKDIR /var/www/html

CMD ["supervisord", "-c", "/etc/supervisord.conf"]