FROM php:7.4-fpm

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            apt-utils \
            nginx \
            git \
            openssl \
            libssl-dev \
            zlib1g-dev \
            libzip-dev \
            unzip \
            zip \
            wget 


RUN set -eux; \
    docker-php-ext-install \
        zip \
        sockets \
        pdo_mysql \
        bcmath \
        opcache \
        mysqli; \
    pecl install redis && docker-php-ext-enable redis

# RUN docker-php-ext-install 
# RUN docker-php-ext-install pdo_mysql
# RUN docker-php-ext-install bcmath
# RUN docker-php-ext-install opcache
# RUN docker-php-ext-install mysqli
# RUN pecl install redis && docker-php-ext-enable redis

RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN set -eux; \
    cd /root; \
    curl -o swoole.tar.gz https://codeload.github.com/swoole/swoole-src/tar.gz/v4.5.5; \
    mkdir swoole && tar -zxvf swoole.tar.gz -C ./swoole --strip-components 1; \
    cd swoole; \
    phpize; \
    ./configure --enable-openssl --enable-http2  --enable-sockets --enable-mysqlnd; \
    make && make install; \
    docker-php-ext-enable swoole

RUN curl -sS https://getcomposer.org/installer | php -- --no-ansi --install-dir=/usr/bin --filename=composer

ADD run.sh /
ADD config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD config/nginx/default.conf /etc/nginx/conf.d/
ADD config/php-fpm/zzz-docker.conf /usr/local/etc/php-fpm.d/

RUN chmod +x /run.sh
RUN mkdir /website
RUN chown www-data:www-data /website
ADD index.php /website

VOLUME [ "/etc/nginx/conf.d/", "/website" ]

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["/run.sh"]
