# ai-usage-log

Personal AI tool usage data log. Currently tracks [Claude Code](https://claude.ai/code) via [ccusage](https://github.com/hanai/ccusage).

## Data Structure

```
cc/
└── {device}/
    └── YYYYMM.json   # monthly usage, keyed by date → model breakdowns
```

Each monthly file:

```json
{
  "2026-02-15": [
    {
      "modelName": "claude-sonnet-4-20250514",
      "inputTokens": 800,
      "outputTokens": 150,
      "cacheCreationTokens": 30,
      "cacheReadTokens": 80,
      "cost": 0.008
    }
  ]
}
```

## Setup

Clone to `~/.ai-usage-log`:

```bash
git clone https://github.com/hanai/ai-usage-log.git ~/.ai-usage-log
```

Set device name in your shell profile (`~/.zshrc`):

```bash
export AI_USAGE_DEVICE=macbook-pro
```

Install the daily sync task (macOS launchd):

```bash
cd ~/.ai-usage-log
bash scripts/install.sh
```

This generates a plist in `config/`, copies it to `~/Library/LaunchAgents/`, and loads it. The task runs daily at 09:00 and also on every boot/login.

## Manual Sync

```bash
# Run sync script directly
node ~/.ai-usage-log/scripts/sync.mjs

# Or trigger the launchd job
launchctl start com.hanai.ai-usage-sync
```

## Logs

```
~/.ai-usage-log/logs/sync.log
~/.ai-usage-log/logs/sync.error.log
```
