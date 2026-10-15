# hermes-desktop-standalone

Weekly bleeding-edge Linux AppImage builds of **Hermes Desktop** (light variant — remote-only client, no bundled Python/agent) from [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) `main`.

## Why

Upstream publishes Linux desktop builds nowhere (only macOS/Windows). This repo tracks `main` and produces a runnable AppImage every week — or on demand via *Run workflow*.

## Use

1. Download the newest `*.AppImage` from [Releases](../../releases).
2. `chmod +x Hermes-*.AppImage && ./Hermes-*.AppImage`
3. Point it at your Hermes backend (remote gateway) — it carries no local agent by design.

## Supply chain

- `build.sh` clones upstream at the exact resolved SHA, builds with the upstream's own pinned toolchain (`npm ci` respects upstream lockfiles).
- No signing (upstream publishes no signing material for Linux) — the AppImage is unsigned; verify provenance via `BUILD_INFO.txt` inside each release.
- Workflows pinned by action SHA.

## Not included

- Auto-update feed: self-built binaries declare `updateMechanism: self`. Re-download from Releases on each weekly build.
