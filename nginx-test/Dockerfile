FROM nginx

LABEL maintainer="XG520" \
      description="nginx" \
      version="1.0"

WORKDIR /app
USER root

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
