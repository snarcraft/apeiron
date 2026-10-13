<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

class TrackLogContext
{
    public function handle(Request $request, Closure $next): Response
    {
        Log::shareContext([
            'request_id' => (string) str()->uuid(),
            'route' => $request->route()?->getName() ?? $request->path(),
            'method' => $request->method(),
            'ip' => $request->ip(),
            'user' => $request->user()?->uuid,
        ]);

        return $next($request);
    }
}
