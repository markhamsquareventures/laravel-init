# Changelog

## 1.2.0 — 2026-10-22
- Generic for any user. The skill names "the user", the run plan is always `docs/features/laravel-init/plan.md`, and it needs no other skill for delegation or rule reasons.
- Phase 4 (Radix to Base UI) is opt-in, asked in Step 0. When `migrate-radix-to-base` is missing, the skill gives the install command and skips the phase. A known gap records that fresh mode without Phase 4 has not run end to end.
- New `RULES.md` gives the reason for each rule. Template comments and the prefetch lint message no longer name the private marketplace.
- Why: the skill is published as a public repo (markhamsquareventures/laravel-init) for anyone to install.

## 1.1.0 — 2026-10-05
- Retrofit audit runs in a scratch git worktree with Pest 5, Wayfinder generated and `vp migrate --full`. It counts each arch-preset expectation on its own, and it runs the suite with strict models and `final` actions.
- `vp migrate --full` in Phase 1, with notes on porting `.prettierignore`, the oxfmt ignore list, and the pnpm 11 `allowBuilds` step.
- Boost: CLAUDE.md holds `@AGENTS.md`, because Boost 2.10 writes the Claude Code guidelines to AGENTS.md.
- Pest bootstrap: a separate Browser block, so browser tests do not get `withoutVite()`.
- Phase 7 runs `composer ci:check` after the gate, and the new `scripts/negative-controls.sh` runs the nine controls. New `scripts/plain` replaces the long `env -u ...` prefix.
- `templates/phpstan.neon` sets `parseModelCastsMethod: true`.
- Screenshot note: assert rendered content or wait before `screenshot()`.
- Why: the first retrofit run (a production app) found each of these. The audit said 202 reformatted files when the real number was 4, it missed four groups of arch work, and a zsh variable bug made three hand-written controls print nothing. Both scripts were run on that app: 8 of 9 families passed, and shadcn failed as expected because its rules are off.

## 1.0.1 — 2026-10-05
- `templates/disallowed-calls.neon` bans `Illuminate\Database\Eloquent\Relations\HasOneOrMany::updateOrCreate()` outside app/Models, database and tests.
- Why: the first retrofit run (a production app) found `$lineItem->values()->updateOrCreate(...)` in a controller and an action. The ban did not see it, because the method is declared on the relation, not on the Builder. A negative control on that app confirmed that the new entry fires.

## 1.0.0 — 2026-10-04
- Initial: fresh and retrofit modes for a Laravel 13 + Inertia + React repo. Installs Pest browser and arch tests, Larastan level 8 with disallowed-calls and shipmonk dead-code, 100% type coverage, vite-plus 1.0 with oxlint a11y and React rules, @shadcn/lint, knip, nitpick, Boost rules, and `composer gate`. Fresh mode fixes starter residue, moves starter writes into model methods, and migrates Radix to Base UI (`base-vega`).
- Verified by an end-to-end fresh-mode trial on a new starter: `composer gate` green (PHPStan 0 errors, Pest 50/50, type coverage 100%, lint clean) and all nine negative controls engaged. The trial's 17 defects (arch `->ignoring()` scope, email-verification smoke path, Boost non-interactive install, shadcn CLI `cn` import, and others) are fixed in the skill.
- Why: agents worked around conventions that they only had to remember. Spike evidence is in `spikes/`.
