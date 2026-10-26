<?php

namespace Tests\Scenarios;

use App\Models\User;
use MarkhamSq\Nitpick\Checklist;
use MarkhamSq\Nitpick\Scenario;
use MarkhamSq\Nitpick\Section;

// Covers the four starter write sites that laravel-init moves into model methods.
class StarterSmoke extends Scenario
{
    public function setUp(): void
    {
        User::factory()->create(['name' => 'Smoke Admin', 'email' => 'smoke@example.test']);
    }

    public function personas(): array
    {
        return [
            'admin' => ['label' => 'Smoke Admin', 'email' => 'smoke@example.test', 'home' => '/dashboard'],
        ];
    }

    public function checklist(Checklist $checklist): Checklist
    {
        return $checklist
            ->as('admin', fn (Section $section) => $section
                ->check('The dashboard loads with no console errors', url: '/dashboard')
                ->check('Change the name and save: the new name shows in the sidebar', url: '/settings/profile')
                ->check('Change the password: a success message shows, and the new password logs in', url: '/settings/security')
                ->check('Delete the account: you land on the home page logged out, and the login fails', url: '/settings/profile'));
    }
}
