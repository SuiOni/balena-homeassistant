#!/bin/sh

set -eu

author_query=${1:?author query is required}
case "$author_query" in
  *[!A-Za-z0-9%+_-]*)
    echo "Invalid author query" >&2
    exit 2
    ;;
esac

cookie_jar=$(mktemp)
trap 'rm -f "$cookie_jar"' EXIT
search_page=$(curl --fail --silent --show-error --location --compressed \
  --cookie "$cookie_jar" --cookie-jar "$cookie_jar" \
  --user-agent 'Mozilla/5.0 (Home Assistant)' \
  'https://www.nd-aktuell.de/suche/index.php')
csrf_token=$(printf '%s' "$search_page" | sed -n 's/.*name="csrf_token" value="\([^"]*\)".*/\1/p' | head -n 1)

if [ -z "$csrf_token" ]; then
  echo "Could not obtain ND Aktuell CSRF token" >&2
  exit 1
fi

curl --fail --silent --show-error --location --compressed \
  --cookie "$cookie_jar" --cookie-jar "$cookie_jar" \
  --user-agent 'Mozilla/5.0 (Home Assistant)' \
  "https://www.nd-aktuell.de/suche/index.php?csrf_token=${csrf_token}&and=${author_query}&search=Suchen&modus=0&sort=1&searchfields%5B%5D=4&display=1"