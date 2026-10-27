# Sourced by run-checks.sh from the repository root: bring node_modules up to
# date with pnpm-lock.yaml from the image's pnpm store, offline. Lifecycle
# scripts are skipped (the only one is husky's `prebuild`, a git hook installer).
# A marker records the lockfile and Node it was installed for; it is written only
# after an install that succeeded, and an install whose tools don't resolve is redone.
lock_id="$(sha256sum pnpm-lock.yaml | cut -d' ' -f1) $(node --version)"
marker=node_modules/.aidev-pnpm-lock
tools_present() {
    local t
    for t in retype markdownlint; do [ -x "node_modules/.bin/$t" ] || return 1; done
}
if [ "$(cat "$marker" 2>/dev/null)" != "$lock_id" ] || ! tools_present; then
    echo "node_modules is not current for pnpm-lock.yaml: pnpm install --offline" >&2
    pnpm install --offline --frozen-lockfile --ignore-scripts < /dev/null || return 1
    tools_present || { echo "pnpm install left no retype/markdownlint" >&2; return 1; }
    printf '%s\n' "$lock_id" > "$marker.tmp" && mv "$marker.tmp" "$marker"
fi
