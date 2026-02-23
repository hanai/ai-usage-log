#!/bin/bash
set -euo pipefail

REPO="$HOME/.ai-usage-log"
cd "$REPO"

git pull --ff-only

node "$REPO/scripts/sync.mjs"

git add cc/
if ! git diff --cached --quiet; then
	git commit -m "sync: $(date +%Y-%m-%d)"
	git push
fi
