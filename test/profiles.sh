#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FAILED=0

SHACL_PLAYGROUND_URL="https://shacl-playground.zazuko.com/"
SHORTENER="https://s.zazuko.com/api/v1/shorten/"

function urlencode() {
  set +x

  local string="$1"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * ) printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
}

function getPlaygroundUrl() {
  local playgroundUrl="$SHACL_PLAYGROUND_URL#page=2&shapesGraph=$(urlencode "$1")&dataGraph=$(urlencode "$2")&dataGraphFormat=text%2Fturtle"
  curl -s $SHORTENER --data-raw "url=$playgroundUrl"
}

function reportFailure() {
  playground=$(getPlaygroundUrl "$1" "$2")
  echo "❌ FAIL - check report on $playground"
}

# iterate over valid cases, run validation and monitor exit code
for file in "$SCRIPT_PATH"/*/valid*.ttl; do
  echo "Test case $file"
  if ! barnard59 cube check-metadata --profile validation/profile-opendataswiss.ttl < "$file" > /dev/null 2>&1; then
    reportFailure "$(cat validation/profile-opendataswiss.ttl)" "$(cat "$file")"
    FAILED=1
  fi
done

# iterate over invalid cases
for file in "$SCRIPT_PATH"/*/invalid*.cube.ttl; do
  echo "Test case $file"
  report=$(barnard59 cube check-metadata --profile validation/profile-opendataswiss.ttl < "$file" 2> /dev/null)
  expectation="${file/cube\.ttl/expectation.ttl}"
  if ! echo "$report" | barnard59 shacl validate --shapes "$expectation" > /dev/null 2>&1; then
    reportFailure "$(cat "$expectation")" "$report"
    FAILED=1
  fi
done

exit $FAILED
