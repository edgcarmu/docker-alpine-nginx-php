ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION}

LABEL Maintainer="Fabian Carvajal <inbox@edgcarmu.me>"
LABEL Description="Lightweight container with Nginx 1.18 & PHP 7.4 based on Alpine Linux."

# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add --no-cache \
    curl \
    yarn \
    nginx \
    php81 \
    php81-dev \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-fpm \
    php81-gd \
    php81-intl \
    php81-mbstring \
    php81-mysqli \
    php81-opcache \
    php81-openssl \
    php81-phar \
    php81-session \
    php81-xml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-simplexml \
    php81-json \
    php81-zlib \
    php81-intl \
    php81-sysvshm \
    php81-sysvsem \
    php81-sysvmsg \
    php81-sqlite3 \
    php81-sodium \
    php81-soap \
    php81-ffi \
    php81-pecl-imagick \
    php81-pcntl \
    php81-pgsql \
    php81-posix \
    php81-redis \
    php81-shmop \
    php81-sockets \
    php81-zip \
    php81-pear \
    php81-xsl \
    php81-gmp \
    php81-bcmath \
    php81-tokenizer \
    php81-iconv \
    php81-calendar \
    php81-exif \
    php81-ftp \
    php81-gettext \
    php81-imap \
    php81-pdo \
    php81-pdo_mysql \
    php81-pdo_sqlite \
    php81-pdo_pgsql \
    php81-mysqlnd \
    php81-fileinfo \
    php81-pecl-memcached \
    php81-pecl-msgpack \
    supervisor

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
COPY --chown=nobody src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping