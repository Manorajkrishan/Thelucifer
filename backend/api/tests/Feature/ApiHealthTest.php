<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiHealthTest extends TestCase
{
    use RefreshDatabase;

    public function test_api_health_returns_ok(): void
    {
        $response = $this->getJson('/api/health');

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'status' => 'online'])
            ->assertJsonStructure(['timestamp', 'database']);
    }

    public function test_api_root_returns_info(): void
    {
        $response = $this->getJson('/api/');

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'status' => 'online', 'message' => 'SentinelAI X API'])
            ->assertJsonStructure(['endpoints']);
    }
}
