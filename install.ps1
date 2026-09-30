# Manual install of the AI dev team (Windows PowerShell): agents, commands, safety hook, permissions.
#   .\install.ps1                        -> user level (%USERPROFILE%\.claude), every project on this machine
#   .\install.ps1 -Project C:\path\repo  -> one project (<repo>\.claude). Commit it to use the team
#                                          from Claude Code on the web / the mobile app too.
param([string]$Project)
$ErrorActionPreference = "Stop"
$src = $PSScriptRoot
if ($Project) {
  $Project = (Resolve-Path $Project).Path
  $dest = Join-Path $Project ".claude"
  $settingsSrc = Join-Path $src "settings\project-settings.json"
} else {
  $dest = Join-Path $HOME ".claude"
  $settingsSrc = Join-Path $src "settings\user-settings.json"
}
New-Item -ItemType Directory -Force -Path (Join-Path $dest "agents"), (Join-Path $dest "commands"), (Join-Path $dest "hooks") | Out-Null
Copy-Item (Join-Path $src "agents\*.md") (Join-Path $dest "agents") -Force
Copy-Item (Join-Path $src "commands\*.md") (Join-Path $dest "commands") -Force
Copy-Item (Join-Path $src "hooks\guard.sh") (Join-Path $dest "hooks\guard.sh") -Force
$settings = Join-Path $dest "settings.json"
if (Test-Path $settings) {
  Copy-Item $settingsSrc (Join-Path $dest "ai-team.settings.example.json") -Force
  Write-Host "Existing settings.json kept. Merge permissions and the PreToolUse hook from: $dest\ai-team.settings.example.json"
} else {
  Copy-Item $settingsSrc $settings
}
if ($Project) {
  $gi = Join-Path $Project ".gitignore"
  if (-not (Test-Path $gi)) { New-Item -ItemType File -Path $gi | Out-Null }
  if (-not (Select-String -Path $gi -Pattern '^ai-runs/$' -Quiet)) { Add-Content $gi "`n# AI dev team run logs`nai-runs/" }
  Write-Host "Installed into $dest. Commit .claude\ and .gitignore so cloud and mobile sessions get the team:"
  Write-Host "  git add .claude .gitignore; git commit -m 'Add AI dev team'; git push"
} else {
  Write-Host "Installed AI dev team into $dest"
}
