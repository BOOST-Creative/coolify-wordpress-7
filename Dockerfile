FROM alpine:3.15

# Install packages
RUN apk --no-cache add \
  php7 \
  php7-fpm \
  php7-mysqli \
  php7-json \
  php7-openssl \
  php7-curl \
  php7-zlib \
  php7-xml \
  php7-phar \
  php7-intl \
  php7-dom \
  php7-xmlreader \
  php7-xmlwriter \
  php7-exif \
  php7-fileinfo \
  php7-sodium \
  php7-simplexml \
  php7-ctype \
  php7-mbstring \
  php7-zip \
  php7-opcache \
  php7-iconv \
  php7-pecl-imagick \
  php7-pecl-vips \
  php7-session \
  php7-tokenizer \
  php7-gd \
  php7-pecl-redis \
  php7-soap \
  php7-pdo \
  php7-sqlite3 \
  php7-pecl-apcu \
  mariadb-client \
  nginx \
  supervisor \
  inotify-tools \
  curl \
  bash \
  less \
  tzdata \
  ca-certificates

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN mkdir -p /usr/src/wordpress /var/log/nginx /var/log/php7 && chown -R nobody: /usr/src/wordpress /var/log/nginx /var/log/php7
WORKDIR /usr/src/wordpress

# Add WP CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x /usr/local/bin/wp

# Nginx restart watcher
COPY config/watch-wordpress-nginx.sh /usr/local/bin/watch-wordpress-nginx
RUN chmod +x /usr/local/bin/watch-wordpress-nginx

# Entrypoint to install plugins
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# healthcheck runs cron queue every 5 mintes - add disable_cron to wp-config
HEALTHCHECK --interval=300s --timeout=120s CMD curl -fsS http://localhost/ >/dev/null && su -s /bin/sh nobody -c "sleep $(tr -dc 0-9 </dev/urandom | head -c2) && wp cron event run --due-now --skip-themes --skip-plugins --path=/usr/src/wordpress --quiet" || exit 1