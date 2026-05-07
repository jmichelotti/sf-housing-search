#!/usr/bin/env bash
cd "$(dirname "$0")"

separator="$(printf '=%.0s' {1..60})"
echo -e "\n${separator}\nRUN: $(date '+%Y-%m-%d %H:%M:%S')\n${separator}" >> tracker-log.txt

claude -p "Run a housing search session as described in CLAUDE.md" \
  --model claude-sonnet-4-6 \
  --allowedTools "mcp__playwright__*,WebSearch,WebFetch,Bash,Read,Edit,Write" \
  2>&1 | tee tracker-latest.txt >> tracker-log.txt

if git diff --quiet listings.md; then
  echo "No changes to listings.md — skipping commit." >> tracker-log.txt
else
  git add listings.md
  git commit -m "chore: update listings tracker ($(date '+%Y-%m-%d %H:%M'))"
  git push
  echo "Committed and pushed listings.md updates." >> tracker-log.txt
fi

send_run_email() {
  local key_file="$HOME/.config/resend/key"
  if [[ ! -r $key_file ]]; then
    echo "[email] missing $key_file — skipping" >> tracker-log.txt
    return 0
  fi
  local key
  key=$(cat "$key_file")

  local body_file="tracker-latest.txt"
  local subject_suffix=""
  if [[ ! -s $body_file ]]; then
    body_file="$(mktemp)"
    echo "(no output captured from claude run — check tracker-log.txt)" > "$body_file"
    subject_suffix=" — no output"
  else
    local new_count
    new_count=$(grep -oE 'New finds this session \([0-9]+\)' "$body_file" \
      | head -1 | grep -oE '[0-9]+' || true)
    if [[ -n $new_count ]]; then
      subject_suffix=" — ${new_count} new"
    fi
  fi

  local subject
  subject="SF Housing $(date '+%Y-%m-%d %H:%M')${subject_suffix}"

  local payload
  payload=$(jq -n \
    --arg from "SF Housing <sf-housing@thunderheadflix.com>" \
    --arg to "hopkinshousecp@gmail.com" \
    --arg subject "$subject" \
    --rawfile text "$body_file" \
    '{from: $from, to: [$to], subject: $subject, text: $text}')

  local resp_file
  resp_file=$(mktemp)
  local http_status
  http_status=$(curl -sS -o "$resp_file" -w '%{http_code}' \
    -X POST https://api.resend.com/emails \
    -H "Authorization: Bearer $key" \
    -H "Content-Type: application/json" \
    -d "$payload" || echo "curl_failed")

  if [[ $http_status == 200 ]]; then
    echo "[email] sent ($subject)" >> tracker-log.txt
  else
    echo "[email] FAILED status=$http_status body=$(cat "$resp_file")" >> tracker-log.txt
  fi
  rm -f "$resp_file"
}

send_run_email
