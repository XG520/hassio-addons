FROM ubuntu:22.04

LABEL maintainer="XG520" \
      description="MoneyNote application with Nginx, PHP, MySQL and Java" \
      version="1.0"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    DB_PASSWORD=78p7gkc1 \
    SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/moneynote \
    SPRING_DATASOURCE_USERNAME=root \
    SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD} \
    SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.MySQL8Dialect \
    invite_code=111111

WORKDIR /app

RUN mkdir -p /var/log/{nginx,php-fpm,mysql,java} \
    /data \
    /var/run/mysqld \
    /var/www \
    /etc/nginx/sites-enabled

COPY moneynote.sql /data/
COPY app/app.jar /app/
COPY jdk-17.0.9_linux-x64_bin.deb /tmp/
COPY mysql-apt-config_0.8.33-1_all.deb /tmp/
COPY etc/nginx/sites-available/* /etc/nginx/sites-enabled/
COPY var/www/ /var/www/

RUN set -eux \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        lsb-release \
        wget \
        gnupg \
        software-properties-common \
        curl \
        ca-certificates \
    # && wget https://download.oracle.com/java/17/archive/jdk-17.0.9_linux-x64_bin.deb -O /tmp/jdk-17.0.9_linux-x64_bin.deb \
    # && wget https://dev.mysql.com/get/mysql-apt-config_0.8.33-1_all.deb -O /tmp/mysql-apt-config_0.8.33-1_all.deb \
    && dpkg -i /tmp/mysql-apt-config_0.8.33-1_all.deb \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        php8.1-fpm \
        php8.1-cli \
        php8.1-mysql \
        php8.1-xml \
        php8.1-mbstring \
        php8.1-curl \
        mysql-server \
    && dpkg -i /tmp/jdk-17.0.9_linux-x64_bin.deb \
    && chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www \
    && chown mysql:mysql /var/run/mysqld \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /tmp/mysql-apt-config_0.8.33-1_all.deb \
    && rm -f /tmp/jdk-17.0.9_linux-x64_bin.deb \
    && mysqld --user=mysql --daemonize \
    && while ! mysqladmin ping -h localhost --silent; do sleep 1; done \
    && mysql -e "CREATE DATABASE IF NOT EXISTS moneynote CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" \
    && mysql -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_PASSWORD}';" \
    && mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';" \
    && mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';" \
    && mysql -e "FLUSH PRIVILEGES;" \
    && mysql -u root -p"${DB_PASSWORD}" moneynote < /data/moneynote.sql \
    && mysqladmin shutdown \
    && echo '#!/bin/bash \n\
set -e \n\
CONTAINER_IP=$(hostname -i) \n\
\n\
echo "Container IP: ${CONTAINER_IP}" \n\
\n\
echo "Starting MySQL..." \n\
mysqld --user=mysql --daemonize \n\
max_tries=30 \n\
counter=0 \n\
while true; do \n\
    if mysqladmin ping -h localhost --silent > /dev/null 2>&1; then \n\
        echo "MySQL is ready!" \n\
        break \n\
    fi \n\
    counter=$((counter + 1)) \n\
    if [ $counter -ge $max_tries ]; then \n\
        echo "Error: MySQL failed to start after $max_tries attempts" \n\
        exit 1 \n\
    fi \n\
    echo "Waiting for MySQL to start... (attempt $counter/$max_tries)" \n\
    sleep 2 \n\
done \n\
\n\
service php8.1-fpm start \n\
if ! pgrep php-fpm > /dev/null; then \n\
    echo "PHP-FPM failed to start" \n\
    exit 1 \n\
fi \n\
\n\
service nginx start\n\
if ! pgrep nginx > /dev/null; then\n\
    echo "Nginx failed to start"\n\
    exit 1\n\
fi\n\
\n\
exec java -jar app.jar --spring.datasource.url=jdbc:mysql://$CONTAINER_IP:3306/moneynote --spring.datasource.username=root --spring.datasource.password=$DB_PASSWORD --spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect --invite.code=$invite_code'> /app/start.sh && chmod +x /app/start.sh 


EXPOSE 88 81 82 9092 3306

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["/app/start.sh"]
