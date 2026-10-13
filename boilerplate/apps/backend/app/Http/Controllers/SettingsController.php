<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Resources\SettingResource;
use App\Models\Setting;
use Illuminate\Http\JsonResponse;

class SettingsController extends Controller
{
    /**
     * The frontend bootstrapping payload: tenant settings plus
     * every enum option list the UI needs.
     */
    public function __invoke(): JsonResponse
    {
        $setting = app(Setting::class);

        return response()->json([
            'data' => SettingResource::make($setting)->resolve(),
        ]);
    }
}
