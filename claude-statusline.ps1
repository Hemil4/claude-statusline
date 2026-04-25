# ─────────────────────────────────────────────────────────────────────────────
# claude-statusline — Real-time usage monitor for Claude Code (Windows)
#
# PowerShell version for native Windows support.
# Shows session limit, weekly limit, context window, cost, and model
# directly in Claude Code's status bar.
# ─────────────────────────────────────────────────────────────────────────────

# Read JSON from stdin (Claude Code pipes session data)
$input = [Console]::In.ReadToEnd()
$data = $input | ConvertFrom-Json

# ── Extract data ─────────────────────────────────────────────────────────

$fiveHr = $data.rate_limits.five_hour.used_percentage
$fiveReset = $data.rate_limits.five_hour.resets_at
$sevenDay = $data.rate_limits.seven_day.used_percentage
$sevenReset = $data.rate_limits.seven_day.resets_at
$ctxPct = [math]::Floor($data.context_window.used_percentage)
$cost = $data.cost.total_cost_usd
$modelName = $data.model.display_name

# ── Shorten model name ──────────────────────────────────────────────────

function Get-ShortModel($name) {
    if ($name -match "Opus")   { return "Opus" }
    if ($name -match "Sonnet") { return "Sonnet" }
    if ($name -match "Haiku")  { return "Haiku" }
    return ($name -replace '\s*\(.*', '')
}
$model = Get-ShortModel $modelName

# ── Terminal width ───────────────────────────────────────────────────────

try { $cols = $Host.UI.RawUI.WindowSize.Width } catch { $cols = 80 }

# ── Colors (ANSI) ────────────────────────────────────────────────────────

$GREEN  = "`e[32m"
$YELLOW = "`e[33m"
$RED    = "`e[31m"
$DIM    = "`e[2m"
$BOLD   = "`e[1m"
$RESET  = "`e[0m"

function Get-PctColor($pct) {
    if ($pct -ge 80) { return $RED }
    if ($pct -ge 50) { return $YELLOW }
    return $GREEN
}

# ── Progress bar ─────────────────────────────────────────────────────────

function Make-Bar($pct, $width = 10) {
    $pct = [math]::Floor($pct)
    $filled = [math]::Min($width, [math]::Floor(($pct * $width) / 100))
    $empty = $width - $filled
    $color = Get-PctColor $pct
    $bar = ("$([char]0x2588)" * $filled) + ("$([char]0x2591)" * $empty)
    return "${color}${bar}${RESET}"
}

# ── Format reset time ────────────────────────────────────────────────────

function Format-Reset($timestamp) {
    if (-not $timestamp) { return "" }
    try {
        $epoch = [DateTimeOffset]::FromUnixTimeSeconds([long]$timestamp)
        $local = $epoch.ToLocalTime()
        return $local.ToString("h:mmtt").ToLower()
    } catch {
        return ""
    }
}

# ── Format cost ──────────────────────────────────────────────────────────

function Format-Cost($c) {
    if (-not $c -or $c -eq 0) { return "" }
    return "`${0:F2}" -f $c
}

# ── Build responsive output ─────────────────────────────────────────────

$fivePct = if ($fiveHr) { [math]::Floor($fiveHr) } else { 0 }
$sevenPct = if ($sevenDay) { [math]::Floor($sevenDay) } else { 0 }
$fiveTime = Format-Reset $fiveReset
$sevenTime = Format-Reset $sevenReset
$costStr = Format-Cost $cost

$fiveColor = Get-PctColor $fivePct
$sevenColor = Get-PctColor $sevenPct

$out = ""

if ($cols -ge 120) {
    # Wide: full detail with bars
    $bar = Make-Bar $fivePct 10
    $out = "${DIM}${model}${RESET}"
    if ($fiveHr)   { $out += " | ${bar} ${fivePct}%" }
    if ($fiveTime) { $out += " ${DIM}reset ${fiveTime}${RESET}" }
    if ($sevenDay) { $out += " | Wk: ${sevenColor}${sevenPct}%${RESET}" }
    if ($sevenTime){ $out += " ${DIM}${sevenTime}${RESET}" }
    $out += " | Ctx: ${ctxPct}%"
    if ($costStr)  { $out += " | ${costStr}" }
}
elseif ($cols -ge 90) {
    # Medium: bar + percentages, no reset times
    $bar = Make-Bar $fivePct 8
    $out = "${DIM}${model}${RESET}"
    if ($fiveHr)   { $out += " | ${bar} ${fivePct}%" }
    if ($sevenDay) { $out += " | Wk: ${sevenColor}${sevenPct}%${RESET}" }
    $out += " | Ctx: ${ctxPct}%"
    if ($costStr)  { $out += " | ${costStr}" }
}
elseif ($cols -ge 60) {
    # Narrow: compact
    $out = "${DIM}${model}${RESET}"
    if ($fiveHr)   { $out += " ${fiveColor}S:${fivePct}%${RESET}" }
    if ($sevenDay) { $out += " ${sevenColor}W:${sevenPct}%${RESET}" }
    $out += " C:${ctxPct}%"
    if ($costStr)  { $out += " ${costStr}" }
}
else {
    # Very narrow
    $out = "${model}"
    if ($fiveHr) { $out += " ${fiveColor}${fivePct}%${RESET}" }
}

Write-Host $out
