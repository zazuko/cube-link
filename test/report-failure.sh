SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

file=$1
name=$(basename "$file")

message=$4
if [ -z "$message" ]; then
  message="check report"
fi

playground=$("$SCRIPT_PATH"/shorten-report.js "$2" "$3")
echo "❌ FAIL - $name. $message: $playground"

# git diff non interactive
if [ -f "$1".approved.txt ]; then
  printf '\n'
  git diff --color --no-index "$1".approved.txt "$1".received.txt | cat
fi
