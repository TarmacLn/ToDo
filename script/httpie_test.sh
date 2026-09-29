#!/usr/bin/env bash
# Tests every endpoint of the Todos API with httpie, including the error cases.
#
# Start the server first:   bin/rails server
# Then run:                 script/httpie_test.sh
# Save the output:          script/httpie_test.sh | tee docs/httpie-output.txt
#
# Needs httpie (brew install httpie) and jq.
set -euo pipefail

HOST="${HOST:-:3000}"
EMAIL="httpie-$(date +%s)@example.com"
PASSWORD="password123"
TOKEN=""

# Colors in the terminal, plain text when the output is saved to a file
if [ -t 1 ]; then PRETTY=all; else PRETTY=format; fi

LAST_RESPONSE="$(mktemp)"
trap 'rm -f "$LAST_RESPONSE"' EXIT

step() {
  printf '\n\n=== %s ===\n' "$1"
}

# Print the command (with the token shown as $TOKEN), then run it and show the
# response status line and body (the other headers are left out to keep it short)
run() {
  printf '$ http'
  for arg in "$@"; do
    [ -n "$TOKEN" ] && arg="${arg//$TOKEN/\$TOKEN}"
    if [[ "$arg" == *" "* ]]; then printf " '%s'" "$arg"; else printf ' %s' "$arg"; fi
  done
  printf '\n\n'

  http --ignore-stdin --unsorted --pretty="$PRETTY" --print=hb "$@" | only_status_line | tee "$LAST_RESPONSE"
}

# Keep the first line of the headers (e.g. "HTTP/1.1 200 OK") and the body
only_status_line() {
  awk '
    { plain = $0; gsub(/\x1b\[[0-9;]*m/, "", plain) }
    NR == 1 { in_headers = 1; print; next }
    in_headers && plain !~ /^[[:space:]]*$/ { next }
    { in_headers = 0; print }
  '
}

# Read a field from the JSON body of the last response
last_json() {
  sed $'s/\x1b\\[[0-9;]*m//g' "$LAST_RESPONSE" | sed '1,/^[[:space:]]*$/d' | jq -r "$1"
}

step "1. Sign up (201)"
run POST "$HOST/signup" name=Ioanna "email=$EMAIL" "password=$PASSWORD" "password_confirmation=$PASSWORD"

step "2. Sign up with an email that is already taken (422)"
run POST "$HOST/signup" name=Ioanna "email=$EMAIL" "password=$PASSWORD"

step "3. Log in with a wrong password (401)"
run POST "$HOST/auth/login" "email=$EMAIL" password=wrong

step "4. Log in (200)"
run POST "$HOST/auth/login" "email=$EMAIL" "password=$PASSWORD"
TOKEN="$(last_json .auth_token)"

step "5. List todos without a token (401)"
run GET "$HOST/todos"

step "6. Create a todo (201)"
run -A bearer -a "$TOKEN" POST "$HOST/todos" title=Groceries
TODO_ID="$(last_json .id)"

step "7. Create a todo without a title (422)"
run -A bearer -a "$TOKEN" POST "$HOST/todos" title=""

step "8. Create a second todo (201)"
run -A bearer -a "$TOKEN" POST "$HOST/todos" title=Homework
SECOND_TODO_ID="$(last_json .id)"

step "9. Create a todo item (201)"
run -A bearer -a "$TOKEN" POST "$HOST/todos/$TODO_ID/items" name="Buy milk"
ITEM_ID="$(last_json .id)"

step "10. Create a todo item that is already done (201)"
run -A bearer -a "$TOKEN" POST "$HOST/todos/$TODO_ID/items" name="Buy bread" done:=true

step "11. List all todos and todo items (200)"
run -A bearer -a "$TOKEN" GET "$HOST/todos"

step "12. Get a todo (200)"
run -A bearer -a "$TOKEN" GET "$HOST/todos/$TODO_ID"

step "13. Update a todo (204)"
run -A bearer -a "$TOKEN" PUT "$HOST/todos/$TODO_ID" title="Weekly groceries"

step "14. Get a todo item (200)"
run -A bearer -a "$TOKEN" GET "$HOST/todos/$TODO_ID/items/$ITEM_ID"

step "15. Update a todo item: mark it as done (204)"
run -A bearer -a "$TOKEN" PUT "$HOST/todos/$TODO_ID/items/$ITEM_ID" done:=true

step "16. Get the todo item again to see the change (200)"
run -A bearer -a "$TOKEN" GET "$HOST/todos/$TODO_ID/items/$ITEM_ID"

step "17. Delete a todo item (204)"
run -A bearer -a "$TOKEN" DELETE "$HOST/todos/$TODO_ID/items/$ITEM_ID"

step "18. Get the deleted todo item (404)"
run -A bearer -a "$TOKEN" GET "$HOST/todos/$TODO_ID/items/$ITEM_ID"

step "19. Delete a todo and its items (204)"
run -A bearer -a "$TOKEN" DELETE "$HOST/todos/$SECOND_TODO_ID"

step "20. Get the deleted todo (404)"
run -A bearer -a "$TOKEN" GET "$HOST/todos/$SECOND_TODO_ID"

step "21. Log out (200)"
run -A bearer -a "$TOKEN" GET "$HOST/auth/logout"

step "22. Use the token after logging out (401)"
run -A bearer -a "$TOKEN" GET "$HOST/todos"
