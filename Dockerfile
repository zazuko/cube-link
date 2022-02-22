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

RUN npm i -g respec@31 chromium serve pm2

WORKDIR /app
COPY . .

# start a server locally, and generate the ReSpec HTML file
RUN pm2 --name serve start "serve -l tcp://0.0.0.0:5000 /app" \
  && sleep 5 && curl http://localhost:5000/ && respec --disable-sandbox http://localhost:5000/ /app/respec.html \
  && pm2 delete serve

# Trifid is only working on Node12
FROM docker.io/library/node:12-alpine3.15

EXPOSE 8080

WORKDIR /app

# install Trifid
ENV NODE_ENV=production
RUN npm install -g trifid@2.3.6

COPY --from=respec /app/respec.html ./respec.html

COPY . .

CMD [ "trifid", "--verbose", "--config=trifid/config.json" ]
