# Verification

After any change, run `composer gate`. It runs Pint, PHPStan, tsc, `vp check --fix`, knip, the Vite build, Pest (arch, unit, feature, browser) and type coverage. Do not use `pnpm check` alone: it stops on formatting before it runs the lint rules, so a lint result you did not see is not a lint pass.

A green gate does not cover runtime behavior. Finish with a browser pass over the pages you touched. For page-load or crash errors, use `mcp__laravel-boost__browser-logs`, not the Chrome console tool. Chrome sees only messages that come after its first call, and a crash that blanks the page can clear the buffer before you read it.

Read `browser-logs` and `storage/logs/laravel.log` only for entries after your pass began. `composer run dev` reloads on every save, so errors logged mid-edit come from a half-saved file, not from a defect.

The `.ai/rules` files and the checks do not cover every rule. No lint rule finds an `<input>` with no label. Check each new input for a label yourself.
