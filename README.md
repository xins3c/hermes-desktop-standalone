# hermes-desktop-standalone

Weekly bleeding-edge Linux **AppImage** builds of **Hermes Desktop** (variant `light` — remote-only client, no bundled Python/agent) from [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) `main`.

## Why this repo exists

At [getting-started/installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation) upstream publishes desktop packages for **macOS** (`Hermes-Setup.dmg`) and **Windows** (`Hermes-Setup.exe`) only — both carrying a bundled local agent. To use them against a remote backend you install the package and connect via **Settings → Gateways**. Two gaps:

1. **No Linux download at all** — on Linux upstream expects the terminal install (`install.sh`), which pulls the agent runtime, even if you only want the GUI client.
2. **No separate remote-only download for any platform** — the `light` build variant exists in the source tree but has never had a release leg (confirmed in upstream's `apps/desktop/BUILDING.md`).

This repo closes both for Linux: it builds the **`light`** variant from upstream `main` every week — an Electron client with **no Python runtime, no local agent** (~1/10 the size), meant to be pointed at an already-running Hermes backend (e.g. `hermes serve` on your server).

If you want a full local agent on Linux, use the official terminal install instead; if you already run your agent on a server and just want the native GUI on your Linux desktop, this is for you.

## Use

1. Download the newest `*.AppImage` from [Releases](../../releases).
2. `chmod +x Hermes*.AppImage`
3. In the app: **Settings → Gateways → Remote gateway** → your backend URL → sign in.

## Supply chain

- `build.sh` clones upstream at the exact resolved SHA and builds with upstream's own pinned toolchain (`npm ci` respects upstream lockfiles — no registry-side upgrades).
- Actions pinned by commit SHA; `BUILD_INFO.txt` in each release carries `ref`/`sha`/`built` provenance.
- Unsigned builds (upstream publishes no Linux signing material).

## Not included

- Auto-update feed: self-built binaries declare `updateMechanism: self` — re-download from Releases weekly.
