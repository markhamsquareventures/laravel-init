---
name: laravel-init
version: 1.2.0
license: MIT
description: Set up a Laravel 13 + Inertia + React project past the starter kit, and encode an opinionated set of coding rules in the codebase as checks that fail the build. Installs Pest browser and arch tests, Larastan level 8 with disallowed-calls and dead-code detection, 100% type coverage, oxlint a11y and React rules, @shadcn/lint, knip, nitpick, Boost rules, and one `composer gate`. Fresh mode runs on a new starter; retrofit mode audits an existing repo and asks per rule whether to fix or baseline. Use when asked to "set up this Laravel project", "laravel-init", "harden the starter", or "retrofit the rules into this repo".
argument-hint: fresh | retrofit
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Agent
  - AskUserQuestion
---

# Laravel Init

You set up one Laravel repo so that the coding rules are enforced, not only remembered. The `.ai/rules` files give agents the context. PHPStan, Pest arch tests, oxlint and knip catch the departures.

The template files in `templates/` are the source of truth. Copy them. Do not write them again from memory. A repo copy is a snapshot. The `.ai/rules` files state each rule, and `RULES.md` next to this file gives the reason for each one.

## Principles

1. **Copy the templates, then change only the listed values** (app name, DB driver, pnpm version). Fresh generation drifts between projects.
2. **Fix residue, do not exempt it.** Starter code that breaks a rule is residue, not precedent. Do not add an exemption list, a `@phpstan-ignore`, or a lint disable to get green. The two allowed exceptions are in the templates: `App\Actions\Fortify` (Fortify contracts) and `ResetUserPassword::reset` in the dead-code detector (a container call).
3. **A gate counts only when a negative control proves it engaged.** For each gate family, introduce one violation, confirm that the output names the expected rule ID, then revert. An exit code alone proves nothing.
4. **Leave all work uncommitted.** The user commits. Never commit a violation, even to revert it.
5. **pnpm only.** Never run npm in the project. A stale npm tree hides the versions that pnpm installs.
6. **One subagent at a time for code changes.** Give each residue phase (marked "delegated") to one subagent. Paste the phase text, the relevant `.ai/rules` files and the phase's check into its prompt, and tell it to leave the tree uncommitted. Do not trust its report. Before you close the phase, verify the work with `git status`, `git diff` and grep, and run the phase's check yourself.
7. **Read text output, not agent JSON.** In an agent shell, PHPStan and Pest print JSON because of `AI_AGENT`. When a check must read the text (rule IDs, messages), run it through `${CLAUDE_SKILL_DIR}/scripts/plain <command>`, for example `scripts/plain vendor/bin/phpstan analyse --error-format=raw`. The script unsets `AI_AGENT`, `CLAUDECODE` and `CLAUDE_CODE_ENTRYPOINT` and removes ANSI color codes. Do not keep the command in a shell variable.

## Step 0. Detect

Find and state these facts in one short block:

- Repo root, current branch, and whether the tree is clean.
- **Mode.** No `artisan` file: stop. This skill starts from an installed starter (`laravel new <name> --react --pest --pnpm`). An `artisan` file and no commits past the starter commits ("Set up a fresh Laravel app", "Install Pest"): fresh. All other repos: retrofit. An argument overrides the detection. Confirm the mode in one line and continue.
- React present (`resources/js/app.tsx`). If not, skip every JS step.
- `DB_CONNECTION` in `.env.example`, PHP version (`php -v`), pnpm version (`pnpm -v`), the vite-plus version, and the shadcn `style` in `components.json`.
- The run plan goes in `docs/features/laravel-init/plan.md`.
- Whether a dev server runs already (for example `composer run dev`, Herd or Valet). Use it for the browser passes. Start one only when none runs.
- **Base UI.** In fresh mode, ask the user once whether to migrate the starter from Radix UI to Base UI (Phase 4). Recommend yes. If the user says yes, confirm that the `migrate-radix-to-base` skill is installed. If it is not, tell the user to install it with `npx skills add shadcn/ui --skill migrate-radix-to-base`, then skip Phase 4 for this run and record the skip in the run plan.

## Fresh mode

Run the phases in this order. Each phase ends with its own check green before the next phase starts.

### Phase 1. Install and configure

PHP:

