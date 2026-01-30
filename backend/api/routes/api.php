<?php

use App\Http\Controllers\Api\ThreatController;
use App\Http\Controllers\Api\DocumentController;
use App\Http\Controllers\Api\IncidentController;
use App\Http\Controllers\Api\ThreatActionController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

use App\Http\Controllers\Api\AuthController;

// API Root / Health Check (no auth required)
Route::get('/', function () {
    return response()->json([
        'success' => true,
        'message' => 'SentinelAI X API',
        'version' => '1.0.0',
        'status' => 'online',
        'timestamp' => now()->toIso8601String(),
        'endpoints' => [
            'auth' => '/api/login, /api/register',
            'threats' => '/api/threats',
            'documents' => '/api/documents',
            'incidents' => '/api/incidents',
            'threat-actions' => '/api/threat-actions',
        ]
    ]);
});

// Health check endpoint
Route::get('/health', function () {
    try {
        // Quick database check
        \DB::connection()->getPdo();
        $dbStatus = 'connected';
    } catch (\Exception $e) {
        $dbStatus = 'disconnected';
    }

    return response()->json([
        'success' => true,
        'status' => 'online',
        'database' => $dbStatus,
        'timestamp' => now()->toIso8601String(),
    ]);
});

// CORS preflight (OPTIONS) – avoid 404 from other app on :8000
Route::options('/login', fn () => response('', 204));
Route::options('/register', fn () => response('', 204));

// Authentication routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
});

// Threat Management (protected routes)
Route::middleware('auth:sanctum')->prefix('threats')->group(function () {
    Route::get('/', [ThreatController::class, 'index']);
    Route::get('/statistics', [ThreatController::class, 'statistics']);
    Route::post('/', [ThreatController::class, 'store']);
    Route::get('/{threat}', [ThreatController::class, 'show']);
    Route::put('/{threat}', [ThreatController::class, 'update']);
    Route::delete('/{threat}', [ThreatController::class, 'destroy']);
});

// Document Management (protected routes)
Route::middleware('auth:sanctum')->prefix('documents')->group(function () {
    Route::get('/', [DocumentController::class, 'index']);
    Route::post('/', [DocumentController::class, 'store']);
    Route::get('/{document}', [DocumentController::class, 'show']);
    Route::get('/{document}/download', [DocumentController::class, 'download']);
    Route::post('/{document}/process', [DocumentController::class, 'process']);
    Route::delete('/{document}', [DocumentController::class, 'destroy']);
});

// Incident Management (protected routes)
Route::middleware('auth:sanctum')->prefix('incidents')->group(function () {
    Route::get('/', [IncidentController::class, 'index']);
    Route::post('/', [IncidentController::class, 'store']);
    Route::get('/{incident}', [IncidentController::class, 'show']);
    Route::put('/{incident}', [IncidentController::class, 'update']);
    Route::delete('/{incident}', [IncidentController::class, 'destroy']);
});

// Threat Action Management (protected routes)
Route::middleware('auth:sanctum')->prefix('threat-actions')->group(function () {
    Route::get('/', [ThreatActionController::class, 'index']);
    Route::post('/', [ThreatActionController::class, 'store']);
    Route::post('/auto-create', [ThreatActionController::class, 'autoCreate']);
    Route::get('/{threatAction}', [ThreatActionController::class, 'show']);
    Route::put('/{threatAction}', [ThreatActionController::class, 'update']);
    Route::delete('/{threatAction}', [ThreatActionController::class, 'destroy']);
});
