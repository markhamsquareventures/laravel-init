# VBB 2: @shadcn/lint under vite-plus 0.3.0 (oxlint 1.79.0)

Result: PASS. The rules engage in both 0.1.0 and 0.2.0 despite the README claim of "oxlint 1.80 or later".

Installed: vite-plus 0.3.0, oxlint 1.79.0 (node_modules/oxlint/package.json).
Config: see lint-config.ts (jsPlugins: ['@shadcn/lint'] plus the six shadcn rules as 'error').
Option shape for no-restyle (README): ["error", { allow: ["layout"], contracts: [...] }].

Evidence (flagged probe, same output for 0.1.0 and 0.2.0):
- shadcn(no-arbitrary-values) on bg-[#ff0000] and p-[13px]
- shadcn(no-unknown-classes) on rounded-huge
- shadcn(no-inline-styles) on style={{ color: 'red' }}
- shadcn(no-restyle) and shadcn(no-raw-colors) on <Button className="bg-red-500">
- shadcn(require-static-classes) on <Button className={`bg-${color}`}>
Clean probe (mt-4 plus variant="destructive"): no output, exit 0.

Notes:
- A raw hex color in an arbitrary value is reported by no-arbitrary-values, not no-raw-colors.
- The rules read resources/css/app.css and components.json (theme tokens, Button variants are in the messages). So they work with the stock shadcn starter.
- The stock starter fails these rules (denyWarnings is on). Counts are the same in 0.1.0 and 0.2.0:
  92 no-arbitrary-values, 54 no-raw-colors, 52 no-restyle, 1 no-inline-styles. Example files: nav-user.tsx, nav-footer.tsx, passkey-item.tsx, password-input.tsx, text-link.tsx, login.tsx, profile.tsx, app-sidebar-header.tsx. components/ui is ignored through ignorePatterns.
  A fresh-mode template must fix these starter files, or set the rules to 'warn' with denyWarnings off, or scope them.
- vite-plus 1.0.0 is on npm (latest) and pins oxlint =1.85.0. It was NOT needed and NOT tried.
- ESLint 9 fallback was not needed. If needed: eslint >= 9.30, @typescript-eslint/parser, and a flat config with plugins: { shadcn } (import { plugin as shadcn } from '@shadcn/lint').
