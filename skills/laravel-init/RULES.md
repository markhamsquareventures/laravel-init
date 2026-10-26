# Rules and reasons

laravel-init installs these rules as checks that fail the build. This file gives the reason for each rule. The `.ai/rules` files in the project tell agents what to do. The checks find the departures.

## PHP

| Rule | Check | Reason |
| --- | --- | --- |
| A change to an existing record is a named method on its model (`$invoice->markPaid()`). Outside `app/Models`, code never calls `update`, `save`, `delete`, `fill`, `increment`, `touch` or a bulk query write. `create` is allowed everywhere. | PHPStan `disallowed-calls.neon` | Each state change and its invariant are in one known place. An agent cannot go around the invariant with a stray `->update()` in a controller. |
| A model does not override `save`, `update` or another write method. | PHPStan `disallowed-calls.neon` | An override hides a write behind a generic name. A named method shows what the change means. |
| A model does not call actions, jobs, notifications or events. | Pest arch test | The model changes state. The caller decides what happens after the change. This keeps side effects out of the write boundary. |
| Controller methods are RESTful verbs or `__invoke`. For another verb, make a new controller. | Pest arch `laravel` preset | Small controllers with known method names are easy to find and easy to read. |
| No traits in controllers. | Pest arch test | A trait hides behavior. An action or a base controller shows it. |
| Logic stays inline in the controller until a second caller needs it. Then it moves to an action in `app/Actions`. | Text rule only | An early extraction adds indirection with no reuse. |
| An action is a `final readonly` class with one `handle()` method. It does not read the request, validate HTTP input or authorize. | Pest arch test | One shape for every action. HTTP concerns stay in the controller, so an action can run from a job or a command. |
| No classes with the `Service` suffix. | Pest arch test | Service classes grow without a limit. Actions have one job each. |
| A third-party API goes in a `Gateway` class in `app/Gateways`. | Pest arch test | One place to change, fake and test each integration. |
| No dead code. | shipmonk dead-code detector, oxlint `no-unused-vars`, knip | Dead code costs reading time and gives agents false examples to copy. |
| 100% type coverage, PHPStan level 8. | Pest type coverage, Larastan | Types catch errors before runtime, and they tell agents what each value is. |
| Strict models outside production (`Model::shouldBeStrict`). | Runtime | Lazy loading, missing attributes and silent discards fail loudly in development. |

## React and Inertia

| Rule | Check | Reason |
| --- | --- | --- |
| No link prefetching. | oxlint `react/forbid-component-props` | Prefetching is usually more trouble than it is worth. |
| Use Inertia `usePoll`, not `setInterval`. | oxlint `no-restricted-globals` | Use the built-in feature before a hand-written workaround. |
| External links with `target="_blank"` also have `rel="noopener noreferrer"`. | oxlint `react/jsx-no-target-blank` | Security. The new page cannot control the old page. |
| Images have `alt`. Decorative images have `alt=""`. | oxlint `jsx-a11y/alt-text` | Accessibility. |
| Interactive elements are `<button>` or `<a>`, not a `<div>` with `onClick`. | oxlint `jsx-a11y` rules | Accessibility. Native elements give keyboard and screen-reader support. |
| Each form control has a label. | oxlint `jsx-a11y/label-has-associated-control`, and a text rule | Accessibility. No oxlint rule finds an `<input>` with no label, so the verification guideline tells agents to check by hand. |
| No `autoFocus`, no positive `tabIndex`. | oxlint `jsx-a11y` rules | Accessibility. Both change the focus order that keyboard users expect. |
| UI chrome uses theme tokens and component variants, not raw colors, arbitrary values or inline styles. | `@shadcn/lint` | The design stays consistent, and dark mode works. |

## Process

| Rule | Check | Reason |
| --- | --- | --- |
| One command runs every check (`composer gate`). | Composer script | An agent or a person cannot skip a check by accident. |
| Each check family is proved with a negative control. | `scripts/negative-controls.sh` | An exit code of 0 can come from a check that did not run. A violation that the check names proves the check works. |
| pnpm only. | Text rule | A stale npm tree hides the versions that pnpm installs. |
| A browser smoke test runs in the gate. | Pest browser plugin | A green unit suite does not prove that the pages render. |
