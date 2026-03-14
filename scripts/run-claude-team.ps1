param(
    [string]$PromptFile,
    [string]$PromptText,
    [string]$DebugLogPath,
    [string]$ClaudeCommand = "claude",
    [switch]$Dangerous,
    [ValidateSet("Auto", "None", "AlibabaCloud", "Zai")]
    [string]$Provider = "Auto",
    [switch]$UseAlibabaCloud,
    [switch]$UseZai,
    [string]$AlibabaApiKey = $env:ALIBABA_API_KEY,
    [string]$AlibabaBaseUrl = "https://coding-intl.dashscope.aliyuncs.com/apps/anthropic",
    [string]$AlibabaModel = "qwen3.5-plus",
    [string]$ZaiApiKey = $env:ZAI_API_KEY,
    [string]$ZaiBaseUrl = "https://api.z.ai/api/anthropic",
    [string]$ZaiApiTimeoutMs = "3000000",
    [string]$ZaiHaikuModel = "glm-4.5-air",
    [string]$ZaiSonnetModel = "glm-4.7",
    [string]$ZaiOpusModel = "glm-4.7"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-EnvVarValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $item = Get-Item -LiteralPath "Env:$Name" -ErrorAction SilentlyContinue
    if ($null -eq $item) {
        return $null
    }

    return $item.Value
}

function Set-EnvVarValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [AllowNull()]
        [string]$Value
    )

    if ($null -eq $Value) {
        Remove-Item -LiteralPath "Env:$Name" -ErrorAction SilentlyContinue
        return
    }

    Set-Item -LiteralPath "Env:$Name" -Value $Value
}

if ([string]::IsNullOrWhiteSpace($PromptFile) -and [string]::IsNullOrWhiteSpace($PromptText)) {
    throw "Provide either -PromptFile or -PromptText."
}

