<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Threat;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
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

        return response()->json([
            'success' => true,
            'data' => $threat,
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
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }
}
