<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Mail\ThreatAlertMail;
use App\Models\Threat;
use App\Models\ThreatAction;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;

class ThreatController extends Controller
{
    /**
     * Display a listing of threats
     */
    public function index(Request $request): JsonResponse
    {
        $query = Threat::query();

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by severity
        if ($request->has('severity')) {
            $query->where('severity', $request->severity);
        }

        // Filter by type
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('description', 'like', "%{$search}%")
                  ->orWhere('source_ip', 'like', "%{$search}%")
                  ->orWhere('classification', 'like', "%{$search}%");
            });
        }

        // Pagination
        $perPage = $request->get('per_page', 15);
        $threats = $query->orderBy('detected_at', 'desc')->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $threats,
        ]);
    }

    /**
     * Store a newly created threat
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|string',
            'severity' => 'required|integer|min:1|max:10',
            'source_ip' => 'nullable|ip',
            'target_ip' => 'nullable|ip',
            'description' => 'required|string',
            'classification' => 'nullable|string',
            'metadata' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $threat = Threat::create([
            ...$validator->validated(),
            'status' => 'detected',
            'detected_at' => now(),
            'user_id' => auth()->id(),
        ]);

        // Auto-create threat actions based on severity
        $this->autoCreateThreatActions($threat);

        // Email alerts for high-severity threats
        $this->sendThreatAlertIfNeeded($threat);

        return response()->json([
            'success' => true,
            'data' => $threat->load('actions'),
            'message' => 'Threat detected and recorded successfully',
        ], 201);
    }

    /**
     * Display the specified threat
     */
    public function show(Threat $threat): JsonResponse
    {
        $threat->load(['incidents', 'actions']);

        return response()->json([
            'success' => true,
            'data' => $threat,
        ]);
    }

    /**
     * Update the specified threat
     */
    public function update(Request $request, Threat $threat): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'sometimes|string|in:detected,analyzing,mitigated,resolved',
            'severity' => 'sometimes|integer|min:1|max:10',
            'description' => 'sometimes|string',
            'metadata' => 'sometimes|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        if ($request->has('status') && $request->status === 'resolved') {
            $threat->resolved_at = now();
        }

        $threat->update($validator->validated());

        return response()->json([
            'success' => true,
            'data' => $threat,
            'message' => 'Threat updated successfully',
        ]);
    }

    /**
     * Remove the specified threat
     */
    public function destroy(Threat $threat): JsonResponse
    {
        $threat->delete();

        return response()->json([
            'success' => true,
            'message' => 'Threat deleted successfully',
        ]);
    }

    /**
     * Get threat statistics
     */
    public function statistics(): JsonResponse
    {
        $stats = [
            'total' => Threat::count(),
            'by_status' => Threat::selectRaw('status, count(*) as count')
                ->groupBy('status')
                ->pluck('count', 'status'),
            'by_type' => Threat::selectRaw('type, count(*) as count')
                ->groupBy('type')
                ->pluck('count', 'type'),
            'by_severity' => Threat::selectRaw('severity, count(*) as count')
                ->groupBy('severity')
                ->pluck('count', 'severity'),
            'recent_24h' => Threat::where('detected_at', '>=', now()->subDay())->count(),
            'by_date' => $this->threatsByDate(7),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Threat counts per day for the last N days (for charts).
     */
    protected function threatsByDate(int $days): array
    {
        $out = [];
        for ($i = $days - 1; $i >= 0; $i--) {
            $d = now()->subDays($i)->format('Y-m-d');
            $out[] = [
                'date' => $d,
                'count' => Threat::whereDate('detected_at', $d)->count(),
            ];
        }
        return $out;
    }

    /**
     * Auto-create threat actions based on threat severity
     */
    protected function autoCreateThreatActions(Threat $threat): void
    {
        try {
            // Critical threats (severity >= 8): Block IP, Isolate, Alert
            if ($threat->severity >= 8) {
                ThreatAction::create([
                    'threat_id' => $threat->id,
                    'action_type' => 'block_ip',
                    'action_details' => ['ip' => $threat->source_ip],
                    'status' => 'pending',
                ]);

                if ($threat->target_ip) {
                    ThreatAction::create([
                        'threat_id' => $threat->id,
                        'action_type' => 'isolation',
                        'action_details' => ['target' => $threat->target_ip],
                        'status' => 'pending',
                    ]);
                }
            }
            // High threats (severity >= 5): Firewall rule, Alert
            elseif ($threat->severity >= 5) {
                ThreatAction::create([
                    'threat_id' => $threat->id,
                    'action_type' => 'firewall_rule',
                    'action_details' => ['ip' => $threat->source_ip, 'action' => 'deny'],
                    'status' => 'pending',
                ]);
            }

            // Always create an alert for all threats
            ThreatAction::create([
                'threat_id' => $threat->id,
                'action_type' => 'alert',
                'action_details' => [
                    'severity' => $threat->severity,
                    'type' => $threat->type,
                    'source_ip' => $threat->source_ip,
                ],
                'status' => 'pending',
            ]);
        } catch (\Exception $e) {
            // Log error but don't fail threat creation
            \Log::error('Failed to auto-create threat actions', [
                'threat_id' => $threat->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Send email alert for high-severity threats when configured.
     */
    protected function sendThreatAlertIfNeeded(Threat $threat): void
    {
        $config = config('mail.threat_alert', []);
        $enabled = $config['enabled'] ?? true;
        $minSeverity = (int) ($config['min_severity'] ?? 7);
        $to = $config['to'] ?? [];

        if (!$enabled || $threat->severity < $minSeverity) {
            return;
        }

        $to = array_values(array_filter(array_map('trim', is_array($to) ? $to : [])));
        if (empty($to)) {
            return;
        }

        try {
            Mail::to($to)->send(new ThreatAlertMail($threat));
        } catch (\Exception $e) {
            \Log::warning('Failed to send threat alert email', [
                'threat_id' => $threat->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
