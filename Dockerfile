FROM docker.io/library/node:22 AS respec

# Install some required dependencies to run Puppeteer (for ReSpec)
RUN apt-get update && apt-get install -y \
  chromium \
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
COPY package.json package-lock.json ./
RUN npm install
COPY . .
# Start a server locally, and generate the ReSpec HTML file
RUN npm run build

# Final Docker image
FROM docker.io/library/node:22-alpine

EXPOSE 8080

WORKDIR /app

RUN apk add --no-cache tini

# Install Trifid
ENV NODE_ENV=production
COPY package.json package-lock.json ./
RUN npm install

COPY --from=respec /app/dist ./dist
COPY img .
COPY . .

CMD [ "tini",  "--", "npm", "run", "trifid:local" ]
