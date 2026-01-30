<?php

namespace App\Exceptions;

use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Throwable;

class Handler extends ExceptionHandler
{
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            //
        });
    }

    /**
     * API-only app: always return 401 JSON. Never redirect to route('login')
     * (that route does not exist and caused 500 on unauthenticated /api/* requests).
     */
    protected function unauthenticated($request, AuthenticationException $exception)
    {
        return response()->json([
            'message' => $exception->getMessage() ?: 'Unauthenticated.',
            'success' => false,
        ], 401);
    }
}
