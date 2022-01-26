# Trifid is only working on Node12
FROM docker.io/library/node:12-alpine3.15

EXPOSE 8080

WORKDIR /app

# install Trifid
ENV NODE_ENV=production
RUN npm install -g trifid@2.3.5

COPY . .

CMD [ "trifid", "--verbose", "--config=trifid/config.json" ]
