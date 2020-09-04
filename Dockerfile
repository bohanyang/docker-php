FROM php:7.4.10-fpm-buster

RUN set -ex; \
    \
    SU_EXEC_VERSION=212b75144bbc06722fbd7661f651390dc47a43d1; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        unzip \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    curl -fsSL -o su-exec.tar.gz "https://github.com/ncopa/su-exec/archive/$SU_EXEC_VERSION.tar.gz"; \
    tar -xf su-exec.tar.gz; \
    rm su-exec.tar.gz; \
    \
    make -C "su-exec-$SU_EXEC_VERSION"; \
    mv "su-exec-$SU_EXEC_VERSION/su-exec" /usr/local/bin; \
    rm -r "su-exec-$SU_EXEC_VERSION"

RUN set -ex; \
    \
    # https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html
    INSTANTCLIENT_URL=https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-basiclite-linux.x64-19.8.0.0.0dbru.zip; \
    INSTANTCLIENT_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip; \
    INSTANTCLIENT_VERSION=19.8; \
    INSTANTCLIENT_DIR=instantclient_19_8; \
    # https://packages.debian.org/buster-backports/libzstd-dev
    LIBZSTD_VERSION='1.4.4+dfsg-3~bpo10+1'; \
    # https://packages.debian.org/sid/librabbitmq-dev
    LIBRABBITMQ_VERSION='0.10.0-1'; \
    # https://pecl.php.net/package/amqp
    PHP_EXT_AMQP_VERSION=1.10.2; \
    # https://pecl.php.net/package/APCu
    PHP_EXT_APCU_VERSION=5.1.18; \
    # https://pecl.php.net/package/geoip
    PHP_EXT_GEOIP_VERSION=1.1.1; \
    # https://pecl.php.net/package/igbinary
    PHP_EXT_IGBINARY_VERSION=3.1.5; \
    # https://pecl.php.net/package/imagick
    PHP_EXT_IMAGICK_VERSION=3.4.4; \
    # https://pecl.php.net/package/lzf
    PHP_EXT_LZF_VERSION=1.6.8; \
    # https://github.com/maxmind/MaxMind-DB-Reader-php/releases
    PHP_EXT_MAXMINDDB_VERSION=1.7.0; \
    # https://pecl.php.net/package/memcached
    PHP_EXT_MEMCACHED_VERSION=3.1.5; \
    # https://pecl.php.net/package/mongodb
    PHP_EXT_MONGODB_VERSION=1.8.0; \
    # https://pecl.php.net/package/msgpack
    PHP_EXT_MSGPACK_VERSION=2.1.1; \
    # https://pecl.php.net/package/oci8
    PHP_EXT_OCI8_VERSION=2.2.0; \
    # https://pecl.php.net/package/redis
    PHP_EXT_REDIS_VERSION=5.3.1; \
    # https://pecl.php.net/package/smbclient
    PHP_EXT_SMBCLIENT_VERSION=1.0.0; \
    # https://pecl.php.net/package/swoole
    PHP_EXT_SWOOLE_VERSION=4.5.3; \
    # https://pecl.php.net/package/yaml
    PHP_EXT_YAML_VERSION=2.1.0; \
    # https://pecl.php.net/package/zstd
    PHP_EXT_ZSTD_VERSION=0.9.0; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/buster-backports.list; \
    echo 'deb http://deb.debian.org/debian unstable main' > /etc/apt/sources.list.d/unstable.list; \
    printf '%s\n%s\n%s\n' 'Package: *' 'Pin: release a=unstable' 'Pin-Priority: 1' > /etc/apt/preferences.d/10unstable; \
    printf '%s\n%s\n%s\n' 'Package: libzstd*' 'Pin: release a=buster-backports' 'Pin-Priority: 500' > /etc/apt/preferences.d/50libzstd; \
    printf '%s\n%s\n%s\n' 'Package: librabbitmq*' 'Pin: release a=unstable' 'Pin-Priority: 500' > /etc/apt/preferences.d/50librabbitmq; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libaio1 \
        libbz2-dev \
        libc-client-dev \
        libfreetype6-dev \
        libgeoip-dev \
        libgmp-dev \
        libicu-dev \
        libjpeg-dev \
        libkrb5-dev \
        libldap2-dev \
        libmagickwand-dev \
        libmaxminddb-dev \
        libmemcached-dev \
        libpng-dev \
        libpq-dev \
        librabbitmq-dev \
        libsmbclient-dev \
        libwebp-dev \
        libxml2-dev \
        libyaml-dev \
        libzip-dev \
        libzstd-dev \
        zlib1g-dev \
    ; \
    \
    curl -fsSL \
        -o instantclient.zip "$INSTANTCLIENT_URL" \
        -o instantclient-sdk.zip "$INSTANTCLIENT_SDK_URL" \
    ; \
    unzip -q instantclient.zip; \
    unzip -q instantclient-sdk.zip; \
    rm \
        instantclient.zip \
        instantclient-sdk.zip \
    ; \
    rm -rf "/usr/lib/oracle/$INSTANTCLIENT_VERSION/client64/lib"; \
    mkdir -p "/usr/lib/oracle/$INSTANTCLIENT_VERSION/client64"; \
    mv "$INSTANTCLIENT_DIR" "/usr/lib/oracle/$INSTANTCLIENT_VERSION/client64/lib"; \
    echo "/usr/lib/oracle/$INSTANTCLIENT_VERSION/client64/lib" > /etc/ld.so.conf.d/oracle-instantclient.conf; \
    ldconfig; \
    \
    pecl install "amqp-$PHP_EXT_AMQP_VERSION"; \
    pecl install "APCu-$PHP_EXT_APCU_VERSION"; \
    pecl install "geoip-$PHP_EXT_GEOIP_VERSION"; \
    pecl install "igbinary-$PHP_EXT_IGBINARY_VERSION"; \
    pecl install "imagick-$PHP_EXT_IMAGICK_VERSION"; \
    pecl install "lzf-$PHP_EXT_LZF_VERSION"; \
    pecl install "mongodb-$PHP_EXT_MONGODB_VERSION"; \
    pecl install "msgpack-$PHP_EXT_MSGPACK_VERSION"; \
    # Skip prompt (autodetect) : /usr/lib/oracle/19.8/client64/lib
    pecl install "oci8-$PHP_EXT_OCI8_VERSION" </dev/null; \
    pecl install "smbclient-$PHP_EXT_SMBCLIENT_VERSION"; \
    pecl install "swoole-$PHP_EXT_SWOOLE_VERSION"; \
    pecl install "yaml-$PHP_EXT_YAML_VERSION"; \
    \
    docker-php-ext-enable \
        amqp \
        apcu \
        geoip \
        igbinary \
        imagick \
        lzf \
        mongodb \
        msgpack \
        oci8 \
        smbclient \
        swoole \
        yaml \
    ; \
    \
    mkdir -p /usr/src/php/ext; \
    touch /usr/src/php/.docker-delete-me; \
    cd /usr/src/php/ext; \
    \
    curl -fsSL -o MaxMind-DB-Reader-php.tar.gz "https://github.com/maxmind/MaxMind-DB-Reader-php/archive/v$PHP_EXT_MAXMINDDB_VERSION.tar.gz"; \
    mkdir MaxMind-DB-Reader-php; \
    tar -xf MaxMind-DB-Reader-php.tar.gz -C MaxMind-DB-Reader-php --strip-components=1; \
    mv MaxMind-DB-Reader-php/ext maxminddb; \
    \
    pecl bundle "memcached-$PHP_EXT_MEMCACHED_VERSION"; \
    pecl bundle "redis-$PHP_EXT_REDIS_VERSION"; \
    pecl bundle "zstd-$PHP_EXT_ZSTD_VERSION"; \
    \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
    PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch"; \
    docker-php-ext-configure memcached --enable-memcached-json --enable-memcached-msgpack --enable-memcached-igbinary; \
    docker-php-ext-configure redis --enable-redis-igbinary --enable-redis-msgpack --enable-redis-lzf --enable-redis-zstd; \
    docker-php-ext-configure zstd --with-libzstd; \
    \
    docker-php-ext-install -j "$(nproc)" \
        bcmath \
        bz2 \
        exif \
        gd \
        gettext \
        gmp \
        imap \
        intl \
        ldap \
        maxminddb \
        memcached \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        redis \
        soap \
        sockets \
        xmlrpc \
        zip \
        zstd \
	; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    \
    # https://getcomposer.org/
    COMPOSER_VERSION=1.10.10; \
    # https://github.com/composer/getcomposer.org/blob/master/web/installer
    COMPOSER_INSTALLER_VERSION=61ce3d7428126e268abb49b9cd8623b6e45ccff4; \
    \
    curl -fsSL "https://raw.githubusercontent.com/composer/getcomposer.org/$COMPOSER_INSTALLER_VERSION/web/installer" | php -- --quiet --install-dir=/usr/local/bin --filename=composer --version="$COMPOSER_VERSION"; \
    \
    { \
        echo 'opcache.enable=1'; \
        echo 'opcache.enable_cli=1'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.revalidate_freq=2'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    \
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini; \
    \
    echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini; \
    \
    echo 'max_execution_time=60' > /usr/local/etc/php/conf.d/max-execution-time.ini; \
    \
    echo 'pm.max_children = 16' >> /usr/local/etc/php-fpm.d/zz-docker.conf

RUN curl -A 'Docker' -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/74 && \
    mkdir -p /tmp/blackfire && \
    tar -xpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire && \
    mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so && \
    echo 'extension=blackfire.so' > "$PHP_INI_DIR/conf.d/blackfire.ini" && \
    rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php-fpm"]
