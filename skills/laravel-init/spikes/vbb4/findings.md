# VBB 4 findings

Setup: stock starter, git stash -u of the VBB 1 changes, then composer require --dev shipmonk/dead-code-detector (v1.4). Include: vendor/shipmonk/dead-code-detector/rules.neon.

## Dead-code reports on the stock starter
Count: 1 (shipmonk.deadMethod).

| Report | Class | Reason |
| --- | --- | --- |
| App\Actions\Fortify\ResetUserPassword::reset (line 19) | false positive | Fortify calls it as app(ResetsUserPasswords::class)->reset(...) in NewPasswordController. The container returns mixed, so the detector sees no call. The class is bound with Fortify::resetUserPasswordsUsing(ResetUserPassword::class) in FortifyServiceProvider. |

Not reported (good): CreateNewUser::create, controllers, routes, Inertia page props, form requests, middleware, providers, Scenario overrides (setUp, personas, checklist), class-based PHPUnit test methods.
No true dead code in the starter.

Fix that works: ignoreErrors entry with identifier shipmonk.deadMethod, path app/Actions/Fortify/ResetUserPassword.php, message '#::reset$#'. After it, the run shows 0 new lines.

## Negative control
Added `private function deadPrivate()` and `public function deadPublic()` to App\Models\User. Both reported with identifier shipmonk.deadMethod (lines 51 and 56). A public method is reported too, so the detector is not limited to private methods.

## Pest closure tests
No config needed. Calls made inside it()/test() closures count as usages (PestHelper::usedInClosure not reported). A static dataset method used in ->with(PestHelper::dataset()) is not reported. A helper method that no test calls is reported (PestHelper::neverUsed). pest ran 43/43 green with the controls.
The README lists PHPUnit support only (testXxx, data providers). The stock starter tests are class-based, so they work as is. Production code that only tests call counts as used, because tests/ is analysed.

## nitpick
- composer require --dev markhamsq/nitpick installed ^0.5.0.
- nitpick:install ran. It created storage/nitpick/nitpick.sqlite.
- make:nitpick-scenario StarterSmoke created tests/Scenarios/StarterSmoke.php (saved next to this file).
- phpstan level 8 on tests/Scenarios: "[OK] No errors". The full run with the stub also adds no dead-code report.
- pest-plugin-type-coverage ^5.0 installed. `pest --type-coverage --min=100` FAILS: "Type coverage below expected: 100.0%, currently 98.2%". The cause is app/Http/Controllers/Settings/SecurityController.php (pa30 75%), a starter file. The plugin measures only the phpunit.xml source (app/). It does not measure tests/Scenarios. So the stub passes PHPStan. Type coverage of the stub is UNVERIFIED (not measured by the gate).

## Tooling note
In this agent shell, AI_AGENT forces phpstan JSON output. Use `env -u AI_AGENT -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT vendor/bin/phpstan ...` for table or raw output.
