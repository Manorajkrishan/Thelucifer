<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Threat;
use App\Models\ThreatAction;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class ThreatActionController extends Controller
{
    /**
     * Display a listing of threat actions
     */
    public function index(Request $request): JsonResponse
    {
        $query = ThreatAction::query();

        // Filter by threat_id
        if ($request->has('threat_id')) {
            $query->where('threat_id', $request->threat_id);
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by action_type
        if ($request->has('action_type')) {
            $query->where('action_type', $request->action_type);
        }

        $perPage = $request->get('per_page', 15);
        $actions = $query->with('threat')->orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $actions,
        ]);
    }

    /**
     * Store a newly created threat action
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'threat_id' => 'required|exists:threats,id',
            'action_type' => 'required|string|in:firewall_rule,isolation,patch,block_ip,quarantine,alert,investigation,mitigation',
            'action_details' => 'nullable|array',
            'status' => 'nullable|string|in:pending,executing,completed,failed',
            'metadata' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
                'error' => $validator->errors()->first(),
            ], 422);
        }

        try {
            $action = ThreatAction::create([
                'threat_id' => $request->threat_id,
                'action_type' => $request->action_type,
                'action_details' => $request->action_details ?? [],
                'status' => $request->status ?? 'pending',
                'metadata' => $request->metadata ?? [],
            ]);

            return response()->json([
                'success' => true,
                'data' => $action->load('threat'),
                'message' => 'Threat action created successfully',
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create threat action',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Display the specified threat action
     */
    public function show(ThreatAction $threatAction): JsonResponse
    {
        $threatAction->load('threat');

        return response()->json([
            'success' => true,
            'data' => $threatAction,
        ]);
    }

    /**
     * Update the specified threat action
     */
    public function update(Request $request, ThreatAction $threatAction): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => 'sometimes|string|in:pending,executing,completed,failed',
            'action_details' => 'sometimes|array',
            'result' => 'sometimes|array',
            'metadata' => 'sometimes|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // If status is completed or failed, set executed_at
            if ($request->has('status') && in_array($request->status, ['completed', 'failed'])) {
                $threatAction->executed_at = now();
            }

            $threatAction->update($validator->validated());

            return response()->json([
                'success' => true,
                'data' => $threatAction->load('threat'),
                'message' => 'Threat action updated successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update threat action',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified threat action
     */
    public function destroy(ThreatAction $threatAction): JsonResponse
    {
        try {
            $threatAction->delete();

            return response()->json([
                'success' => true,
                'message' => 'Threat action deleted successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete threat action',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Auto-create threat actions for a threat based on severity
     */
    public function autoCreate(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'threat_id' => 'required|exists:threats,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $threat = Threat::findOrFail($request->threat_id);
            $actions = [];

            // Auto-create actions based on threat severity
            if ($threat->severity >= 8) {
                // Critical: Block IP, Isolate, Alert
                $actions[] = ThreatAction::create([
                    'threat_id' => $threat->id,
                    'action_type' => 'block_ip',
                    'action_details' => ['ip' => $threat->source_ip],
                    'status' => 'pending',
                ]);

                $actions[] = ThreatAction::create([
                    'threat_id' => $threat->id,
                    'action_type' => 'isolation',
                    'action_details' => ['target' => $threat->target_ip],
                    'status' => 'pending',
                ]);
            } elseif ($threat->severity >= 5) {
                // High: Firewall rule, Alert
                $actions[] = ThreatAction::create([
                    'threat_id' => $threat->id,
                    'action_type' => 'firewall_rule',
                    'action_details' => ['ip' => $threat->source_ip, 'action' => 'deny'],
                    'status' => 'pending',
                ]);
            }

            // Always create an alert
            $actions[] = ThreatAction::create([
                'threat_id' => $threat->id,
                'action_type' => 'alert',
                'action_details' => ['severity' => $threat->severity, 'type' => $threat->type],
                'status' => 'pending',
            ]);

            return response()->json([
                'success' => true,
                'data' => $actions,
                'message' => count($actions) . ' threat action(s) created automatically',
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to auto-create threat actions',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
