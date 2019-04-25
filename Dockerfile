FROM php:7.3.4-fpm-alpine3.9

RUN set -ex; \
    # delete the user xfs (uid 33) for the user www-data (the same uid 33 in Debian) that will be created soon
    deluser xfs; \
    # delete the existing www-data user (uid 82)
    deluser www-data; \
    # create a new user and its group www-data with uid 33
    addgroup -g 33 -S www-data; adduser -G www-data -S -D -H -u 33 www-data

RUN set -ex; \
    sed -i 's!^listen = 9000!listen = /var/run/php/php7.3-fpm.sock!' /usr/local/etc/php-fpm.d/zz-docker.conf; \
    printf "listen.owner = www-data\nlisten.group = www-data\nlisten.mode = 0660\n" >> /usr/local/etc/php-fpm.d/zz-docker.conf

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        libtool \
        # required by gd
        freetype-dev \
        # required by geoip
        # geoip-dev \
        # required by gettext
        gettext-dev \
        # required by gmp
        # gmp-dev \
        # required by gmagick
        # graphicsmagick-dev \
        # required by intl
        icu-dev \
        # required by imap
        # imap-dev \
        # required by imagick
        # imagemagick-dev \
        # required by bz2
        bzip2-dev \
        # required by gd
        libjpeg-turbo-dev \
        # required by maxminddb
        # libmaxminddb-dev \
        # required by memcached
        libmemcached-dev \
        # required by gd
        libpng-dev \
        # required by gd
        libwebp-dev \
        # required by zip
        libzip-dev \
        # required by ldap
        # openldap-dev \
        # required by pdo_pgsql
        # postgresql-dev \
        # required by smbclient
        # samba-dev \
        # required by yaml
        # yaml-dev \
    ; \
    # curl -fsSL https://github.com/maxmind/MaxMind-DB-Reader-php/archive/v1.4.0.tar.gz -o maxminddb.tar.gz; \
    # mkdir /usr/src/maxminddb; \
    # tar -xf maxminddb.tar.gz -C /usr/src/maxminddb --strip-components=1; \
    # rm maxminddb.tar.gz; \
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr --with-webp-dir=/usr; \
    docker-php-ext-configure zip --with-libzip; \
    docker-php-ext-install \
        bcmath \
        bz2 \
        exif \
        gd \
        gettext \
        # gmp \
        # imap \
        intl \
        # ldap \
        # /usr/src/maxminddb/ext \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        # pdo_pgsql \
        sockets \
        zip \
    ; \
    # rm -r /usr/src/maxminddb; \
    pecl install APCu-5.1.17; \
    # pecl install geoip-1.1.1; \
    # pecl install gmagick-2.0.5RC1; \
    # pecl install imagick-3.4.3; \
    pecl install memcached-3.1.3; \
    # pecl install mongodb-1.5.3; \
    # pecl install rar-4.0.0; \
    pecl install redis-4.3.0; \
    # pecl install smbclient-0.9.0; \
    # pecl install swoole-4.2.9; \
    # pecl install yaml-2.0.4; \
    docker-php-ext-enable \
        apcu \
        # geoip \
        # gmagick \
        # imagick \
        memcached \
        # mongodb \
        # rar \
        redis \
        # smbclient \
        # swoole \
        # yaml \
    ; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --virtual .php-ext-rundeps $runDeps; \
    curl -fsSL https://raw.githubusercontent.com/composer/getcomposer.org/e831e1e4d6cabfb11fa9657103cf728e6eb9e295/web/installer | php -- --quiet --install-dir=/usr/local/bin --filename=composer --version=1.8.5; \
    apk del .build-deps

RUN printf "opcache.enable=1\nopcache.enable_cli=1\nopcache.interned_strings_buffer=8\nopcache.max_accelerated_files=10000\nopcache.memory_consumption=128\nopcache.save_comments=1\nopcache.revalidate_freq=1\n" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
