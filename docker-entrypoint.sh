#!/usr/bin/env sh

set -e

mkdir -p /var/www/.composer
chown -R www-data:www-data /var/www/.composer

exec docker-php-entrypoint "$@"
