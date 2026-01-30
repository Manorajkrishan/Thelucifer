<?php

namespace Tests\Feature;

use App\Models\Threat;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiThreatsTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::create([
            'name' => 'Admin',
            'email' => 'admin@sentinelai.com',
            'password' => bcrypt('admin123'),
        ]);
    }

    public function test_threats_statistics_requires_auth(): void
    {
        $response = $this->getJson('/api/threats/statistics');
        $response->assertStatus(401);
    }

    public function test_threats_statistics_returns_data_when_authenticated(): void
    {
        $token = $this->user->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/threats/statistics');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonStructure([
                'data' => [
                    'total',
                    'by_status',
                    'by_type',
                    'by_severity',
                    'recent_24h',
                    'by_date',
                ],
            ]);
    }

    public function test_threats_index_requires_auth(): void
    {
        $response = $this->getJson('/api/threats');
        $response->assertStatus(401);
    }

    public function test_threats_index_returns_list_when_authenticated(): void
    {
        Threat::create([
            'type' => 'malware',
            'severity' => 7,
            'description' => 'Test threat',
            'status' => 'detected',
            'detected_at' => now(),
            'user_id' => $this->user->id,
        ]);

        $token = $this->user->createToken('test')->plainTextToken;
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/threats');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonPath('data.data.0.type', 'malware');
    }

    public function test_create_threat_requires_auth(): void
    {
        $response = $this->postJson('/api/threats', [
            'type' => 'malware',
            'severity' => 7,
            'description' => 'Test',
        ]);
        $response->assertStatus(401);
    }

    public function test_create_threat_returns_201_when_authenticated(): void
    {
        $token = $this->user->createToken('test')->plainTextToken;
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/threats', [
                'type' => 'phishing',
                'severity' => 8,
                'description' => 'High-severity test threat',
            ]);

        $response->assertStatus(201)
            ->assertJson(['success' => true, 'message' => 'Threat detected and recorded successfully'])
            ->assertJsonPath('data.type', 'phishing')
            ->assertJsonPath('data.severity', 8);
    }
}
