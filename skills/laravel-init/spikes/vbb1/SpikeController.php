<?php

namespace App\Http\Controllers;

use App\Models\District;
use App\Models\Overrider;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class SpikeController extends Controller
{
    public function flagged(User $user, District $district, Overrider $overrider): void
    {
        $user->update(['name' => 'x']); // 1 flag
        User::where('id', 1)->update(['name' => 'x']); // 2 flag
        DB::table('users')->update(['name' => 'x']); // 3 flag
        $district->meetings()->update(['title' => 'x']); // 4 flag
        User::destroy(1); // 5 flag
        $user->fill(['name' => 'x'])->save(); // 8 flag
        $overrider->update(['name' => 'x']); // 9 override
        $district->meetings()->delete(); // 10 flag
        $district->meetings()->increment('x'); // 11 flag
    }

    public function allowed(District $district): void
    {
        $district->meetings()->create(['title' => 'x']); // 6 ok
        User::create(['name' => 'x', 'email' => 'a@b.c', 'password' => 'x']); // 7 ok
    }
}
