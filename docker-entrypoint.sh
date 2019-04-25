#!/usr/bin/env sh

set -e

if [ -n "$PHP73_FPM_SOCKET" ]; then
  mkdir -p $(dirname "$PHP73_FPM_SOCKET")
  sed -i 's!^listen = /var/run/php/php7.3-fpm.sock!listen = '"$PHP73_FPM_SOCKET"'!' /usr/local/etc/php-fpm.d/zz-docker.conf
fi

exec docker-php-entrypoint "$@"
