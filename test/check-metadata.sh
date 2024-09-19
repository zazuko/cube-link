#!/usr/bin/env bash

npx shacl-test --shapes="validation/$1.ttl" \
 --valid-cases="test/$1/valid*.ttl" \
 --invalid-cases="test/$1/invalid*.ttl" \
 --command="npx b59 cube check-metadata --profile" \
 --prefixes=schema,cube=https://cube.link/ \
 ${*:2}
