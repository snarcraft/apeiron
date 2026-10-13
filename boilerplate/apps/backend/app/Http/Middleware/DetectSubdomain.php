<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Resolves the tenant Setting from the subdomain and overrides
 * the scoped singleton (e.g. acme.{{DOMAIN}} → Setting for
 * acme). Requests without a tenant subdomain keep the default.
 */
class DetectSubdomain
{
    public function handle(Request $request, Closure $next): Response
    {
        $host = $request->getHost();

        if ($host !== config('app.domain')) {
            $subdomain = str($host)->beforeLast(config('app.domain'))->rtrim('.')->toString();

            if ('' !== $subdomain && !str($subdomain)->contains('.')) {
                $setting = \App\Models\Setting::where('subdomain', $subdomain)->first();

                if ($setting) {
                    app()->instance(\App\Models\Setting::class, $setting);
                }
            }
        }

        return $next($request);
    }
}
