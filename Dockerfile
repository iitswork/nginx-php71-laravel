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

WORKDIR /var/www/html

CMD ["sh","/start.sh"]

# CMD ["nginx", "-g", "daemon off;"]