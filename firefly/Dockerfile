FROM python:3.11-alpine

LABEL maintainer="XG520" \
      description="firefly" \
      version="1.0"

ENV TARGET_URL=http://192.168.31.5:888 \
    LISTEN_PORT=8080

WORKDIR /app
COPY proxy /app/proxy

USER root

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["python", "-m", "proxy.main"]