Set `"php": "^8.4"` in composer.json first. pest-plugin-browser v5 and nitpick need it.

```bash
composer require --dev spaze/phpstan-disallowed-calls shipmonk/dead-code-detector \
  pestphp/pest-plugin-browser pestphp/pest-plugin-type-coverage pestphp/pest-plugin-phpstan \
  pestphp/pest-plugin-agent laravel/boost markhamsq/nitpick
php artisan nitpick:install
```

- Boost has no TTY in an agent shell, so its package prompt cannot be answered. Write `boost.json` as `{"agents": ["claude_code"], "packages": ["markhamsq/nitpick", "pestphp/pest-plugin-agent"]}`, write `CLAUDE.md` with the single line `@AGENTS.md` (Boost 2.10 uses CLAUDE.md only to detect Claude Code, and writes the guidelines to AGENTS.md), then run `php artisan boost:install --no-interaction`. Non-interactive mode sets `"cloud": true` and installs the `deploying-to-cloud` skill; keep that unless the user says otherwise.
- Copy `templates/phpstan.neon` and `templates/disallowed-calls.neon` to the repo root.
- Merge `templates/composer-scripts.json` into composer.json `scripts`, then run `composer update --lock`.
- In `AppServiceProvider::configureDefaults()`, add `Model::shouldBeStrict(! app()->isProduction());`. The starter already sets `CarbonImmutable` and `prohibitDestructiveCommands`.
- phpunit.xml: add `Arch` (`tests/Arch`) and `Browser` (`tests/Browser`) test suites. Pest stops when a suite directory is missing, so run `mkdir -p tests/Browser && touch tests/Browser/.gitkeep`. Phase 6 deletes the `.gitkeep`. Set the `DB_*` values to the app's driver (see `templates/ci.md`).
- tests/Pest.php: add a separate block for browser tests, `pest()->extend(TestCase::class)->use(RefreshDatabase::class)->in('Browser');`. Do not add `Browser` to the Feature block when that block calls `withoutVite()` or other per-test setup, because browser tests render the built assets. Remove the starter's example `toBeOne` expectation and `something()` function (dead code).
- Copy `templates/tests/Arch/ArchitectureTest.php`.
- Add `/tests/Browser/Screenshots` and `/storage/nitpick` to `.gitignore`.

JS:

Installer 5.32 with `--pnpm` can leave an npm tree: it commits `package-lock.json`, deletes it, and its pnpm step fails. If `node_modules/.package-lock.json` exists, move `node_modules` out of the repo (do not delete it recursively) and run `pnpm install`. Confirm that `pnpm-lock.yaml` exists before you continue.

```bash
pnpm add -D vite-plus@latest knip @shadcn/lint@latest playwright
pnpm exec vp migrate --full --no-interactive --no-agent --no-editor --no-hooks
pnpm exec playwright install chromium
pnpm exec vp fmt
```

