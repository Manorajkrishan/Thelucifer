<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'success' => true,
        'message' => 'SentinelAI X API',
        'version' => '1.0.0',
        'status' => 'online',
        'timestamp' => now()->toIso8601String(),
        'api_base' => '/api',
        'endpoints' => [
            'health' => '/api/health',
            'auth' => '/api/login, /api/register',
            'threats' => '/api/threats',
            'documents' => '/api/documents',
            'incidents' => '/api/incidents',
            'threat-actions' => '/api/threat-actions',
        ]
    ]);
});
