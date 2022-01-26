FROM docker.io/library/nginx:1.21-alpine

EXPOSE 80

WORKDIR /usr/share/nginx/html
COPY . .
