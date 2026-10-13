<?php

namespace App\Http\Middleware;

use App\Enums\Language;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class Localization
{
    public function handle(Request $request, Closure $next): Response
    {
        $locale = $request->string('locale', (string) $request->header('Accept-Language', config('app.locale')))
            ->lower()
            ->substr(0, 2)
            ->toString();

        if (null === Language::tryFrom($locale)) {
            $locale = config('app.locale');
        }

        app()->setLocale($locale);

        return $next($request);
    }
}
