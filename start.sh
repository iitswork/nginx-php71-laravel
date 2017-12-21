#!/bin/sh

set -e
chown -R nginx.nginx /var/www/html

supervisord -n -c /etc/supervisord.conf