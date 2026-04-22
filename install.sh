#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# claude-statusline installer
# One command to add real-time usage monitoring to Claude Code
# ─────────────────────────────────────────────────────────────────────────────

REPO="Hemil4/claude-statusline"
SCRIPT_NAME="claude-statusline.sh"
INSTALL_DIR="$HOME/.claude"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

info()    { printf "  ${CYAN}>${RESET} %s\n" "$1"; }
success() { printf "  ${GREEN}✔${RESET} %s\n" "$1"; }
warn()    { printf "  ${YELLOW}!${RESET} %s\n" "$1"; }
error()   { printf "  ${RED}✘${RESET} %s\n" "$1"; exit 1; }

install() {
    echo ""
    printf "  ${BOLD}claude-statusline${RESET} — installer\n"
    printf "  ${DIM}Real-time usage monitor for Claude Code${RESET}\n"
    echo ""

    # Check jq
    if ! command -v jq >/dev/null 2>&1; then
        if command -v brew >/dev/null 2>&1; then
            info "Installing jq..."
            brew install jq
        else
            error "jq is required. Install: brew install jq"
        fi
    fi

    # Check claude
    if ! command -v claude >/dev/null 2>&1; then
        warn "Claude Code not found. Install it first."
    fi

    # Download script to ~/.claude/
    mkdir -p "$INSTALL_DIR"

    info "Downloading statusline script..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/${SCRIPT_NAME}" -o "${INSTALL_DIR}/${SCRIPT_NAME}"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "${INSTALL_DIR}/${SCRIPT_NAME}" "https://raw.githubusercontent.com/${REPO}/main/${SCRIPT_NAME}"
    else
        error "curl or wget is required."
    fi
    chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
    success "Script installed to ${INSTALL_DIR}/${SCRIPT_NAME}"

    # Configure settings.json
    local settings_file="$INSTALL_DIR/settings.json"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi

    if grep -q "claude-statusline" "$settings_file" 2>/dev/null; then
        success "Already configured in settings.json"
    else
        info "Configuring status line..."
        python3 -c "
import json

with open('$settings_file', 'r') as f:
    settings = json.load(f)

settings['statusLine'] = {
    'type': 'command',
    'command': 'bash $INSTALL_DIR/$SCRIPT_NAME',
    'refreshInterval': 10
}

with open('$settings_file', 'w') as f:
    json.dump(settings, f, indent=2)

print('ok')
" && success "Configured in $settings_file" || error "Failed to configure"
    fi

    echo ""
    success "Installation complete!"
    echo ""
    printf "  ${BOLD}What you'll see:${RESET}\n"
    printf "  ${DIM}  Opus | ██░░░░░░░░ 15%% reset 4:30PM | Wk: 48%% | Ctx: 35%% | \$0.05${RESET}\n"
    echo ""
    printf "  ${BOLD}Restart Claude Code${RESET} to activate.\n"
    printf "  ${DIM}  The status line updates after every response — same data as /usage.${RESET}\n"
    echo ""
}

uninstall() {
    echo ""
    printf "  ${BOLD}claude-statusline${RESET} — uninstaller\n"
    echo ""

    # Remove script
    if [ -f "${INSTALL_DIR}/${SCRIPT_NAME}" ]; then
        rm -f "${INSTALL_DIR}/${SCRIPT_NAME}"
        success "Removed ${INSTALL_DIR}/${SCRIPT_NAME}"
    fi

    # Remove from settings.json
    local settings_file="$INSTALL_DIR/settings.json"
    if [ -f "$settings_file" ]; then
        python3 -c "
import json
with open('$settings_file', 'r') as f:
    settings = json.load(f)
if 'statusLine' in settings:
    del settings['statusLine']
with open('$settings_file', 'w') as f:
    json.dump(settings, f, indent=2)
print('ok')
" && success "Removed from settings.json" || warn "Could not update settings.json"
    fi

    echo ""
    info "Restart Claude Code to apply."
    echo ""
}

case "${1:-}" in
    uninstall|--uninstall) uninstall ;;
    *)                     install ;;
esac
