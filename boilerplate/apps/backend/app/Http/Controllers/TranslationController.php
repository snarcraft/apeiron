<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

class TranslationController extends Controller
{
    /**
     * The full message dictionary for the requested (or header
     * resolved) locale — loaded by the webapp at boot.
     */
    public function __invoke(): JsonResponse
    {
        $locale = app()->getLocale();

        return response()->json([
            'data' => Storage::json(sprintf('lang/%s.json', $locale)) ?? [],
        ]);
    }
}
