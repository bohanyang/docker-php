#!/usr/bin/env sh

set -e

# if [ -n "$PHP_FPM_LISTEN" ]; then
#   if ! [ "$PHP_FPM_LISTEN" -eq "$PHP_FPM_LISTEN" ] 2> /dev/null; then
#     mkdir -p "$(dirname "$PHP_FPM_LISTEN")"
#     {
#       echo 'listen.owner = www-data'
#       echo 'listen.group = www-data'
#       echo 'listen.mode = 0660'
#     } >> /usr/local/etc/php-fpm.d/zz-docker.conf
#   fi
#   sed -i "s,^listen = 9000,listen = $PHP_FPM_LISTEN," /usr/local/etc/php-fpm.d/zz-docker.conf
# fi

mkdir -p /var/www/.composer
chown -R www-data:www-data /var/www/.composer

exec docker-php-entrypoint "$@"
