<?php

use App\Http\Controllers\Api\ThreatController;
use App\Http\Controllers\Api\DocumentController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Threat Management
Route::prefix('threats')->group(function () {
    Route::get('/', [ThreatController::class, 'index']);
    Route::get('/statistics', [ThreatController::class, 'statistics']);
    Route::post('/', [ThreatController::class, 'store']);
    Route::get('/{threat}', [ThreatController::class, 'show']);
    Route::put('/{threat}', [ThreatController::class, 'update']);
    Route::delete('/{threat}', [ThreatController::class, 'destroy']);
});

// Document Management
Route::prefix('documents')->group(function () {
    Route::get('/', [DocumentController::class, 'index']);
    Route::post('/', [DocumentController::class, 'store']);
    Route::get('/{document}', [DocumentController::class, 'show']);
    Route::get('/{document}/download', [DocumentController::class, 'download']);
    Route::post('/{document}/process', [DocumentController::class, 'process']);
    Route::delete('/{document}', [DocumentController::class, 'destroy']);
});
