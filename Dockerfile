FROM php:8.1.12-cli-bullseye

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

ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/1.5.47/install-php-extensions /usr/local/bin/

RUN set -ex; \
    \
    chmod a+rx /usr/local/bin/install-php-extensions; \
    \
    install-php-extensions \
        apcu \
        bcmath \
        bz2 \
        event \
        igbinary \
        intl \
        oci8 \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        redis \
        sockets \
        sysvsem \
        opcache \
        zip

RUN set -ex; \
    \
    # https://getcomposer.org/
    COMPOSER_VERSION=2.4.4; \
    # https://github.com/composer/getcomposer.org/blob/master/web/installer
    COMPOSER_INSTALLER_VERSION=0a51b6fe383f7f61cf1d250c742ec655aa044c94; \
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
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php", "-a"]
