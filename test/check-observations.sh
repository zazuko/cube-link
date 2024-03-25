#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FAILED=0

filter=''

# get arguments --profile
while [ $# -gt 0 ]; do
  case "$1" in
    --approve)
      approvalsFlags='-f'
      ;;
    --filter=*)
      filter="${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

# iterate over valid cases, run validation and monitor exit code
for file in "$SCRIPT_PATH"/observations/*.ttl; do
  # check if filter is set and skip if not matching
    if [ -n "$filter" ] && ! echo "$file" | grep -q "$filter"; then
      continue
    fi

    name=$(basename "$file")
    report=$(npx barnard59 cube check-observations --constraint "$file" < "$file" 2> "$file.log" | "$SCRIPT_PATH"/pretty-print.js)

    if ! echo "$report" | npx approvals "$name" --outdir "$SCRIPT_PATH"/observations "$approvalsFlags" > /dev/null 2>&1 ; then
      "$SCRIPT_PATH"/report-failure.sh "$file" "$(cat "$file")" "$(cat "$file")" "check results"
      FAILED=1
    else
      echo "✅ PASS - $name"
    fi
done

exit $FAILED
