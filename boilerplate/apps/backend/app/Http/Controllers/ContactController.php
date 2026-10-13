<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Requests\ContactRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Http;

/**
 * Website contact form → Discord relay. Guest-facing, throttled
 * by the `contact` rate limiter (IP + email keyed).
 */
class ContactController extends Controller
{
    public function __invoke(ContactRequest $request): JsonResponse
    {
        Http::discord()->notify('contact', $request->validated())->throw();

        return response()->json(['data' => ['received' => true]]);
    }
}
