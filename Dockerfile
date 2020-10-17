FROM php:7.4-fpm

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN apt-get update -y \
    && apt-get install -y nginx git zlib1g-dev libzip-dev unzip

RUN docker-php-ext-install zip
RUN docker-php-ext-install sockets
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install opcache
RUN docker-php-ext-install mysqli
RUN pecl install redis && docker-php-ext-enable redis

ADD run.sh /
RUN chmod +x /run.sh
RUN mkdir /website
RUN chown www-data:www-data /website
ADD config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD config/nginx/default.conf /etc/nginx/conf.d/
ADD config/php-fpm/zzz-docker.conf /usr/local/etc/php-fpm.d/

ADD index.php /website

VOLUME [ "/etc/nginx/conf.d/", "/website" ]

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["/run.sh"]
