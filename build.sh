#!/usr/bin/env bash
# Build Hermes Desktop (light = remote-only client) from a pinned upstream ref.
# Consumed by .github/workflows/build-desktop.yml — not meant for manual use.
set -euo pipefail

REF="${1:?usage: build.sh <ref>}"          # upstream tag, branch or full SHA
UPSTREAM="https://github.com/NousResearch/hermes-agent.git"

# 1. Resolve ref -> full SHA (fail closed on anything unresolvable).
SHA="$(git ls-remote "$UPSTREAM" "refs/heads/$REF" "refs/tags/$REF" "refs/tags/${REF}^{}" | awk 'NR==1{print $1}')"
[ -n "$SHA" ] || { echo "unresolvable ref: $REF" >&2; exit 1; }
echo "building upstream $REF -> $SHA"

# 2. Shallow clean checkout exactly at that SHA.
rm -rf src
git clone --filter=blob:none --no-checkout --depth 1 "$UPSTREAM" src
git -C src fetch --depth 1 origin "$SHA"
git -C src checkout --detach "$SHA"
cd src

# 3. Build. PM pins its own Python/Node; host only needs python3.11+ and git.
bash scripts/build-bundle.sh --variant light

# 4. Hand artifacts + provenance to the caller.
mkdir -p ../out
cp -v apps/desktop/release/* ../out/ 2>/dev/null || true
printf 'ref=%s\nsha=%s\nbuilt=%s\n' "$REF" "$SHA" "$(date -u +%FT%TZ)" > ../out/BUILD_INFO.txt
ls -lh ../out
