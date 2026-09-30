#!/usr/bin/env bash
# Start the AI dev team in Docker for a project.
#   ./run.sh /path/to/your-repo
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PROJECT="${1:-}"
if [ -z "$PROJECT" ]; then echo "Usage: ./run.sh /path/to/your-repo" >&2; exit 1; fi
PROJECT="$(cd "$PROJECT" && pwd)"
[ -d "$PROJECT/.git" ] || { echo "Not a git repository: $PROJECT" >&2; exit 1; }
command -v docker >/dev/null || { echo "Docker is not installed. See README > Docker > Install Docker." >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo "Docker is not running. Start Docker Desktop (or the docker service) and try again." >&2; exit 1; }
[ -f "$HERE/.env" ] || { cp "$HERE/.env.example" "$HERE/.env"; echo "Created .env - fill in GH_TOKEN, GIT_USER_NAME, GIT_USER_EMAIL, then run again." >&2; exit 1; }
cd "$HERE"
docker image inspect ai-dev-team:latest >/dev/null 2>&1 || docker compose build
PROJECT_DIR="$PROJECT" docker compose run --rm ai-dev-team
