#!/usr/bin/env bash
# Build Hermes Desktop light (remote-only client) from a pinned upstream ref.
set -euo pipefail

REF="${1:?usage: build.sh <ref>}"
UPSTREAM="https://github.com/NousResearch/hermes-agent.git"

# 1. Ref -> full SHA; fail closed.
SHA="$(git ls-remote "$UPSTREAM" "refs/heads/$REF" "refs/tags/$REF" "refs/tags/${REF}^{}" | awk 'NR==1{print $1}')"
[ -n "$SHA" ] || { echo "unresolvable ref: $REF" >&2; exit 1; }
echo "building upstream $REF -> $SHA"

# 2. Clean detached checkout at that exact SHA.
rm -rf src
git clone --filter=blob:none --no-checkout --depth 1 "$UPSTREAM" src
git -C src fetch --depth 1 origin "$SHA"
git -C src checkout --detach "$SHA"
cd src

PY=python3
"$PY" -c 'import sys; assert sys.version_info >= (3, 11)'

# 3. Prepare once (PM pins its own Pythons/Node; work/cache must be inside the
#    checkout so .gitignore keeps the tree clean for the consumer's own check).
$PY scripts/bundles/desktop.py --commit "$SHA" --variant light \
   --prepare-only --work "$PWD/.build/desktop-job" --cache "$PWD/.cache/desktop-inputs"

# 4. Patch the icons toolset (upstream CJS/module-type bug) + republish manifests.
node patch-icons-toolset.mjs "$PWD"

# 5. Consume: package the AppImage.
$PY scripts/bundles/desktop.py --prepared "$PWD/.build/desktop-job/prepared.json"

# 6. Artifacts out.
mkdir -p ../out
cp -v apps/desktop/release/*.AppImage ../out/
printf 'ref=%s\nsha=%s\nbuilt=%s\n' "$REF" "$SHA" "$(date -u +%FT%TZ)" > ../out/BUILD_INFO.txt
ls -lh ../out
