FROM php:7.4-fpm

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN apt-get update -y \
    && apt-get install -y nginx git zlib1g-dev libzip-dev unzip

ADD run.sh /
RUN chmod +x /run.sh

CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["/run.sh"]