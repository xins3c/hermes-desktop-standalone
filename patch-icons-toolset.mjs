// Fix upstream bug: apps/desktop/package.json declares "type":"module" but the
// prepared icon-tool.js bundle is CommonJS. Linux is the only consumer that
// executes it via node + toolsets.icons. Adding {"type":"commonjs"} to the toolset
// directory fixes module resolution; prepared.json is republished because the
// consumer admits toolsets by tree digest.
// Upstream candidate fix: rename to icon-tool.cjs in electron-userland toolset.
import fs from 'node:fs'
import path from 'node:path'
import { pathToFileURL } from 'node:url'

const root = process.argv[2]
if (!root) throw new Error('usage: patch-icons-toolset.mjs <repo-root>')
const packager = path.join(root, '.build/desktop-job/packager')
const manifest = path.join(packager, 'prepared.json')

const { publishPackagingInputs, readPackagingInputs } = await import(
  pathToFileURL(path.join(root, 'apps/desktop/scripts/prepared-packaging.mjs')).href)
const prepared = readPackagingInputs(manifest, root, 'linux-x64')

fs.writeFileSync(path.join(prepared.toolsets.icons, 'package.json'),
  JSON.stringify({ type: 'commonjs', private: true }, null, 2) + '\n')

// Republish into the same packager directory (publisher writes <out>/prepared.json).
await publishPackagingInputs({ ...prepared, out: packager })

// The job-level manifest digest-caches the packager manifest — refresh it.
const jobManifest = path.join(root, '.build/desktop-job/prepared.json')
const job = JSON.parse(fs.readFileSync(jobManifest, 'utf8'))
const { createHash } = await import('node:crypto')
job.digests[manifest] = createHash('sha256')
  .update(fs.readFileSync(manifest)).digest('hex')
fs.writeFileSync(jobManifest, JSON.stringify(job, null, 1))
console.log('icons toolset patched (CJS marker) + manifests republished')
