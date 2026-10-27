#!/usr/bin/env bash
# Run the checks named after the suite and write test-results/<suite>/junit.xml.
#
#   .aidev/run-checks.sh <suite> <step>...
#
# This repository is a documentation site (Retype) and has no tests of its own;
# the slots run its CI jobs. Every run first installs node_modules offline
# (.aidev/pnpm-deps.sh). Steps, one junit case each:
#
#   lint      markdownlint over src/ without the snippets submodule (`pnpm run
#             lint`, CI's lint job and the pre-commit hook)
#   snippets  every `:::code source="…"` include in src/ names a file that
#             exists (they point into the src/static/snippets submodule,
#             hive/workerbee-doc-snippets); Retype only warns about a missing one
#   build     `retype build` into .retype/ (CI's build job, without its
#             deployment-URL substitutions in retype.yml), failing on any
#             error Retype reports
#
# Runs offline in the image of .aidev/runtime/Dockerfile.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
root="$PWD"
suite="${1:?usage: $0 <suite> <step>...}"; shift
out="$root/test-results/$suite"
rm -rf "$out"; mkdir -p "$out"
cases="$out/cases.tsv"; : > "$cases"
source .aidev/junit-helpers.sh

status=0
step() {
    local name="$1"; shift
    local log="$out/$name.log" t0=$SECONDS rc=0
    echo "== $name" >&2
    ( cd "$root" && "$@" ) > "$log" 2>&1 < /dev/null || rc=$?
    if [ "$rc" -eq 0 ]; then
        printf 'case\t%s\tpass\t%s\t\n' "$name" "$((SECONDS - t0))" >> "$cases"
    else
        status=1; tail -40 "$log" >&2
        printf 'case\t%s\tfail\t%s\texit %s\t%s\n' "$name" "$((SECONDS - t0))" "$rc" "$log" >> "$cases"
    fi
    return "$rc"
}

if ! source "$root/.aidev/pnpm-deps.sh"; then
    printf 'case\tinstall\tfail\t0\tpnpm install --offline failed\n' >> "$cases"
    junit_write_cases "$out/junit.xml" "$suite" "$cases"
    exit 1
fi

# The included files are resolved relative to the page, as Retype does.
snippets() {
    [ -d src/static/snippets/src ] || { echo "src/static/snippets is empty: git submodule update --init"; return 1; }
    local missing=0 checked=0 md ref
    while IFS=: read -r md ref; do
        checked=$((checked + 1))
        [ -f "$(dirname "$md")/$ref" ] || { echo "$md: missing $ref"; missing=$((missing + 1)); }
    done < <(grep -roP --include='*.md' ':::code source="\K[^"]+' src)
    echo "$checked snippet include(s) checked, $missing missing"
    [ "$checked" -gt 0 ] || { echo "no :::code includes found in src/"; return 1; }
    [ "$missing" -eq 0 ]
}

# Retype exits 0 on most content problems and prints them as errors; a line
# starting with "Error" (or Retype's ✗ marker) fails the step.
build() {
    local log="$out/retype.log" rc=0
    pnpm exec retype build 2>&1 | tee "$log" || rc=${PIPESTATUS[0]}
    [ "$rc" -eq 0 ] || return "$rc"
    if grep -qiE '^\s*(error|✗)' "$log"; then echo "retype reported errors" >&2; return 1; fi
    [ -f .retype/index.html ] || { echo "retype wrote no .retype/index.html" >&2; return 1; }
}

for s in "$@"; do
    case "$s" in
        lint) step lint pnpm run lint ;;
        snippets) step snippets snippets ;;
        build) step build build ;;
        *) printf 'case\t%s\tfail\t0\tunknown step\n' "$s" >> "$cases"; status=1 ;;
    esac
done
junit_write_cases "$out/junit.xml" "$suite" "$cases"
exit "$status"
