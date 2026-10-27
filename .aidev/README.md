# Automated contributions

This directory configures the automated development platform that contributes to this
repository. This note says which branches it uses here and how its work reaches the
project's main line.

## Branches

- `aidev/integration` — the integration branch. Automated work lands here and nowhere else.
- `develop` — the project's main line; reached from `aidev/integration` only by merge request (`aidev handoff`, a linear one-commit-per-change copy on `aidev/handoff`, since `develop` is fast-forward only). Merge it **keeping the source branch**: `aidev/integration` is protected for that reason.
- `ai/*` — one branch per task, created and deleted by the platform. Do not commit to them.
- `session/*` — a session's accumulated work, landed on the integration branch as a batch.

## How work reaches the main line

Task and session branches never reach `aidev/integration` through merge requests; the platform
lands them after its own verification. `aidev/integration` reaches `develop` by this project's
usual process, merge requests included — the platform never merges into any other branch.

Whether this project's CI pipelines skip `ai/*` and `session/*` branches is decided by the
project's CI rules; maintainers record that decision here.

## Suites run before work lands

This repository is a documentation site (Retype) and has **no tests of its own**: every slot
runs the site's own CI checks, so several slots carry the same steps. Declared in
`.aidev/project.yaml` under `verification`, all through `.aidev/run-checks.sh`, which writes
`test-results/<slot>/junit.xml` (one case per step):

- `quick` — `command` .aidev/run-checks.sh quick lint snippets build
- `full` — `command` .aidev/run-checks.sh full lint snippets build
- `baseline` — `command` .aidev/run-checks.sh baseline build
- `canary` — `command` .aidev/run-checks.sh canary lint snippets build
- `static` — `command` .aidev/run-checks.sh static lint snippets
- `coverage` — `command` .aidev/run-checks.sh coverage build
- `system` — `command` .aidev/run-checks.sh system build

Steps: `lint` is `pnpm run lint` (markdownlint over `src/` without the snippets submodule — CI's
`lint` job and the pre-commit hook); `snippets` checks that every `:::code source="…"` include
in `src/` names a file that exists (they point into the `src/static/snippets` submodule,
hive/workerbee-doc-snippets; Retype itself only warns about a missing one); `build` is `retype build`
(CI's `build` job without its deployment-URL substitutions), failing on any error Retype prints.
Every run first installs `node_modules` offline (`.aidev/pnpm-deps.sh`). The submodules must be
checked out (`git submodule update --init --recursive`). There is nothing to measure coverage
of: `coverage` runs the build.

## Test runtime

`.aidev/runtime/Dockerfile` builds on common-ci-configuration's `node-test-tools:develop` (Node
and pnpm come from there; this repository pins no Node of its own in it) and adds the ICU
libraries Retype (.NET) needs and a pnpm store filled from `pnpm-lock.yaml`. Rebuild and re-pin
it with `.aidev/runtime/build.sh --push` when the Dockerfile or `pnpm-lock.yaml` changes, or to
follow a new `node-test-tools:develop`, and put the printed `repo@sha256:…` into
`environment.image`.

## Known state at onboarding (2026-10-26)

`lint` and `snippets` pass offline (35 includes, none missing). `build` **fails on `develop`**:
the lockfile's `retypeapp-linux-x64` 3.11.0 refuses to run — *"This release of Retype has
expired … A Retype license is required"* — and the project has no Retype key. This is the
release's own date check, not the sandbox, so CI's `build` job is expected to fail the same way (develop's last pipeline, 154756, ran in February). Moving to a
current Retype (4.6.0 on npm) brings it back; Retype 4.x also wants a real
`url:` in `retype.yml`.
