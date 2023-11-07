ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION}

LABEL Maintainer="Fabian Carvajal <inbox@edgcarmu.me>"
LABEL Description="Lightweight container with Nginx & PHP 8.1 based on Alpine Linux."

# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add --no-cache \
    curl \
    nginx \
    supervisor \
    nodejs \
    npm \
    php81 \
    php81-bcmath \
    php81-calendar \
    php81-ctype \
    php81-curl \
    php81-dev \
    php81-dom \
    php81-exif \
    php81-ffi \
    php81-fileinfo \
    php81-fpm \
    php81-ftp \
    php81-gd \
    php81-gettext \
    php81-gmp \
    php81-iconv \
    php81-imap \
    php81-intl \
    php81-json \
    php81-mbstring \
    php81-mysqli \
    php81-mysqlnd \
    php81-opcache \
    php81-openssl \
    php81-pcntl \
    php81-pdo \
    php81-pdo_mysql \
    php81-pdo_pgsql \
    php81-pdo_sqlite \
    php81-pear \
    php81-pecl-imagick \
    php81-pecl-memcached \
    php81-pecl-msgpack \
    php81-pgsql \
    php81-phar \
    php81-posix \
    php81-redis \
    php81-session \
    php81-shmop \
    php81-simplexml \
    php81-soap \
    php81-sockets \
    php81-sodium \
    php81-sqlite3 \
    php81-sysvmsg \
    php81-sysvsem \
    php81-sysvshm \
    php81-tokenizer \
    php81-xml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-xsl \
    php81-zip \
    php81-zlib

# Installing composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessible by the nobody user
RUN chown -R nobody:nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user
USER nobody

# Add application
COPY --chown=nobody src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping