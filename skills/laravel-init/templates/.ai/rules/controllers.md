---
paths:
    - 'app/Http/Controllers/**'
---

# Controllers

## Load, authorize, validate, then call the model

A controller method loads the models, authorizes with a policy or gate, validates the input (inline or with a FormRequest), and calls a model method to change state. It can open a transaction around more than one model call. It never calls `update`, `save`, `delete` or a bulk write itself. `create` is allowed.

## Actions only on the second use

Keep single-use logic inline in the controller. Move it to an action in `app/Actions` when a second caller appears.

## Shape

Public methods are RESTful verbs or `__invoke`. For another verb, make a new controller. Do not use traits in controllers.

Enforced by: `disallowed-calls.neon` (PHPStan) and `tests/Arch/ArchitectureTest.php` (with the Pest `laravel` preset).
