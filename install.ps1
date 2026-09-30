# Install the AI dev team for Claude Code (Windows PowerShell).
#   .\install.ps1                      -> user level (%USERPROFILE%\.claude), available in every project
#   .\install.ps1 -Project C:\path\repo -> one project (<repo>\.claude)
param([string]$Project)
$ErrorActionPreference = "Stop"
$src = Join-Path $PSScriptRoot ".claude"
$dest = if ($Project) { Join-Path $Project ".claude" } else { Join-Path $HOME ".claude" }
New-Item -ItemType Directory -Force -Path (Join-Path $dest "agents"), (Join-Path $dest "commands") | Out-Null
Copy-Item (Join-Path $src "agents\*.md") (Join-Path $dest "agents") -Force
Copy-Item (Join-Path $src "commands\*.md") (Join-Path $dest "commands") -Force
$settings = Join-Path $dest "settings.json"
if (Test-Path $settings) {
  Copy-Item (Join-Path $src "settings.json") (Join-Path $dest "ai-team.settings.example.json") -Force
  Write-Host "Existing settings.json kept. Merge permissions from: $dest\ai-team.settings.example.json"
} else {
  Copy-Item (Join-Path $src "settings.json") $settings
}
Write-Host "Installed AI dev team into $dest"
