# Override wildcard probe (2026-10-04)

Pest `toHaveMethod()` uses `ReflectionClass::hasMethod()`, which includes inherited methods
(vendor/pestphp/pest/src/Expectation.php:575). `->not->toHaveMethod('update')` fails on every model,
so the decision-13 arch rule cannot be written that way.

Probe: a disallowed-calls entry `method: 'App\Models\*::update()'` with the same `allowIn` globs.

- Before the entry: `SpikeController.php:20` (`$overrider->update()`) had no report.
- After the entry: `SpikeController.php:20:Calling App\Models\Overrider::update() is forbidden, WILDCARD override probe. [App\Models\Overrider::update() matches App\Models\*::update()]`
- `$user->update()` (line 14) does not match the wildcard. Only the Model rule reports it.
- NEON: use single backslashes in single-quoted strings. `'App\\Models\\*'` does not match.
