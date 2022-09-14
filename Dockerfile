# deploy stage
FROM nginx:stable-alpine

WORKDIR /usr/share/nginx/html

COPY dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
COPY CONTRIBUTING.* DCO LICENSE README.* ./
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80

HEALTHCHECK --interval=30s --start-period=10s --timeout=30s \
  CMD wget --quiet --tries=1 --spider "http://127.0.0.1:80/config.js" || exit 1

ENTRYPOINT ["/entrypoint.sh"]
