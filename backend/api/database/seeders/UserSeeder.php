<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Never seed known credentials; explicit local/test-only opt in.
        if (!app()->environment(['local', 'testing'])) {
            return;
        }
        $password = env('DEV_SEED_PASSWORD', '');
        if (strlen($password) < 12 || in_array($password, ['admin123', 'test123'], true)) {
            return;
        }
        User::updateOrCreate(['email' => 'admin@sentinelai.com'], [
            'name' => 'Development Admin',
            'password' => $password,
            'email_verified_at' => now(),
        ]);
    }
}
