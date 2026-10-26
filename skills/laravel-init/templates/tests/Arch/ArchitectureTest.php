<?php

// Source of truth: the laravel-init skill, templates/tests/Arch/ArchitectureTest.php
// The laravel preset already limits controllers to RESTful methods and __invoke.
// The write ban (and the ban on model overrides of write methods) is in disallowed-calls.neon.

arch()->preset()->php();

arch()->preset()->laravel();

arch()->preset()->security();

arch('controllers use no app traits')
    ->expect('App\Http\Controllers')
    ->not->toUse(['App\Concerns', 'App\Traits']);

arch('reuse goes in actions, not service classes')
    ->expect('App')
    ->not->toHaveSuffix('Service');

arch('gateways have the Gateway suffix')
    ->expect('App\Gateways')
    ->toHaveSuffix('Gateway');

arch('models do not reach out to actions, jobs, notifications, or events')
    ->expect('App\Models')
    ->not->toUse(['App\Actions', 'App\Jobs', 'App\Notifications', 'App\Events']);

// Fortify actions implement Fortify contracts (create, update, reset), not handle().
// A chained ->ignoring() covers only the last expectation, so each expectation carries its own.
arch('actions are final readonly classes with handle()', function () {
    expect('App\Actions')->toBeFinal()->ignoring('App\Actions\Fortify');
    expect('App\Actions')->toBeReadonly()->ignoring('App\Actions\Fortify');
    expect('App\Actions')->toHaveMethod('handle')->ignoring('App\Actions\Fortify');
});

arch('actions do not read the request or authorize')
    ->expect('App\Actions')
    ->not->toUse([
        'Illuminate\Http\Request',
        'Illuminate\Foundation\Http\FormRequest',
        'Illuminate\Support\Facades\Gate',
        'Illuminate\Foundation\Auth\Access\AuthorizesRequests',
    ])
    ->ignoring('App\Actions\Fortify');
