<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;

class CreateAdminUser extends Command
{
    protected $signature = 'sentinelai:create-admin
                            {--email=admin@sentinelai.com : Administrator email}
                            {--password= : Optional password; interactive prompt is recommended}';

    protected $description = 'Create or update an administrator with a strong unique password.';

    public function handle(): int
    {
        $email = $this->option('email');
        $password = $this->option('password') ?: env('INITIAL_ADMIN_PASSWORD');
        if (!$password && $this->input->isInteractive()) {
            $password = $this->secret('New administrator password');
        }
        if (!is_string($password) || strlen($password) < 12 || in_array($password, ['admin123', 'test123'], true)) {
            $this->error('A unique password with at least 12 characters is required.');
            return self::FAILURE;
        }
        $user = User::updateOrCreate(['email' => $email], [
            'name' => 'Administrator',
            'password' => $password,
        ]);
        $this->info("Administrator configured: {$user->email}");
        return self::SUCCESS;
    }
}
