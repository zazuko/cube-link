#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FAILED=0

filter=''
debug=false

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
    --debug)
      debug=true
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

loadFullShape() {
  "$SCRIPT_PATH"/load-graph.mjs "$1" | "$SCRIPT_PATH"/pretty-print.mjs
}

# iterate over valid cases, run validation and monitor exit code
for file in "$SCRIPT_PATH"/"$profile"/valid*.ttl; do
  name=$(basename "$file")

  # check if filter is set and skip if not matching
  if [ -n "$filter" ] && ! echo "$file" | grep -q "$filter"; then
    echo "ℹ️SKIP - $name"
    continue
  fi

  {
    if [ "$debug" = true ]; then
      echo "🐞 npx barnard59 cube check-metadata --profile $profilePath < $file"
    fi
    npx barnard59 cube check-metadata --profile "$profilePath" > "$file.log" 2>&1
    success=$?
  } < "$file"

  if [ $success -ne 0 ] ; then
    "$SCRIPT_PATH"/report-failure.sh "$file" "$(loadFullShape "$profilePath")" "$(cat "$file")"
    FAILED=1
  else
    echo "✅ PASS - $name"
  fi
done

# iterate over invalid cases
for file in "$SCRIPT_PATH"/"$profile"/{invalid,warning}*.ttl; do
  name=$(basename "$file")

  # skip if file does not exist
  if [ ! -f "$file" ]; then
    continue
  fi

  # check if pattern is set and skip if not matching
  if [ -n "$filter" ] && ! echo "$file" | grep -q "$filter"; then
    echo "ℹ️SKIP - $name"
    continue
  fi


    if [ "$debug" = true ]; then
      echo "🐞 npx barnard59 cube check-metadata --profile $profilePath < $file"
    fi
  report=$(npx barnard59 cube check-metadata --profile "$profilePath" < "$file" 2> "$file.log" | "$SCRIPT_PATH"/pretty-print.mjs)

  if ! echo "$report" | npx approvals "$name" --outdir "$SCRIPT_PATH"/"$profile" "$approvalsFlags" > /dev/null 2>&1 ; then
    "$SCRIPT_PATH"/report-failure.sh "$file" "$(loadFullShape "$profilePath")" "$(cat "$file")" "check results"
    FAILED=1
  else
    echo "✅ PASS - $name"
  fi
done

exit $FAILED
