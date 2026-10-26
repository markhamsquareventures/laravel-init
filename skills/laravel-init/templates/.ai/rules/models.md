---
paths:
    - 'app/Models/**'
---

# Models

## State changes live on the model

A change to an existing record is a named method on its model (`$meeting->cancel()`, `$invoice->markPaid()`). The method checks the invariant before it writes. Only model files call `update`, `save`, `delete`, `fill`, `increment`, `touch` or a bulk query write. `create` is allowed everywhere.

A model method is the write boundary, so it is exempt from the second-use rule. Do not override `update`, `save` or another write method. Add a named method.

## Invariant failures

Throw `ValidationException::withMessages([...])`. Inertia renders it as a redirect with the error bag, and JSON gets a 422. Write a custom exception class only when the failure needs different handling (another status, reporting, or a non-form response).

## No outward calls

A model does not call actions, jobs, notifications or events. The caller (a controller or an action) does that after the model method returns.

Enforced by: `disallowed-calls.neon` (PHPStan) and `tests/Arch/ArchitectureTest.php`.
