FROM docker.io/library/node:16-bullseye as respec

# install some required dependencies to run Puppeteer (for ReSpec)
RUN apt-get update && apt-get install -y \
  fonts-liberation \
  gconf-service \
  libasound2 \
  libatk1.0-0 \
  libcairo2 \
  libcups2 \
  libfontconfig1 \
  libgbm-dev \
  libgdk-pixbuf2.0-0 \
  libgtk-3-0 \
  libicu-dev \
  libjpeg-dev \
  libnspr4 \
  libnss3 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libpng-dev \
  libx11-6 \
  libx11-xcb1 \
  libxcb1 \
  libxcomposite1 \
  libxcursor1 \
  libxdamage1 \
  libxext6 \
  libxfixes3 \
  libxi6 \
  libxrandr2 \
  libxrender1 \
  libxss1 \
  libxtst6 \
  xdg-utils

WORKDIR /app
COPY . .
RUN npm install

# start a server locally, and generate the ReSpec HTML file
RUN npm run build

# Trifid is only working on Node12
FROM docker.io/library/node:12-alpine3.15

EXPOSE 8080

WORKDIR /app

RUN apk add --no-cache tini

# install Trifid
ENV NODE_ENV=production
RUN npm install -g trifid@2.3.6

COPY --from=respec /app/dist ./dist
COPY img .

COPY . .

CMD [ "tini",  "--", "trifid", "--verbose", "--config=trifid/config.json" ]
