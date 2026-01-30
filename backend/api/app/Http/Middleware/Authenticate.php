<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * API-only app: never redirect. Unauthenticated requests get 401 JSON.
     * Redirecting to route('login') caused 500 because that route does not exist.
     */
    protected function redirectTo(Request $request): ?string
    {
        return null;
    }
}
