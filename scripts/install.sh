#!/bin/bash
set -euo pipefail

LABEL="com.hanai.ai-usage-sync"
REPO="$HOME/.ai-usage-log"
CONFIG_DIR="$REPO/config"
PLIST_PATH="$CONFIG_DIR/$LABEL.plist"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"

if [ -z "${AI_USAGE_DEVICE:-}" ]; then
	echo "Error: AI_USAGE_DEVICE environment variable is not set"
	echo "Example: AI_USAGE_DEVICE=macbook-pro bash scripts/install.sh"
	exit 1
fi

NODE_BIN="$(which node)"
if [ -z "$NODE_BIN" ]; then
	echo "Error: node not found in PATH"
	exit 1
fi

mkdir -p "$CONFIG_DIR" "$LAUNCH_AGENTS" "$REPO/logs"

cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$LABEL</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>$REPO/scripts/run.sh</string>
	</array>
	<key>EnvironmentVariables</key>
	<dict>
		<key>PATH</key>
		<string>$(dirname "$NODE_BIN"):/usr/bin:/bin</string>
		<key>AI_USAGE_DEVICE</key>
		<string>$AI_USAGE_DEVICE</string>
	</dict>
	<key>StartCalendarInterval</key>
	<dict>
		<key>Hour</key>
		<integer>9</integer>
		<key>Minute</key>
		<integer>0</integer>
	</dict>
	<key>StandardOutPath</key>
	<string>$REPO/logs/sync.log</string>
	<key>StandardErrorPath</key>
	<string>$REPO/logs/sync.error.log</string>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
PLIST

# Unload existing if any
launchctl unload "$LAUNCH_AGENTS/$LABEL.plist" 2>/dev/null || true

cp "$PLIST_PATH" "$LAUNCH_AGENTS/$LABEL.plist"
launchctl load "$LAUNCH_AGENTS/$LABEL.plist"

echo "Installed: $LABEL"
echo "Runs daily at 09:00"
echo "Logs: $REPO/logs/"
