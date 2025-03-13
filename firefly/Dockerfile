FROM python:3.11-alpine

LABEL maintainer="XG520" \
      description="firefly" \
      version="1.0"

ENV TARGET_URL= \
    LISTEN_PORT=80

WORKDIR /app
COPY proxy /app/proxy

USER root

EXPOSE 80 

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["python", "-m", "proxy.main"]
