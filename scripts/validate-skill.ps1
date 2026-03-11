Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

$requiredFiles = @(
    "SKILL.md",
    "README.md",
    "README.ja.md",
    "LICENSE",
    ".gitignore",
    "agents/openai.yaml",
    "references/prompt-patterns.md",
    "assets/cc-orchestrator-cli-skill.svg",
    "scripts/run-claude-team.ps1",
    "scripts/validate-skill.ps1"
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Missing required file: $relativePath"
    }
}

$skillText = Get-Content (Join-Path $root "SKILL.md") -Raw -Encoding UTF8
$yamlText = Get-Content (Join-Path $root "agents/openai.yaml") -Raw -Encoding UTF8
$readmeText = Get-Content (Join-Path $root "README.md") -Raw -Encoding UTF8
$readmeJaText = Get-Content (Join-Path $root "README.ja.md") -Raw -Encoding UTF8

if ($skillText -notmatch '(?m)^name:\s+cc-orchestrator-cli-skill\s*$') {
    throw "SKILL.md name must be cc-orchestrator-cli-skill"
}

if ($yamlText -notmatch '\$cc-orchestrator-cli-skill') {
    throw "agents/openai.yaml default prompt must reference $cc-orchestrator-cli-skill"
}

if ($readmeText -notmatch 'README\.ja\.md') {
    throw "README.md must link to README.ja.md"
}

if ($readmeJaText -notmatch 'README\.md') {
    throw "README.ja.md must link to README.md"
}

Write-Output "VALIDATION_OK"
