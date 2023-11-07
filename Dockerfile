ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION}

LABEL Maintainer="Fabian Carvajal <inbox@edgcarmu.me>"
LABEL Description="Lightweight container with Nginx & PHP 8.1 based on Alpine Linux."

# Set environment variables for the 'nobody' user's home directory, npm cache, and node_modules
ENV HOME=/home/nobody
ENV NPM_CACHE=${HOME}/.npm
ENV NODE_MODULES=${HOME}/node_modules

# Set the working directory to the document root
WORKDIR /var/www/html

# Install required packages, including Nginx, Supervisor, Node.js, npm, PHP, and PHP extensions
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

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy Nginx main configuration file
COPY config/nginx.conf /etc/nginx/nginx.conf
# Copy Nginx default server configuration
COPY config/conf.d /etc/nginx/conf.d/

# Copy PHP-FPM pool configuration
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
# Copy custom PHP configuration
COPY config/php.ini /etc/php81/conf.d/custom.ini

# Copy Supervisor configuration
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Ensure 'nobody' user has access to necessary files and folders
RUN chown -R nobody:nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Create directories for npm cache and node_modules and set ownership to 'nobody' user
RUN mkdir -p ${NPM_CACHE} ${NODE_MODULES} && \
    chown -R nobody:nobody ${HOME}

# Switch to the 'nobody' user before running further commands
USER nobody

# Set environment variables for npm to use the created directories
ENV NPM_CONFIG_CACHE=${NPM_CACHE}
ENV PATH="${NODE_MODULES}/.bin:${PATH}"

# Copy the application source code to the container and set ownership to 'nobody'
COPY --chown=nobody src/ /var/www/html/

# Expose port 8080 for Nginx
EXPOSE 8080

# Use Supervisor to start Nginx and PHP-FPM
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Set up a healthcheck to verify that Nginx is serving content
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping