#!/bin/bash

PATH=node_modules/.bin/:$PATH

es6_escape () {
  sed -e 's/`/\\`/g' -e 's/{/\\{/g' -e 's/}/\\}/g' -i $1
}

pm2 --name serve start "serve -l tcp://0.0.0.0:5000 ."
sleep 5
mkdir -p dist
respec --disable-sandbox http://localhost:5000/ dist/cube.html
es6_escape "dist/cube.html"
respec --disable-sandbox http://localhost:5000/meta/ dist/meta.html
es6_escape "dist/meta.html"
respec --disable-sandbox http://localhost:5000/relation/ dist/relation.html
es6_escape "dist/relation.html"
pm2 delete serve
