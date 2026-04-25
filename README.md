<p align="center">
  <h1 align="center">claude-statusline</h1>
  <p align="center">
    Real-time usage monitor for Claude Code.<br>
    See your limits without typing <code>/usage</code>.
  </p>
  <p align="center">
    <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue" alt="Platform">
    <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
    <img src="https://img.shields.io/badge/shell-bash-yellow" alt="Shell">
    <img src="https://img.shields.io/badge/requires-jq-orange" alt="Requires jq">
  </p>
</p>

---

## The Problem

You're coding with Claude. Is your session limit at 20% or 80%? You don't know unless you stop and type `/usage`. By then, you might already be rate-limited.

## The Solution

**claude-statusline** shows your real usage data at the bottom of Claude Code — always visible, always updating. No extra terminal, no polling, no estimation.

```
Opus | ██░░░░░░░░ 15% reset 4:30PM | Wk: 48% | Ctx: 35% | $0.05
```

This is **real data from Anthropic's servers** — the same numbers `/usage` shows.

---

## Install

**One command:**

```bash
curl -fsSL https://raw.githubusercontent.com/Hemil4/claude-statusline/main/install.sh | sh
```

Then restart Claude Code. That's it.

<details>
<summary><strong>Manual install</strong></summary>

```bash
# Download
curl -fsSL https://raw.githubusercontent.com/Hemil4/claude-statusline/main/claude-statusline.sh -o ~/.claude/claude-statusline.sh
chmod +x ~/.claude/claude-statusline.sh

# Add to settings
# Edit ~/.claude/settings.json and add:
# "statusLine": {
#   "type": "command",
#   "command": "bash ~/.claude/claude-statusline.sh",
#   "refreshInterval": 10
# }
```

</details>

<details>
<summary><strong>Requirements</strong></summary>

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (v2.0+)
- [jq](https://jqlang.github.io/jq/) — `brew install jq` (macOS) or `sudo apt install jq` (Linux/WSL)
- macOS, Linux, or Windows (via WSL)

</details>

<details>
<summary><strong>Windows users</strong></summary>

This tool requires bash, so it doesn't run natively on PowerShell or CMD. Use **WSL (Windows Subsystem for Linux)** instead:

1. [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install) if you haven't: `wsl --install`
2. Open your WSL terminal
3. Install jq: `sudo apt install jq`
4. Run the install command above
5. Use Claude Code from within WSL

Most Windows developers using Claude Code already run it in WSL — so this should just work.

</details>

---

## What You See

The status line adapts to your terminal width:

### Wide terminal (120+ chars)
```
Opus | ██░░░░░░░░ 15% reset 4:30PM | Wk: 48% 9:46AM | Ctx: 35% | $0.05
```

### Medium terminal (90-119 chars)
```
Opus | ██░░░░░░ 15% | Wk: 48% | Ctx: 35% | $0.05
```

### Narrow terminal (60-89 chars)
```
Opus S:15% W:48% C:35% $0.05
```

### Very narrow (<60 chars)
```
Opus 15%
```

## What Each Part Means

| Part | Description |
|---|---|
| `Opus` | Current model (updates when you switch) |
| `██░░░░░░░░ 15%` | 5-hour session limit usage (green/yellow/red) |
| `reset 4:30PM` | When the 5-hour window resets |
| `Wk: 48%` | 7-day weekly limit usage |
| `Ctx: 35%` | Context window usage |
| `$0.05` | Session cost |

### Color Coding

- **Green** — under 50% (you're fine)
- **Yellow** — 50-80% (heads up)
- **Red** — over 80% (consider switching tasks or waiting)

---

## How It Works

Claude Code has a built-in status line feature that pipes JSON session data to your script via stdin. This JSON includes **real rate limit data from Anthropic's servers**:

```json
{
  "rate_limits": {
    "five_hour": { "used_percentage": 15, "resets_at": 1745317800 },
    "seven_day": { "used_percentage": 48, "resets_at": 1745468200 }
  },
  "context_window": { "used_percentage": 35 },
  "cost": { "total_cost_usd": 0.05 },
  "model": { "display_name": "Opus 4.6 (1M context)" }
}
```

The script reads this JSON, formats it, and outputs a single line. No API calls, no tokens consumed, no external services.

---

## FAQ

<details>
<summary><strong>Does it use my API tokens?</strong></summary>

No. The status line runs locally and reads data that Claude Code already has. Zero extra API calls.

</details>

<details>
<summary><strong>Is the data real or estimated?</strong></summary>

Real. It's the same data that `/usage` shows — directly from Anthropic's servers. Not an estimate.

</details>

<details>
<summary><strong>Does it work with Claude Pro and Max?</strong></summary>

Yes. Rate limit data (`five_hour`, `seven_day`) appears for all Claude.ai subscribers (Pro/Max). API-only users will see context window and cost data.

</details>

<details>
<summary><strong>Does it update when I switch models?</strong></summary>

Yes. The model name and rate limits update automatically after each response.

</details>

<details>
<summary><strong>Can I customize it?</strong></summary>

Yes — it's a single bash script. Edit `~/.claude/claude-statusline.sh` to change colors, layout, or add your own data.

</details>

---

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/Hemil4/claude-statusline/main/install.sh | sh -s -- --uninstall
```

Or manually:
```bash
rm ~/.claude/claude-statusline.sh
# Remove the "statusLine" entry from ~/.claude/settings.json
```

---

## Works With

- **Regular `claude` command** — no extra tools needed
- **[claude-multi](https://github.com/Hemil4/claude-multi)** — multi-account manager (shows profile name too)
- **Any Claude Code setup** — just needs `jq` and bash

---

## License

MIT — see [LICENSE](LICENSE)

---

<p align="center">
  <strong>Stop guessing. Start seeing.</strong><br>
  <sub>Your usage limits, always visible.</sub>
</p>
