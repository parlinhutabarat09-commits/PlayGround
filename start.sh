#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd "$PROJECT_DIR"
PORT="${PORT:-3000}"
RUNNER_TEMP="${RUNNER_TEMP:-/home/runner/work/_temp}"
DEPLOYMENT_DIR="$PROJECT_DIR/dist"

run_timed() {
  /usr/bin/time -p "$@"
}

[[ "$PORT" =~ ^[0-9]+$ ]] || { echo "PORT must be numeric: $PORT" >&2; exit 1; }

if [[ -f package.json ]]; then
  if [[ -f package-lock.json ]]; then
    run_timed npm ci
  else
    run_timed npm install
  fi
fi

run_timed mkdir -p "$DEPLOYMENT_DIR"
run_timed cp Index.html "$DEPLOYMENT_DIR/index.html"
for asset in cover.png land.png player.png jungle.mp3 click.mp3; do
  if [[ -f "$asset" ]]; then
    run_timed cp "$asset" "$DEPLOYMENT_DIR/$asset"
  fi
done

run_timed mkdir -p "$RUNNER_TEMP/omgithub-web"
run_timed node -e 'const fs=require("node:fs"); const path=require("node:path"); const project=path.resolve(process.argv[1]); const directory=path.resolve(process.argv[2]); if (!directory.startsWith(project + path.sep)) throw new Error("Built static directory must be inside PROJECT_DIR"); fs.writeFileSync(process.argv[3], JSON.stringify({project,directory}, null, 2) + "\n")' "$PROJECT_DIR" "$DEPLOYMENT_DIR" "$RUNNER_TEMP/omgithub-web/deployment-output.json"

printf 'Serving %s on port %s\n' "$DEPLOYMENT_DIR" "$PORT"
exec /usr/bin/time -p python3 -m http.server "$PORT" --bind 0.0.0.0 --directory "$DEPLOYMENT_DIR"
