<?php

namespace App\Http\Middleware;

use App\Enums\Device;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class DetectDevice
{
    public function handle(Request $request, Closure $next): Response
    {
        $device = Device::tryFrom((string) $request->header('X-Device', Device::WEB->value)) ?? Device::WEB;

        $request->attributes->set('device', $device);

        return $next($request);
    }
}
