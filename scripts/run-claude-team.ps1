param(
    [string]$PromptFile,
    [string]$PromptText,
    [string]$DebugLogPath,
    [string]$ClaudeCommand = "claude",
    [switch]$Dangerous
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($PromptFile) -and [string]::IsNullOrWhiteSpace($PromptText)) {
    throw "Provide either -PromptFile or -PromptText."
}

if (-not [string]::IsNullOrWhiteSpace($PromptFile)) {
    if (-not (Test-Path -LiteralPath $PromptFile)) {
        throw "Prompt file not found: $PromptFile"
    }

    $prompt = Get-Content -LiteralPath $PromptFile -Raw -Encoding UTF8
} else {
    $prompt = $PromptText
}

if ([string]::IsNullOrWhiteSpace($prompt)) {
    throw "Prompt content is empty."
}

if ([string]::IsNullOrWhiteSpace($DebugLogPath)) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $DebugLogPath = Join-Path $env:TEMP "claude-agent-team-$stamp.log"
}

Remove-Item -LiteralPath $DebugLogPath -ErrorAction SilentlyContinue

$env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"

$args = @("-p", "--debug-file", $DebugLogPath)
if ($Dangerous) {
    $args = @("--dangerously-skip-permissions") + $args
}

$prompt | & $ClaudeCommand @args
Write-Output "DEBUG_PATH=$DebugLogPath"
