<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MlStatusTest extends TestCase
{
    use RefreshDatabase;

    public function test_ml_status_is_not_public(): void
    {
        $this->getJson('/api/ml/status')->assertUnauthorized();
    }

    public function test_ml_status_refuses_missing_internal_token(): void
    {
        $user = User::create([
            'name' => 'Private Operator', 'email' => 'operator-ml@example.test',
            'password' => bcrypt('test-password-for-ci'),
        ]);
        Sanctum::actingAs($user);
        config()->set('services.ml.internal_token', '');
        $this->getJson('/api/ml/status')->assertStatus(503)
            ->assertJsonPath('status', 'unavailable');
    }

    public function test_ml_status_translates_only_whitelisted_private_status(): void
    {
        $user = User::create([
            'name' => 'Private Operator', 'email' => 'operator-ml2@example.test',
            'password' => bcrypt('test-password-for-ci'),
        ]);
        Sanctum::actingAs($user);
        config()->set('services.ml.internal_token', 'test-internal-token');
        config()->set('services.ml.url', 'http://ml-service:5000');
        Http::fake([
            'http://ml-service:5000/*' => Http::response([
                'success' => true, 'model_available' => false,
                'database_url' => 'do-not-expose',
            ], 200),
        ]);

        $reply = $this->getJson('/api/ml/status')->assertOk()
            ->assertJsonPath('status', 'connected')
            ->assertJsonPath('model_available', false);
        $this->assertArrayNotHasKey('database_url', $reply->json());
        Http::assertSent(function ($request) {
            return $request->url() === 'http://ml-service:5000/api/v1/status'
                && $request->hasHeader('Authorization', 'Bearer test-internal-token');
        });
    }
}
