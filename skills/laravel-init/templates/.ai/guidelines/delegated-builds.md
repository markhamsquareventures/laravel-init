# Delegated builds

A subagent that builds one todo in this tree leaves everything uncommitted. Never `git commit`, `git stash`, `git checkout` or `git restore` on tracked files. Never delete or truncate `storage/logs/laravel.log`. Never add a dependency without approval. When `php artisan migrate:fresh --seed` is allowed, it is the last database action, so the dev database ends seeded.

Code that breaks a rule in `.ai/rules` or a loaded skill is residue, not precedent. The rule wins, and the report names the violation. A defect inside the todo's scope is the subagent's to fix. A permission denial is a stop: report the blocked change and hand it back. Never use another binary to make the same write.

`git diff` shows nothing for an untracked (`??`) file. Before you report an item as already resolved, read or grep the file's current content. An empty diff is not evidence.

Wayfinder regenerates with `php artisan wayfinder:generate --with-form` or `pnpm build`. Without `--with-form`, every `.form()` disappears. Run `pnpm build` before a Pest test that renders a new page.

This project uses pnpm. Never run npm here: a stale npm tree hides the versions that pnpm installs.
