#!/usr/bin/env sh

set -e

if [ -n "$PHP_FPM_LISTEN" ]; then
  if ! [ "$PHP_FPM_LISTEN" -eq "$PHP_FPM_LISTEN" ] 2> /dev/null; then
    mkdir -p $(dirname "$PHP_FPM_LISTEN")
    printf "listen.owner = www-data\nlisten.group = www-data\nlisten.mode = 0660\n" >> /usr/local/etc/php-fpm.d/zz-docker.conf
  fi
  sed -i 's!^listen = 9000!listen = '"$PHP_FPM_LISTEN"'!' /usr/local/etc/php-fpm.d/zz-docker.conf
fi

exec docker-php-entrypoint "$@"
