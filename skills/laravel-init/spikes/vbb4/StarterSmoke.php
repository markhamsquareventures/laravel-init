<?php

namespace Tests\Scenarios;

use App\Models\User;
use MarkhamSq\Nitpick\Checklist;
use MarkhamSq\Nitpick\Scenario;
use MarkhamSq\Nitpick\Section;

class StarterSmoke extends Scenario
{
    public function setUp(): void
    {
        User::factory()->create(['name' => 'Admin', 'email' => 'admin@example.test']);
    }

    public function personas(): array
    {
        return [
            'admin' => ['label' => 'Admin', 'email' => 'admin@example.test', 'home' => '/dashboard'],
        ];
    }

    public function checklist(Checklist $checklist): Checklist
    {
        return $checklist
            ->as('admin', fn (Section $section) => $section
                ->check('The dashboard loads', url: '/dashboard'));
    }
}
