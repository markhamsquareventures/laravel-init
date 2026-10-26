# laravel-init

A Claude Code skill that sets up a Laravel 13 + Inertia + React project so that its coding rules are checks that fail the build. An agent that breaks a rule gets a PHPStan error, a failed arch test or a lint error, not a reminder it can ignore.

This setup is opinionated. Read [RULES.md](skills/laravel-init/RULES.md) before you run it. The file lists each rule, the check that enforces it, and the reason for it.

## What it installs

- Larastan at level 8, with `spaze/phpstan-disallowed-calls` (writes to existing records only in `app/Models`) and `shipmonk/dead-code-detector`
- Pest arch tests, Pest browser tests, and 100% type coverage
- vite-plus with oxlint (jsx-a11y and React rules), `@shadcn/lint` and knip
- Laravel Boost with `.ai/rules` and `.ai/guidelines` files for agents
- [nitpick](https://packagist.org/packages/markhamsq/nitpick) manual-QA scenarios
- One `composer gate` command that runs every check, and `composer ci:check` for CI

The skill proves each check family with a negative control. It writes one violation, confirms that the output names the expected rule, then removes the violation.

## Modes

- `fresh` is for a new starter from `laravel new <name> --react --pest --pnpm`. The skill installs everything, fixes the starter code that breaks a rule, and makes `composer gate` green.
- `retrofit` is for an existing app. The skill audits in a scratch git worktree, shows the violations per rule, and asks you per rule whether to fix it now or baseline it.

The skill detects the mode. You can also pass `fresh` or `retrofit`.

## Requirements

- Claude Code
- PHP 8.4 or later, Composer, and pnpm (the skill never runs npm)
- A Laravel 13 React starter or app with Pest
- The `migrate-radix-to-base` skill from shadcn, if you want the Radix UI to Base UI migration in fresh mode. It is optional, and the skill asks before it migrates.

```bash
npx skills add shadcn/ui --skill migrate-radix-to-base
```

## Install

With the skills CLI:

```bash
npx skills add markhamsquareventures/laravel-init
```

Or as a Claude Code plugin:

```
/plugin marketplace add markhamsquareventures/laravel-init
/plugin install laravel-init@laravel-init
```

Or copy `skills/laravel-init` into `~/.claude/skills/`.

## Use

In the project root, start Claude Code and run:

```
/laravel-init
```

The skill writes its run plan to `docs/features/laravel-init/plan.md` and leaves all changes uncommitted, so you can review the diff before you commit.

## Defaults you may want to change

- The Base UI migration targets the shadcn `base-vega` style. That is a restyle of the starter.
- Boost installs with Laravel Cloud on (`"cloud": true`). Tell the skill if you deploy elsewhere.
- pnpm only.

## Evidence

`skills/laravel-init/spikes/` holds the spike output for each config (2026-10-04). An end-to-end fresh-mode run reached a green `composer gate` with all nine negative controls. A retrofit run on a production app reached a green gate with eight of nine controls. The known gaps are at the end of [SKILL.md](skills/laravel-init/SKILL.md).

## License

MIT
