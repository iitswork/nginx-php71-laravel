#!/bin/sh

set -e
chown -R :www-data /var/www/html

supervisord -n -c /etc/supervisord.conf