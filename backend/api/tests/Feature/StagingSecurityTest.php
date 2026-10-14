<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StagingSecurityTest extends TestCase
{
    use RefreshDatabase;

    private function sampleUser(): array
    {
        return [
            'name' => 'Staging Smoke',
            'email' => 'staging@example.test',
            'password' => 'unique-test-password-48',
            'password_confirmation' => 'unique-test-password-48',
        ];
    }

    public function test_new_accounts_are_disabled_by_default(): void
    {
        config()->set('app.public_registration', false);
        $this->postJson('/api/register', $this->sampleUser())
            ->assertForbidden()
            ->assertJsonPath('message', 'Registration is disabled');
        $this->assertDatabaseCount('users', 0);
    }

    public function test_registration_can_be_explicitly_enabled_for_disposable_tests(): void
    {
        config()->set('app.public_registration', true);
        $this->postJson('/api/register', $this->sampleUser())
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['token']);
        $this->assertDatabaseCount('users', 1);
    }

    public function test_cross_origin_requests_are_not_permitted_by_default(): void
    {
        $this->assertSame([], config('cors.allowed_origins'));
        $this->getJson('/api/health', ['Origin' => 'https://untrusted.example.test'])
            ->assertOk()
            ->assertHeaderMissing('Access-Control-Allow-Origin');
    }

    public function test_threats_require_authentication(): void
    {
        $this->getJson('/api/threats')->assertUnauthorized();
        $this->postJson('/api/threats', ['type' => 'example'])->assertUnauthorized();
    }
}
