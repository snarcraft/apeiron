<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class TrackAuthActivity
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $user = $request->user();

        if ($user) {
            $user->forceFill([
                'last_seen_at' => now(),
                'last_seen_ip_address' => $request->ip(),
                'last_seen_user_agent' => $request->userAgent(),
            ])->saveQuietly();
        }

        return $response;
    }
}
