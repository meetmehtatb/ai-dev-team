# Start the AI dev team in Docker for a project (Windows PowerShell).
#   .\run.ps1 C:\path\to\your-repo
param([Parameter(Mandatory = $true)][string]$Project)
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$Project = (Resolve-Path $Project).Path
if (-not (Test-Path (Join-Path $Project ".git"))) { throw "Not a git repository: $Project" }
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw "Docker is not installed. See README > Docker > Install Docker." }
docker info *> $null
if ($LASTEXITCODE -ne 0) { throw "Docker is not running. Start Docker Desktop and try again." }
$envFile = Join-Path $here ".env"
if (-not (Test-Path $envFile)) {
  Copy-Item (Join-Path $here ".env.example") $envFile
  Write-Host "Created .env - fill in GH_TOKEN, GIT_USER_NAME, GIT_USER_EMAIL, then run again."
  exit 1
}
$code = 0
Push-Location $here
try {
  docker image inspect ai-dev-team:latest *> $null
  if ($LASTEXITCODE -ne 0) {
    docker compose build
    $code = $LASTEXITCODE
    if ($code -ne 0) { Write-Host "docker compose build failed (exit $code)" -ForegroundColor Red }
  }
  if ($code -eq 0) {
    $env:PROJECT_DIR = $Project
    docker compose run --rm ai-dev-team
    $code = $LASTEXITCODE
  }
} finally {
  Pop-Location
}
exit $code
