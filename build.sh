#!/bin/sh

PATH="node_modules/.bin/:${PATH}"

pm2 --name serve start "serve -l tcp://0.0.0.0:5050 ."
sleep 5
mkdir -p dist
respec --disable-sandbox http://localhost:5050/ dist/cube.html
respec --disable-sandbox http://localhost:5050/meta/ dist/meta.html
respec --disable-sandbox http://localhost:5050/relation/ dist/relation.html
pm2 delete serve
