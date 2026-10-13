<?php

namespace Tests\Feature;

use App\Models\Document;
use App\Models\Incident;
use App\Models\Threat;
use App\Models\ThreatAction;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ResourceIsolationTest extends TestCase
{
    use RefreshDatabase;

    public function test_other_users_documents_are_not_visible_or_downloadable(): void
    {
        $owner = User::create(['name' => 'Owner', 'email' => 'owner@example.test', 'password' => bcrypt('safe-password-test')]);
        $viewer = User::create(['name' => 'Viewer', 'email' => 'viewer@example.test', 'password' => bcrypt('safe-password-test')]);
        $document = Document::create([
            'title' => 'Internal report', 'filename' => 'report.txt',
            'file_path' => 'documents/report.txt', 'file_type' => 'txt',
            'file_size' => 4, 'uploaded_by' => $owner->id,
        ]);

        Sanctum::actingAs($viewer);
        $this->getJson('/api/documents')->assertOk()->assertJsonCount(0, 'data.data');
        $this->getJson("/api/documents/{$document->id}")->assertNotFound();
        $this->get("/api/documents/{$document->id}/download")->assertNotFound();
        $this->deleteJson("/api/documents/{$document->id}")->assertNotFound();
        $this->postJson("/api/documents/{$document->id}/process")->assertNotFound();
    }

    public function test_threat_and_its_incident_and_actions_are_isolated(): void
    {
        $owner = User::create(['name' => 'Owner', 'email' => 'owner2@example.test', 'password' => bcrypt('safe-password-test')]);
        $viewer = User::create(['name' => 'Viewer', 'email' => 'viewer2@example.test', 'password' => bcrypt('safe-password-test')]);
        $threat = Threat::create(['type' => 'malware', 'severity' => 7,
            'description' => 'Test observation', 'status' => 'detected',
            'detected_at' => now(), 'user_id' => $owner->id]);
        $incident = Incident::create(['threat_id' => $threat->id, 'title' => 'Case',
            'description' => 'test', 'reported_at' => now(), 'severity' => 7]);
        $action = ThreatAction::create(['threat_id' => $threat->id,
            'action_type' => 'alert', 'status' => 'pending']);

        Sanctum::actingAs($viewer);
        $this->getJson('/api/threats')->assertOk()->assertJsonCount(0, 'data.data');
        $this->getJson('/api/threats/statistics')->assertOk()->assertJsonPath('data.total', 0);
        $this->getJson("/api/threats/{$threat->id}")->assertNotFound();
        $this->getJson('/api/incidents')->assertOk()->assertJsonCount(0, 'data.data');
        $this->getJson("/api/incidents/{$incident->id}")->assertNotFound();
        $this->getJson('/api/threat-actions')->assertOk()->assertJsonCount(0, 'data.data');
        $this->getJson("/api/threat-actions/{$action->id}")->assertNotFound();
        $this->postJson('/api/incidents', [
            'title' => 'Cross-user attempt', 'description' => 'should be rejected',
            'severity' => 7, 'threat_id' => $threat->id,
        ])->assertNotFound();
        $this->postJson('/api/threat-actions', [
            'threat_id' => $threat->id, 'action_type' => 'block_ip',
        ])->assertNotFound();
    }

    public function test_user_cannot_forge_completed_defensive_action(): void
    {
        $user = User::create(['name' => 'Operator', 'email' => 'operator@example.test', 'password' => bcrypt('safe-password-test')]);
        $threat = Threat::create(['type' => 'malware', 'severity' => 8,
            'description' => 'Test', 'status' => 'detected',
            'detected_at' => now(), 'user_id' => $user->id]);
        $action = ThreatAction::create(['threat_id' => $threat->id,
            'action_type' => 'block_ip', 'status' => 'pending']);
        Sanctum::actingAs($user);
        $this->putJson("/api/threat-actions/{$action->id}", [
            'status' => 'completed',
        ])->assertForbidden();
        $this->assertDatabaseHas('threat_actions', [
            'id' => $action->id, 'status' => 'pending',
        ]);
    }
}
