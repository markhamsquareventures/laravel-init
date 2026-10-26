# VBB 5: knip 6.39.0 with vite-plus 0.3.0

Result: PASS with config. Without config, knip is unusable (46 false "unused files").

Final config: knip.json in this folder.

## No config (output.txt RUN 1)
- Lists 46 unused files. This includes ALL of resources/js/pages/** (15 files). FALSE POSITIVE. Inertia v3 loads pages through @inertiajs/vite, not through an import.meta.glob that knip can follow. Knip does see app.tsx as an entry (through laravel-vite-plugin input).
- Also lists all unused components/ui files and 10 unused dependencies (radix + input-otp + @laravel/passkeys). Many are false positives that exist only because pages are not entries.
- Knip loads vite.config.ts without error. It enables the plugins "vite-plus", "Vite", "Vitest", "laravel-vite-plugin" and "Oxlint".

## Final config result (stock starter, output.txt RUN 4 minus the control line)
- Unused files (4): components/app-header.tsx, layouts/app/app-header-layout.tsx, layouts/auth/auth-card-layout.tsx, layouts/auth/auth-split-layout.tsx. TRUE positives. The starter ships alternate layouts that nothing imports. Fresh mode can delete them or list them as entries.
- Unused dependencies (1): concurrently. TRUE positive for JS. package.json has no script that calls it and composer.json does not name it. Remove it, or ignoreDependencies if a script is added later.
- Unlisted dependencies (1): @inertiajs/core in components/passkey-verify.tsx. TRUE positive (starter imports a transitive package). Fix: add it to dependencies or import from @inertiajs/react.
- Unused exported types (2): TwoFactorSetupData, TwoFactorSecretKey in types/auth.ts. TRUE positive but low value. Fix in fresh mode or set "types" off in the rules.
- No unused exports are reported in the starter, because the config sets ignoreExportsUsedInFile and components/ui/** is an entry.

## Config choices, with evidence
- entry resources/js/pages/**: required. Evidence: RUN 1 vs RUN 3.
- entry components/ui/**: makes shadcn components count as used, so unused-export noise from ui files (23 exports, 8 radix deps in RUN 1 and RUN 2) goes away. Using "ignore" for ui/** is worse. Ignored files that no entry reaches do not count their imports, so radix deps show as unused (RUN 2 listed 5 radix deps). Entry is the correct tool.
- Wayfinder dirs (resources/js/actions, routes, wayfinder): not needed. They are in .gitignore and knip skips gitignored files. Adding them to ignore gives hints "Remove from ignore" (RUN 2). If a repo commits them, add them to ignore.
- The hint ".css Compiled extension excluded by project" is harmless noise.

## Negative control
Appended `export function neverImportedSpikeFn()` to resources/js/lib/utils.ts (removed after the run). Knip printed:
  Unused exports (1)
  neverImportedSpikeFn  function  resources/js/lib/utils.ts:13:17
The control is not a first-try pass of nothing. The gate engaged by name.

## Not verified
- Knip exit code is 1 on any finding. The template must decide if knip is a hard gate.
- Knip with a fresh checkout before wayfinder generate (the gitignored dirs absent) was not tested.
- Knip has an Oxlint plugin that reads the lint block of vite.config.ts (enablers: oxlint, vite-plus), including jsPlugins. So @shadcn/lint is counted as used. Verified in node_modules/knip/dist/plugins/oxlint/index.js.
