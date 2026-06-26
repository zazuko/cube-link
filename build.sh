#!/bin/sh

PATH="node_modules/.bin/:${PATH}"

# ReSpec drives a headless browser through Puppeteer. On Linux, Puppeteer only
# ships x86-64 Chromium, which fails on arm64 / under Rosetta; there we use the
# system Chromium instead (it matches the host architecture). On other platforms
# (e.g. macOS) Puppeteer's own bundled Chrome is the right, version-matched one,
# so we leave it alone. An explicit PUPPETEER_EXECUTABLE_PATH always wins.
if [ -z "${PUPPETEER_EXECUTABLE_PATH:-}" ] && [ "$(uname -s)" = "Linux" ]; then
  CHROMIUM_PATH=$(command -v chromium || command -v chromium-browser || true)
  if [ -n "${CHROMIUM_PATH}" ]; then
    export PUPPETEER_EXECUTABLE_PATH="${CHROMIUM_PATH}"
  fi
fi

pm2 --name serve start "serve -l tcp://0.0.0.0:5050 ."
sleep 5
mkdir -p dist
respec --disable-sandbox http://localhost:5050/ dist/cube.html
respec --disable-sandbox http://localhost:5050/meta/ dist/meta.html
respec --disable-sandbox http://localhost:5050/relation/ dist/relation.html
pm2 delete serve
