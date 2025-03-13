FROM fireflyiii/core

LABEL maintainer="XG520" \
      description="firefly" \
      version="1.0"

ENV DEBIAN_FRONTEND=noninteractive \
    APP_KEY= \
    DB_CONNECTION=sqlite \
    TARGET_URL=http://127.0.0.1:8080 \
    LISTEN_PORT=777

WORKDIR /var/www/html
COPY proxy /var/www/html/proxy
COPY init /init

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R www-data:www-data /var/www/html \
    && chmod +x /init

EXPOSE 777 8080 8443 9000 

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["/init"]
