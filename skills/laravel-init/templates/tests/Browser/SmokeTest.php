<?php

use App\Models\User;

it('registers and lands on the email verification notice', function (): void {
    visit('/register')
        ->fill('name', 'Smoke User')
        ->fill('email', 'smoke@example.test')
        ->fill('password', 'password')
        ->fill('password_confirmation', 'password')
        ->press('Create account')
        ->assertPathIs('/email/verify')
        ->assertNoJavaScriptErrors();
});

it('logs in, reaches the dashboard, and logs out', function (): void {
    User::factory()->create(['name' => 'Smoke User', 'email' => 'smoke@example.test']);

    visit('/login')
        ->fill('email', 'smoke@example.test')
        ->fill('password', 'password')
        ->press('Log in')
        ->assertPathIs('/dashboard')
        ->assertNoJavaScriptErrors()
        ->click('Smoke User')
        ->click('Log out')
        ->assertPathIs('/');
});
