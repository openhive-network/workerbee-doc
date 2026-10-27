# The image AIDEV runs this project's suites in (`environment.image` in
# .aidev/project.yaml). Suites run with `--network none` and the caller's uid, so
# everything they need is in the image.
#
# Node and pnpm come from common-ci-configuration's node-test-tools image, the one
# hive's CI templates use; this file pins no Node version of its own. It adds a
# pnpm store filled from pnpm-lock.yaml (`pnpm fetch`), so `pnpm install
# --offline` links node_modules (markdownlint-cli, the Retype binary of
# retypeapp-linux-x64) in the sandbox.
#
# .aidev/runtime/build.sh builds it on the digest node-test-tools:develop names at
# the time; the result is pinned as `environment.image`.
ARG BASE_IMAGE=registry.gitlab.syncad.com/hive/common-ci-configuration/node-test-tools:develop
FROM ${BASE_IMAGE}
USER root
# The suite runs as an arbitrary uid with no passwd entry, so HOME must be a
# directory anyone can write. pnpm must not switch to `packageManager`'s version:
# that would download at run time, offline. The environment variable covers the
# outer pnpm only: the pnpm that `pnpm run <script>` starts for a script's own
# `pnpm exec` reads the setting from its global rc ($XDG_CONFIG_HOME/pnpm/rc).
ENV HOME=/tmp \
    XDG_CONFIG_HOME=/opt/xdg-config \
    npm_config_store_dir=/opt/pnpm-store \
    npm_config_manage_package_manager_versions=false \
    HUSKY=0 \
    CI=1 \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DO_NOT_TRACK=1
# Retype is a self-contained .NET program and needs the ICU libraries, which the
# base image does not carry (it refuses to start in invariant-globalization mode).
RUN apt-get update \
    && icu="$(apt-cache search --names-only '^libicu[0-9]+$' | cut -d' ' -f1 | sort -V | tail -1)" \
    && apt-get install -y --no-install-recommends "${icu:?no libicu package}" \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/xdg-config/pnpm \
    && printf 'manage-package-manager-versions=false\n' > /opt/xdg-config/pnpm/rc \
    && chmod -R a+rX /opt/xdg-config
COPY pnpm-lock.yaml /tmp/pnpm-fetch/
RUN cd /tmp/pnpm-fetch \
    && pnpm fetch \
    && cd / && rm -rf /tmp/pnpm-fetch /tmp/.npm /tmp/.cache \
    && chmod -R a+rwX /opt/pnpm-store
