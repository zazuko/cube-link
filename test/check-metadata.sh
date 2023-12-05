#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FAILED=0

filter=''

# get arguments --profile
while [ $# -gt 0 ]; do
  case "$1" in
    --profile=*)
      profile="${1#*=}"
      profilePath=validation/"$profile".ttl
      ;;
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

# check if profile is set
if [ -z "$profile" ]; then
  printf "***************************\n"
  printf "* Error: No profile set.  *\n"
  printf "***************************\n"
  exit 1
fi

# iterate over valid cases, run validation and monitor exit code
for file in "$SCRIPT_PATH"/"$profile"/valid*.ttl; do
  # check if filter is set and skip if not matching
  if [ -n "$filter" ] && ! echo "$file" | grep -q "$filter"; then
    continue
  fi

  name=$(basename "$file")
  {
    npx barnard59 cube check-metadata --profile "$profilePath" > /dev/null 2>"$file.log"
    success=$?
  } < "$file"

  if [ $success -ne 0 ] ; then
    "$SCRIPT_PATH"/report-failure.sh "$file" "$(cat "$profilePath")" "$(cat "$file")"
    FAILED=1
  else
    echo "✅ PASS - $name"
  fi
done

# iterate over invalid cases
for file in "$SCRIPT_PATH"/"$profile"/invalid*.ttl; do
  # check if pattern is set and skip if not matching
  if [ -n "$pattern" ] && ! echo "$file" | grep -q "$pattern"; then
    continue
  fi

  name=$(basename "$file")
  report=$(npx barnard59 cube check-metadata --profile "$profilePath" < "$file" 2> "$file.log" | "$SCRIPT_PATH"/pretty-print.mjs)

  if ! echo "$report" | npx approvals "$name" --outdir "$SCRIPT_PATH"/"$profile" "$approvalsFlags" > /dev/null 2>&1 ; then
    "$SCRIPT_PATH"/report-failure.sh "$file" "$(cat "$profilePath")" "$(cat "$file")" "check results"
    FAILED=1
  else
    echo "✅ PASS - $name"
  fi
done

exit $FAILED
