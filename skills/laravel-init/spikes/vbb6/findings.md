# VBB 6: vite-plus 1.0.0 (oxlint 1.85.0) against the VBB 2, 3 and 5 results

Result: PASS on every item. But 1.0.0 needs one change that 0.3.0 did not need. The starter's
`vite` dependency must resolve to `@voidzero-dev/vite-plus-core`. Without it, `vp build` fails.
`vite.config.ts` needs NO diff. The change is in `package.json` and `pnpm-workspace.yaml`.

Installed: vite-plus 1.0.0, oxlint 1.85.0 (`vp lint --version` prints "Version: 1.85.0"),
vite 8.3.1, rolldown 1.2.11, vitest 5.0.1, oxfmt 0.70.0, oxlint-tsgolint 7.0.2003, @shadcn/lint 0.2.0, knip 6.39.0.

## Trap found: a stale npm install hides the real oxlint version
The APP had a `node_modules/.package-lock.json` and real directories (not pnpm symlinks) from an earlier npm install.
After `pnpm add -D vite-plus@latest`, `vp lint --version` still printed 1.79.0, because vp resolves the
stale top-level `node_modules/oxlint`. `pnpm why oxlint` printed 1.85.0, so the two disagreed.
Fix used: move `node_modules` aside (kept as `node_modules/.old-npm`, because a recursive force delete is not allowed) and run `pnpm install`.
After that: `vp lint --version` = 1.85.0. All results below come from the clean tree.
VBB 2 and VBB 3 ran on the polluted tree (their fixtures print oxlint 1.79.0). Their rule IDs still hold on 1.85.0 (items 4 and 5).
A template must never run npm in a pnpm project.

## 1. Commit before the upgrade: PASS
`git commit` "vbb 2/3/5 state" = f68e7de.

## 2. Upgrade and breaking changes: PASS
`pnpm add -D vite-plus@latest @shadcn/lint@0.2.0` gave vite-plus 1.0.0.
Sources: `gh api repos/voidzero-dev/vite-plus/releases/tags/v1.0.0`, `v1.0.0-rc.0`, `v1.0.0-rc.1`, and node_modules/vite-plus/docs/guide/migrate.md.
v1.0.0 = v1.0.0-rc.1 with no code changes. 0.3.3 is the last 0.x release.

Breaking changes from 0.3 to 1.0:
- defineConfig and lazyPlugins: NO breaking change in the release notes. The `lazyPlugins` import still works (item 3 and the unchanged vite.config.ts prove it).
  rc.1 fix: async `defineConfig` callbacks now type-check lint and fmt options (no TS2769 on 'warn' severities).
- lint and fmt blocks: NO key renamed. rc.0: `vp lint`, `vp fmt` and `vp check` use native config discovery. rc.1: `vp lint` and `vp fmt` run from a package directory use the same config as the editor; `vp check` applies the workspace-root settings.
  The new oxlint (1.85) and oxfmt (0.70) "can flag or format code that passed before. Run `vp fmt` after upgrading if CI runs `vp check`."
- `vp` CLI:
  - The `oxlint` and `oxfmt` executable wrappers are removed from the `vite-plus` package. Use `vp lint --lsp`, `vp fmt --lsp`, `vp fmt --stdin-filepath`. Proof: `pnpm exec oxlint` now prints `Command "oxlint" not found`. A template must call `vp lint`, never `oxlint`.
  - Node.js range is now `^22.18.0 || ^24.11.0 || >=26.0.0` (Node 20 dropped).
  - `vp staged` needs Node `^22.22.1 || ^24.11.0 || >=26.0.0` and Git >= 2.32.0.
  - `vp test` uses vitest 5.0.1 (Vitest 5 migration guide applies; `vite-plus/test/runners`, `vite-plus/test/suite`, `vite-plus/test/browser-webdriverio` removed).
  - `run.tasks` keys `env`, `untrackedEnv`, `input`, `output` move under `cache`. The starter has no `run` block. No impact.
  - Library builds use tsdown 0.23. The starter has no `pack` block. No impact.
- Not in the release notes but real (found by running): 1.0.0 checks that a project's `vite` resolves to `@voidzero-dev/vite-plus-core` of the same release. See item 3.

## 3. vp check and vp build: PASS with the migrate step (FAIL without it)
Without alignment (after only `pnpm add`): `vp build` exit 1.
  error: Failed to resolve vite command: GenericFailure, Expected @voidzero-dev/vite-plus-core@1.0.0, but found vite@8.3.2 ... Run `vp migrate` to align the Vite alias, then run `vp install`.
