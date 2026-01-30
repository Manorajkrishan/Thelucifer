<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Incident;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class IncidentController extends Controller
{
    /**
     * Display a listing of incidents
     */
    public function index(Request $request): JsonResponse
    {
        $query = Incident::query();

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $perPage = $request->get('per_page', 15);
        $incidents = $query->orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $incidents,
        ]);
    }

    /**
     * Store a newly created incident
     */
    public function store(Request $request): JsonResponse
    {
            $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'severity' => 'required|integer|min:1|max:10',
            'status' => 'nullable|string|in:open,investigating,resolved,closed',
            'threat_id' => 'nullable|exists:threats,id',
            'priority' => 'nullable|integer|min:1|max:5',
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
            // If no threat_id provided, create a default threat or make it nullable
            $threatId = $request->threat_id;
            if (!$threatId) {
                // Create a default threat for this incident
                $threat = \App\Models\Threat::create([
                    'type' => 'Incident Related',
                    'severity' => $request->severity,
                    'status' => 'detected',
                    'description' => 'Auto-created for incident: ' . $request->title,
                    'user_id' => auth()->id(),
                ]);
                $threatId = $threat->id;
            }

            $incident = Incident::create([
                'title' => $request->title,
                'description' => $request->description,
                'severity' => $request->severity,
                'priority' => $request->priority ?? 3,
                'status' => $request->status ?? 'open',
                'threat_id' => $threatId,
                'reported_at' => now(),
                'assigned_to' => auth()->id(),
            ]);

            return response()->json([
                'success' => true,
                'data' => $incident,
                'message' => 'Incident created successfully',
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create incident',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Display the specified incident
     */
    public function show(Incident $incident): JsonResponse
    {
        $incident->load('threat', 'responses');

        return response()->json([
            'success' => true,
            'data' => $incident,
        ]);
    }

    /**
     * Update the specified incident
     */
    public function update(Request $request, Incident $incident): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'severity' => 'sometimes|integer|min:1|max:10',
            'status' => 'sometimes|string|in:open,investigating,resolved,closed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $incident->update($request->only(['title', 'description', 'severity', 'status']));

            return response()->json([
                'success' => true,
                'data' => $incident,
                'message' => 'Incident updated successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update incident',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified incident
     */
    public function destroy(Incident $incident): JsonResponse
    {
        try {
            $incident->delete();

            return response()->json([
                'success' => true,
                'message' => 'Incident deleted successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete incident',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