- `vp migrate` maps `vite` to vite-plus-core through the pnpm catalog. A hand-written override does not work. Remove the `devEngines` block that it adds to package.json (it pins this machine's pnpm).
- `--full` converts the ESLint and Prettier configs. Without it, oxfmt uses its defaults and reformats most files. Port `.prettierignore` and any Prettier `overrides` (for example, a 2-space YAML indent) into the `fmt` block. Add `.claude/**`, `.cursor/**`, `.mcp.json`, `public/**`, `storage/**` and the test fixtures to `fmt.ignorePatterns` before the first `vp fmt`.
- pnpm 11 stops `pnpm install` on build scripts that are not approved, and writes a placeholder (`esbuild: set this to true or false`) to `pnpm-workspace.yaml`. Set `allowBuilds: { esbuild: true }` there and install again.
- Merge `templates/vite-lint.ts` into the `lint` block of vite.config.ts. The `plugins` list overwrites the defaults, so keep it complete.
- Add `"knip": "knip"` to package.json scripts. Copy `templates/knip.json`.

Agent context:

- Copy `templates/.ai/rules/*` and `templates/.ai/guidelines/*`. Then run `php artisan boost:update`, which regenerates AGENTS.md. In retrofit mode, an older CLAUDE.md that holds Boost guidelines is stale. Keep any text in it that is not Boost text, then replace the rest with `@AGENTS.md`. Never edit them by hand. Run `pnpm exec vp fmt` again, because `vp check` also formats Markdown.

CI:

- Apply `templates/ci.md` to `.github/workflows/tests.yml`. Confirm that `.github/dependabot.yml` matches `templates/.github/dependabot.yml` (the current starter ships the same file).

Check: `vendor/bin/phpstan analyse`, `pnpm exec vp check`, `pnpm knip` and `vendor/bin/pest` all run without a config error. They are expected to report starter residue at this point.

### Phase 2. Mechanical residue (delegated)

These were measured on the Laravel 13 React starter (installer 5.32). Recount on the current starter; the counts are a guide.

- PHPStan level 8: about 47 errors. Add `: void` to the class-based starter test methods. Delete `tests/Unit/ExampleTest.php` (its `assertTrue(true)` fails PHPStan) and keep the directory with a `.gitkeep`. Fix `User|null` with `#[CurrentUser] User $user` injection in the controllers and `$this->user()?->id` in `ProfileUpdateRequest`. Fix `Carbon|null` on `created_at` with `?->`.
- Type coverage: the untyped closure parameter in `Settings/SecurityController.php` (type it as `Passkey $passkey`).
- `<Link prefetch>`: 4 (nav-main, app-header, app-sidebar, user-menu-content). app-header.tsx is also on the knip delete list, so 3 remain after the deletion. Remove the prop.
- `target="_blank"` without `rel="noopener noreferrer"`: 3 in welcome.tsx.
- `jsx-a11y/no-autofocus`: remove `autoFocus` from the auth forms. The rule stays on.
- `jsx-a11y/tabindex-no-positive`: 12. Remove the positive `tabIndex` values and fix the DOM order if needed.
- `jsx-a11y/prefer-tag-over-role`: 2 in two-factor-recovery-codes.tsx. Use the native element.
- knip: delete the unused layout files it lists (about 4), remove `concurrently`, add `@inertiajs/core` as a dependency, and delete the unused exported types.

Check: type coverage, knip and the non-shadcn oxlint rules are green. PHPStan is green apart from the disallowed-calls lines that Phase 3 fixes.

### Phase 3. Model write sites (delegated)

Move each direct write outside `app/Models` into a named model method, and call that method. On the stock starter the sites are `ResetUserPassword.php` (`forceFill()->save()`), `Settings/ProfileController.php` (`fill`, `save`, `delete`) and `Settings/SecurityController.php` (`update`). `CreateNewUser` keeps `User::create`, because `create` is allowed.

Check: PHPStan with disallowed-calls is green, and the starter's feature tests pass.

### Phase 4. Radix to Base UI (delegated, opt-in)

Run this phase only when the user said yes in Step 0 and `migrate-radix-to-base` is installed. When you skip it, Phase 5 runs on the Radix consumers (the lint config ignores `components/ui`). That path is unverified; see Known gaps.

Before this phase, take the "before" screenshot set (Phase 5, step 1). The pairs must cover Phases 4 and 5, because `base-vega` is a restyle.

Run the `migrate-radix-to-base` skill for the whole project. The target shadcn style is `base-vega`. This phase comes before Phase 5, because the migration rewrites the `components/ui` primitives.

laravel-init wins where the two skills conflict:
- The move from `new-york` to `base-vega` is an intended restyle (the default of this skill), not "classification only". Use a different Base UI style only when the user names one.
- Leave the tree uncommitted. No branch and no per-component commits. One `.migration/project.md` report is enough; delete `.migration/` at hand-back unless the user wants to keep it.

shadcn CLI traps (seen on the starter with `shadcn add <wrappers> --overwrite`):
- The CLI writes `import { cn } from "cn"` into the ui files and adds the unrelated npm package `cn`, so tsc does not catch it. After every `shadcn add`, run `grep -rl 'from "cn"' resources/js | xargs sed -i '' 's#from "cn"#from "@/lib/utils"#'` and `pnpm remove cn`.
- It adds `hooks/use-mobile.ts` next to the starter's `use-mobile.tsx`. Delete the new `.ts` file.
- `--yes` does not answer the overwrite prompts. Pipe `yes n |` when a registry dependency already exists.
- An overwrite drops the starter's customizations. Replay the sidebar trigger's open and close icons.

Consumer changes on the starter:
- `asChild` becomes `render`. A Button that renders an Inertia `Link` needs `nativeButton={false}`.
- Base UI throws when `DropdownMenuLabel` sits outside a group (user-menu-content.tsx). The trial replaced the label with a plain `div`. Wrapping it in `DropdownMenuGroup` should also work, but that form is unverified.
- `data-[state=open]:` becomes `data-popup-open:`, and `--radix-dropdown-menu-trigger-width` becomes `--anchor-width` (nav-user.tsx).
- `TooltipProvider delayDuration` becomes `delay` (app.tsx).
- An `<a>` moved into `render` with no text needs `aria-label` (nav-footer.tsx), or `jsx-a11y/control-has-associated-label` fails.
- Remove every `@radix-ui/*` package.

Check: `pnpm types:check`, `pnpm build`, `grep -r radix resources/` prints nothing, and a browser pass over every starter page with no console errors. Open the user menu, the delete-account dialog, the collapsed sidebar and its tooltip, and the mobile sheet.

### Phase 5. shadcn residue (delegated)

1. Before Phase 4, take a screenshot of every starter page in light and dark mode: welcome, login, register, forgot password, verify email, confirm password, dashboard, the three settings pages, and the two-factor screens. Use Pest (`visit()->screenshot()` in a temporary test) for the same viewport and state in every pair. Save the screenshots outside the repo, in the run plan's folder. `assertPathIs()` passes before Inertia mounts the page. Before `screenshot()`, assert a text that only the rendered page shows, or wait (`->wait(2)`). Run `assertNoJavaScriptErrors()` after the page renders, not before.
2. Fix every `shadcn/*` error. On the starter there were about 170 after Phase 4 (no-arbitrary-values, no-raw-colors, no-restyle, no-inline-styles), most in welcome.tsx. Use theme tokens or a component variant for UI chrome. For brand or status colors with no near token (the welcome art, success green), declare `--color-<name>` in app.css with light and dark values, as the lint message allows. Do not add a lint disable. Traps:
   - `fill="black"` or `fill="white"` in an SVG mask is flagged. `var(--color-black)` passes.
   - `pr-10` on `<Input>` is a restyle. Rebuild PasswordInput on `shadcn add input-group` (and apply the `cn` fix again).
   - `block` or other layout classes on `InputGroup` break its flex layout. Drop `className` passthrough on PasswordInput.
3. Take the same screenshots after the change, in both themes, and compare them pair by pair. Report each visible change, and show the changed pairs to the user at hand-back.

Check: `pnpm exec vp check` is green with all rules.

### Phase 6. Seed tests

- Copy `templates/tests/Browser/SmokeTest.php` and delete `tests/Browser/.gitkeep`. The starter turns on email verification, so registration lands on `/email/verify`; the second test logs in as a factory user. If the UI labels changed, match them. Run `pnpm build`, then `vendor/bin/pest tests/Browser`.
- Copy `templates/tests/Scenarios/StarterSmoke.php`. Run `php artisan nitpick:scenarios` and confirm that it lists StarterSmoke with no error.

### Phase 7. Gate and negative controls

Run `composer gate`. It must be green. Then prove each gate family with one violation. Each violation must produce the named rule ID in the output. Revert each one before the next. Run `${CLAUDE_SKILL_DIR}/scripts/negative-controls.sh` from the repo root: it writes each probe below, prints PASS with the matched line or FAIL, and removes every probe. Set `SKIP="shadcn"` (space-separated family names) only for a family that is off by a decision, and report it as not proven. The script exits 0 only when every family that is not skipped engaged.

| Family | Violation | Expected output |
| --- | --- | --- |
| Write ban | `$user->update([...])` in a controller | `Calling Illuminate\Database\Eloquent\Model::update()` |
| Override ban | a model that overrides `save()`, called from a controller | `matches App\Models\*::save()` |
| Arch | a `final readonly` class in `app/Actions` with no `handle()` | `actions are final readonly classes with handle()` and `to have method [handle]` |
| Dead code | an unused public method on a model | `shipmonk.deadMethod` |
| Type coverage | an untyped parameter in app/ | `Type coverage below expected` |
| oxlint | `<img>` with no `alt` | `jsx-a11y(alt-text)` |
| shadcn | `className="bg-red-500"` on a plain `div` | `shadcn(no-raw-colors)` |
| knip | an exported function that nothing imports | the function name under `Unused exports` |
| Browser | change the smoke test's expected path | the failing assertion and a screenshot |

Then run `composer gate` again. It must be green, and `git status` must show no probe file.

Then run `composer ci:check`. The gate runs `pint --dirty`, which skips files that this work did not change. In a retrofit, older files can fail Pint in CI. Run `vendor/bin/pint` once on the full tree and list the changed files as pending veto.

`composer gate` is the local run, so it fixes formatting (`pint --dirty`, `vp check --fix`) instead of failing on it. `composer ci:check` is the check-only run that CI uses, and it fails on formatting.

## Retrofit mode

1. **Audit, read-only.** Make a scratch git worktree (`git worktree add --detach <scratchpad>/audit HEAD`). Copy `.env`, create the sqlite file when the driver is sqlite, and run `php artisan wayfinder:generate --with-form` (the generated files are gitignored; without them knip and tsc report false errors). Upgrade Pest to 5 in the worktree, because the agent and phpstan plugins need it. Apply the templates and the Phase 1 config there, with `vp migrate --full`. Do not change app code in the main tree. Count the violations per rule and per family:
   - The Pest `laravel` preset stops at the first failed expectation. Count each expectation with its own temporary arch test (controller methods, console command suffix, requests `rules()`, actions with one public method), not with grep.
   - Run the full suite with `Model::shouldBeStrict` on and with the actions made `final`. Count the new failures and the tests that `mock()` an action. Fix those tests with a fake at the boundary (HTTP client, `Storage::fake`, `Queue::fake`), not by removing `final`.

   Show one table. Remove the worktree at hand-back.
2. **Ask per rule.** For each rule with violations, ask the user: fix now, or baseline. A baseline is `phpstan-baseline.neon` for PHPStan rules, and a dated list in the run plan for arch, oxlint and knip rules (those tools have no baseline file). Do not use `->ignoring()` for a baseline.
3. **Keep the repo's PHPStan level** and offer to raise it to 8.
4. **Diff the templates** against the repo's copies of `phpstan.neon`, `disallowed-calls.neon`, `tests/Arch/ArchitectureTest.php`, `.ai/rules/*`, `.ai/guidelines/*`, `knip.json` and the vite.config.ts lint block. Show each difference and ask whether to take the template version.
5. Add the seed browser test only when `tests/Browser` is empty, and the nitpick scenario only when `tests/Scenarios` is empty.
6. Bump `"php"` to `^8.4` and `markhamsq/nitpick` to the latest release when they are lower.
7. Run the fix phases that apply (2 to 5) for the rules the user chose to fix, then Phase 7. Phase 4 runs only when the user asks for it.

## Known gaps

- No oxlint rule detects an `<input>` with no label (all 35 jsx-a11y rules were tried on oxlint 1.85). The verification guideline carries this rule as text.
- disallowed-calls cannot see a write inside a higher-order collection proxy (`$users->each->update()`). Unverified.
- Fresh mode without Phase 4 (Radix kept) has not run end to end. Phase 5 and the shadcn negative control on Radix consumers are unverified.
- Retrofit mode had its first end-to-end run on a production app (2026-10-05). It reached a green `composer gate` and `composer ci:check`, and 8 of 9 negative controls engaged. The shadcn control was not proven, because the Base UI migration was deferred and the `shadcn/*` rules were off. The GitHub workflow did not run.
- The CI workflow did not run in the trial. Dark mode was not captured in the trial, and these surfaces were not driven after the Base UI migration: the 2FA setup modal, the recovery-codes toggle, passkey register and remove, the mobile sheet, and the collapsed-rail tooltip.
- On the stock starter, Pest's agent JSON reports `"warnings":1` with empty `warning_details`. The cause is unknown; it does not fail the gate.
- Spike evidence for every config in this skill is in `spikes/` (VBB 1 to 6, 2026-10-04). An end-to-end trial of fresh mode on 2026-10-04 reached a green `composer gate` with all nine negative controls; its defects are folded into this file.

## Hand-back

Lead with the run command:

```bash
composer gate
```

Then report:

- Mode, and every phase with its check result.
- The negative-control table with the verbatim output line for each family.
- The Phase 5 screenshot pairs that changed.
- Each deviation from this skill, marked "pending veto".
- Each surface that you did not verify.
- The uncommitted tree (`git status --short`).