`vp check` exit 2 in that state (it also scanned node_modules/.old-npm, an unrelated cause; ignore).
A hand-written `overrides: vite@*: npm:@voidzero-dev/vite-plus-core@1.0.0` in pnpm-workspace.yaml did NOT fix it. pnpm printed "Already up to date" and kept vite 8.3.2.
Fix that worked: `pnpm exec vp migrate --no-interactive --no-agent --no-editor --no-hooks`. It edits only package.json, pnpm-workspace.yaml and the lockfile (see package.json.diff and pnpm-workspace.yaml in this folder):
- `vite` and `vite-plus` move to `catalog:` references. The catalog maps `vite` to `npm:@voidzero-dev/vite-plus-core@1.0.0` and `vite-plus` to `1.0.0`.
- `overrides: vite@*: 'catalog:'` and a `peerDependencyRules` block (allowAny vite, allowedVersions vite '*') are added.
- `devEngines.packageManager` is added with name pnpm, version 12.9.1 (the local pnpm), onFail download. SIDE EFFECT: review this field. A template should pin it on purpose or strip it.
- vite.config.ts is NOT touched (`git diff f68e7de -- vite.config.ts` prints 0 lines).
After migrate:
- `vp build` exit 0 ("built in 2.96s").
- `vp check` exit 1. Formatting: "pass: All 71 files are correctly formatted". Lint: "Found 206 errors and 23 warnings in 64 files". No config error. The failure is the stock starter breaking the shadcn rules, same as VBB 2.
  Counts by rule: 92 shadcn(no-arbitrary-values), 54 shadcn(no-raw-colors), 52 shadcn(no-restyle), 1 shadcn(no-inline-styles). These four match VBB 2 exactly.
  Other rules hit in the starter: 9 jsx-a11y(no-autofocus), 12 jsx-a11y(tabindex-no-positive), 2 jsx-a11y(prefer-tag-over-role), 4 react(forbid-component-props) (prefetch on Link), 3 react(jsx-no-target-blank).
  The VBB 3 run E (0.3.0) showed no-autofocus and tabindex-no-positive as warnings too. UNVERIFIED: whether the target-blank, prefetch and prefer-tag-over-role hits also existed under 0.3.0. I did not diff them.

## 4. VBB 3 probe on 1.0.0: PASS (every rule ID verbatim, from `vp lint`, oxlint 1.85.0)
- eslint(no-unused-vars) on `const unused`
- eslint(no-restricted-globals) on `setInterval`
- eslint(no-restricted-properties) on `window.setInterval`
- jsx-a11y(alt-text) on `<img>` without alt
- jsx-a11y(label-has-associated-control) on `<label>Name</label>`
- jsx-a11y(no-static-element-interactions) on `<div onClick>` (also jsx-a11y(click-events-have-key-events) as a warning)
- react(jsx-no-target-blank) on `<a target="_blank">` without rel
- react(forbid-component-props): "Do not set prefetch on Link." on `<Link prefetch>`
- react(forbid-dom-props): "No prefetch on DOM." on `<section prefetch>`
Message text and positions match vbb3/output.txt.

Bare `<input>` question: NO oxlint 1.85.0 rule flags a bare input with no label. Proof: all 35 jsx-a11y rules from node_modules/oxlint/configuration_schema.json set to error, run on a file with `<input type="text">`, `<input type="password">`, `<textarea>`, `<select>` and an empty `<button>`. Only the button was flagged (control-has-associated-label, line 8). The only two label rules are label-has-associated-control (checks `<label>` elements) and control-has-associated-label (skips input, textarea, select by default, as in eslint-plugin-jsx-a11y).
`vp lint --rules` and the oxlint `--rules` flag print nothing when output is piped (exit 0). The rule list came from the schema instead. UNVERIFIED: the `--rules` output in a TTY.

## 5. VBB 2 probe with @shadcn/lint 0.2.0 on 1.0.0: PASS (verbatim)
- shadcn(no-arbitrary-values): "bg-[#ff0000]" hardcodes a color. Nearest theme tokens: bg-destructive, bg-chart-1.
- shadcn(no-arbitrary-values): "p-[13px]" hardcodes an off-token value. Use "p-3.25" instead
- shadcn(no-unknown-classes): "rounded-huge" is not a class this project's Tailwind knows
- shadcn(no-inline-styles): Inline style sets color.
- shadcn(no-restyle): "bg-red-500" is not allowed on <Button>: <Button> owns its color. Use a variant: default, destructive, outline, secondary, ghost, link.
- shadcn(no-raw-colors): "bg-red-500" uses the raw Tailwind palette.
- shadcn(require-static-classes): Dynamically built className on <Button> cannot be checked.
No option shape changed: `['error', { allow: ['layout'] }]` still loads.

## 6. knip with vbb5/knip.json: PASS
knip.json is byte-identical to vbb5/knip.json. Knip 6.39.0, exit 1 on findings. Results match VBB 5:
unused files (4: app-header.tsx, app-header-layout.tsx, auth-card-layout.tsx, auth-split-layout.tsx), unused dependency concurrently, unlisted @inertiajs/core, unused types TwoFactorSetupData and TwoFactorSecretKey.
Negative control: `neverImportedSpikeFn  function  resources/js/lib/utils.ts:14:17` was reported by name.
Knip still loads vite.config.ts (`--debug` lists vite.config.ts as a config file and 'dependency:@shadcn/lint (vite.config.ts)' as a plugin dependency).

## 7. Cleanup: PASS
Removed resources/js/pages/spike-probe.tsx and the temp a11y probe files. utils.ts restored from HEAD (git status shows no change under resources/).
Left in APP: node_modules/.old-npm (inside the git-ignored node_modules; removal needs a recursive delete).
APP has uncommitted package.json, pnpm-lock.yaml and pnpm-workspace.yaml changes from the migrate step. Commit "vbb6 upgrade to 1.0.0 (manual overrides attempt)" holds the pre-migrate state.

## vite.config.ts diff needed vs 0.3.0
None. The working file is saved here as vite.config.ts and equals the VBB 2/3/5 file. The required 1.0 change is in package.json (see package.json.diff) and pnpm-workspace.yaml.

## UNVERIFIED
- Whether `vp migrate` is the minimum fix. A smaller change (only the catalog entry, or removing `vite` from package.json) was not tested. The hand-written override did fail.
- `vp migrate` on a fresh `laravel new` starter with another pnpm version. It wrote pnpm 12.9.1 into devEngines from this machine.
- Alignment after a later patch release (1.0.1).
- `vp test` on 1.0.0 (vitest 5). Not run.