if (-not [string]::IsNullOrWhiteSpace($PromptFile)) {
    if (-not (Test-Path -LiteralPath $PromptFile)) {
        throw "Prompt file not found: $PromptFile"
    }

    $prompt = Get-Content -LiteralPath $PromptFile -Raw -Encoding UTF8
}
else {
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

$args = @("-p", "--debug-file", $DebugLogPath)
if ($Dangerous) {
    $args = @("--dangerously-skip-permissions") + $args
}

if ($UseAlibabaCloud.IsPresent -and $UseZai.IsPresent) {
    throw "Use either -UseAlibabaCloud or -UseZai, not both."
}

$selectedProvider = $Provider

if ($UseAlibabaCloud.IsPresent) {
    if ($selectedProvider -ne "Auto" -and $selectedProvider -ne "AlibabaCloud") {
        throw "-UseAlibabaCloud cannot be combined with -Provider $selectedProvider."
    }

    $selectedProvider = "AlibabaCloud"
}

if ($UseZai.IsPresent) {
    if ($selectedProvider -ne "Auto" -and $selectedProvider -ne "Zai") {
        throw "-UseZai cannot be combined with -Provider $selectedProvider."
    }

    $selectedProvider = "Zai"
}

if ($selectedProvider -eq "Auto") {
    if (-not [string]::IsNullOrWhiteSpace($AlibabaApiKey)) {
        $selectedProvider = "AlibabaCloud"
    }
    elseif (-not [string]::IsNullOrWhiteSpace($ZaiApiKey)) {
        $selectedProvider = "Zai"
    }
    else {
        $selectedProvider = "None"
    }
}

switch ($selectedProvider) {
    "AlibabaCloud" {
        if ([string]::IsNullOrWhiteSpace($AlibabaApiKey)) {
            throw "Alibaba Cloud mode requires -AlibabaApiKey or ALIBABA_API_KEY."
        }
    }
    "Zai" {
        if ([string]::IsNullOrWhiteSpace($ZaiApiKey)) {
            throw "Z.ai mode requires -ZaiApiKey or ZAI_API_KEY."
        }
    }
}

$scopedEnvNames = @(
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS",
    "ANTHROPIC_AUTH_TOKEN",
    "ANTHROPIC_BASE_URL",
    "ANTHROPIC_MODEL",
    "API_TIMEOUT_MS",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL",
    "ANTHROPIC_DEFAULT_SONNET_MODEL",
    "ANTHROPIC_DEFAULT_OPUS_MODEL"
)

$previousEnv = @{}
foreach ($name in $scopedEnvNames) {
    $previousEnv[$name] = Get-EnvVarValue -Name $name
}

try {
    Set-EnvVarValue -Name "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" -Value "1"

    switch ($selectedProvider) {
        "AlibabaCloud" {
            Set-EnvVarValue -Name "ANTHROPIC_AUTH_TOKEN" -Value $AlibabaApiKey
            Set-EnvVarValue -Name "ANTHROPIC_BASE_URL" -Value $AlibabaBaseUrl
            Set-EnvVarValue -Name "ANTHROPIC_MODEL" -Value $AlibabaModel
            Set-EnvVarValue -Name "API_TIMEOUT_MS" -Value $null
            Set-EnvVarValue -Name "ANTHROPIC_DEFAULT_HAIKU_MODEL" -Value $null
            Set-EnvVarValue -Name "ANTHROPIC_DEFAULT_SONNET_MODEL" -Value $null
            Set-EnvVarValue -Name "ANTHROPIC_DEFAULT_OPUS_MODEL" -Value $null
        }
        "Zai" {
            Set-EnvVarValue -Name "ANTHROPIC_AUTH_TOKEN" -Value $ZaiApiKey
            Set-EnvVarValue -Name "ANTHROPIC_BASE_URL" -Value $ZaiBaseUrl
            Set-EnvVarValue -Name "ANTHROPIC_MODEL" -Value $null
            Set-EnvVarValue -Name "API_TIMEOUT_MS" -Value $ZaiApiTimeoutMs
            Set-EnvVarValue -Name "ANTHROPIC_DEFAULT_HAIKU_MODEL" -Value $ZaiHaikuModel
            Set-EnvVarValue -Name "ANTHROPIC_DEFAULT_SONNET_MODEL" -Value $ZaiSonnetModel
            Set-EnvVarValue -Name "ANTHROPIC_DEFAULT_OPUS_MODEL" -Value $ZaiOpusModel
        }
        "None" {
            Set-EnvVarValue -Name "ANTHROPIC_AUTH_TOKEN" -Value $previousEnv["ANTHROPIC_AUTH_TOKEN"]
            Set-EnvVarValue -Name "ANTHROPIC_BASE_URL" -Value $previousEnv["ANTHROPIC_BASE_URL"]
            Set-EnvVarValue -Name "ANTHROPIC_MODEL" -Value $previousEnv["ANTHROPIC_MODEL"]
            Set-EnvVarValue -Name "API_TIMEOUT_MS" -Value $previousEnv["API_TIMEOUT_MS"]
            Set-EnvVarValue -Name "ANTHROPIC_DEFAULT_HAIKU_MODEL" -Value $previousEnv["ANTHROPIC_DEFAULT_HAIKU_MODEL"]
            Set-EnvVarValue -Name "ANTHROPIC_DEFAULT_SONNET_MODEL" -Value $previousEnv["ANTHROPIC_DEFAULT_SONNET_MODEL"]
            Set-EnvVarValue -Name "ANTHROPIC_DEFAULT_OPUS_MODEL" -Value $previousEnv["ANTHROPIC_DEFAULT_OPUS_MODEL"]
        }
    }

    $prompt | & $ClaudeCommand @args
}
finally {
    foreach ($name in $scopedEnvNames) {
        Set-EnvVarValue -Name $name -Value $previousEnv[$name]
    }
}

Write-Output "DEBUG_PATH=$DebugLogPath"
