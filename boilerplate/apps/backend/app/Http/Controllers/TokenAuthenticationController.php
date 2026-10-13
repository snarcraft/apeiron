<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTokenRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Mobile/token auth: manual credential check + rate limiting,
 * issuing a device-named Sanctum token.
 */
class TokenAuthenticationController extends Controller
{
    public function store(StoreTokenRequest $request): JsonResponse
    {
        $request->ensureIsNotRateLimited();

        $user = User::where('email', $request->string('email')->lower())->first();

        if (!$user || !Hash::check($request->string('password'), $user->password)) {
            $request->incrementRateAttempts();

            throw ValidationException::withMessages([
                'email' => trans('auth.failed'),
            ]);
        }

        $token = $user->createToken($request->string('device'))->plainTextToken;

        return JsonResponse::fromJsonString(
            json_encode(['data' => ['token' => $token, 'user' => $user->toResource()->resolve()]]) ?: '{}',
        );
    }

    public function destroy(): JsonResponse
    {
        Auth::user()?->currentAccessToken()?->delete();

        return response()->json(['data' => null]);
    }
}
