#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FAILED=0

function reportFailure() {
  message=$3
  if [ -z "$message" ]; then
    message="compare reports"
  fi

  playground=$("$SCRIPT_PATH"/shorten-report.js "$1" "$2")
  echo "❌ FAIL - $message: $playground"
}

# iterate over valid cases, run validation and monitor exit code
for file in "$SCRIPT_PATH"/*/valid*.ttl; do
  echo "Test case $file"
  {
    npx barnard59 cube check-metadata --profile validation/profile-opendataswiss.ttl > /dev/null 2>&1
    success=$?
  } < "$file"

  if [ $success -ne 0 ] ; then
    reportFailure "$(cat validation/profile-opendataswiss.ttl)" "$(cat "$file")"
    FAILED=1
  fi
done

# iterate over invalid cases
for file in "$SCRIPT_PATH"/*/invalid*.cube.rq; do
  echo "Test case $file"
  invalidCube=$(arq --data "$SCRIPT_PATH"/opendata.swiss/valid.ttl --query "$file" 2> /dev/null)
  report=$(echo "$invalidCube" | npx barnard59 cube check-metadata --profile validation/profile-opendataswiss.ttl 2> /dev/null)
  expectation="${file/cube\.rq/expectation.ttl}"
  if ! echo "$report" | npx barnard59 shacl validate --shapes "$expectation" > /dev/null 2>&1; then
    reportFailure "$(cat "$expectation")" "$report"
    reportFailure "$(cat validation/profile-opendataswiss.ttl)" "$invalidCube" "actual validation"
    FAILED=1
  fi
done

exit $FAILED
