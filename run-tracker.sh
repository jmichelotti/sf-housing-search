#!/usr/bin/env bash
cd "$(dirname "$0")"
claude -p "Run a housing search session as described in CLAUDE.md" \
  --model claude-sonnet-4-6 \
  --allowedTools "mcp__playwright__*,WebSearch,WebFetch,Bash,Read,Edit,Write" \
  >> tracker-log.txt 2>&1
