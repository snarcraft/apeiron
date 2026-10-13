<?php

namespace App\Http\Controllers;

use App\Enums\Language;
use App\Models\Setting;
use Illuminate\Http\JsonResponse;

/**
 * The server-driven application document (GET /) — the same
 * contract the mobile app bootstraps from: identity, locale,
 * theme, and the public client keys. Tenant-aware via the
 * DetectSubdomain scoped Setting.
 */
class ApplicationController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $setting = app(Setting::class);

        return response()->json([
            'data' => [
                'name' => $setting->name ?? config('app.name'),
                'title' => $setting->title ?? config('app.name'),
                'version' => config('app.version'),
                'env' => config('app.env'),
                'debug' => (bool) config('app.debug'),
                'timezone' => config('app.timezone'),
                'language' => app()->getLocale(),
                'country' => $setting->country ?? config('app.country'),
                'frontend_url' => config('app.frontend_url'),
                'web_url' => config('app.web_url'),

                'theme' => $setting->theme ?? [
                    'font_family' => config('services.theme.font'),
                    'primary' => config('services.theme.primary'),
                    'secondary' => config('services.theme.secondary'),
                    'tertiary' => config('services.theme.tertiary'),
                    'brightness' => 'light',
                ],

                'stripe' => [
                    'key' => config('services.stripe.key'),
                ],

                'reverb' => [
                    'host' => config('services.reverb.host'),
                    'port' => config('services.reverb.port'),
                    'scheme' => config('services.reverb.scheme'),
                    'app_key' => config('services.reverb.app_key'),
                ],

                'locales' => Language::locales()->values(),
            ],
        ]);
    }
}
