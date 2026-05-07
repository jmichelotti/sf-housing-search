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
