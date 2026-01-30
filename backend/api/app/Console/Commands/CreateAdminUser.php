<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;

class CreateAdminUser extends Command
{
    protected $signature = 'sentinelai:create-admin
                            {--email=admin@sentinelai.com : Admin email}
                            {--password=admin123 : Admin password}';

    protected $description = 'Create or update the default admin user (admin@sentinelai.com / admin123).';

    public function handle(): int
    {
        $email = $this->option('email');
        $password = $this->option('password');

        $user = User::updateOrCreate(
            ['email' => $email],
            [
                'name' => 'Admin',
                'password' => $password,
            ]
        );

        $this->info("Admin user ready: {$user->email} (ID: {$user->id})");
        $this->line('Use these credentials to log in.');

        return self::SUCCESS;
    }
}
