#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FAILED=0

function reportFailure() {
  playground=$("$SCRIPT_PATH"/shorten-report.js "$1" "$2")
  echo "❌ FAIL - check report on $playground"
}

# iterate over valid cases, run validation and monitor exit code
for file in "$SCRIPT_PATH"/*/valid*.ttl; do
  echo "Test case $file"
  {
    barnard59 cube check-metadata --profile validation/profile-opendataswiss.ttl > /dev/null 2>&1
    success=$?
  } < "$file"

  if [ $success -ne 0 ] ; then
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
