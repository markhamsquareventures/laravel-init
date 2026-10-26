---
paths:
    - 'app/Actions/**'
---

# Actions

## When an action exists

An action exists because two or more callers share a use case. It is a `final readonly` class with one public `handle()` method. Constructor injection supplies its dependencies.

## What an action does

It loads models, owns the transaction when it has one, calls model methods to change state, and dispatches jobs and notifications after the writes. It does not change state itself; writes go through model methods.

## What an action does not do

It does not read the HTTP request, validate HTTP input, or authorize. The controller does those before it calls `handle()`.

`app/Actions/Fortify` holds Fortify contract classes. They follow the Fortify contracts, not these rules.

Enforced by: `disallowed-calls.neon` (PHPStan) and `tests/Arch/ArchitectureTest.php`.
