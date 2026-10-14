<?php

use App\Http\Controllers\AuthenticatedSessionController;
use App\Http\Controllers\ContactController;
use App\Http\Controllers\MediaController;
use App\Http\Controllers\SettingsController;
use App\Http\Controllers\StripeWebhookController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\TokenAuthenticationController;
use App\Http\Controllers\TranslationController;
use App\Http\Controllers\UpdatePasswordController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

Route::get('translations', TranslationController::class)->name('translations');
Route::get('settings', SettingsController::class)->name('settings');

Route::post('contacts', ContactController::class)->middleware('throttle:contact')->name('contacts');

Route::post('auth/token', [TokenAuthenticationController::class, 'store']);

// Registered by scripts/bootstrap.mjs — signature-verified, no session.
Route::post('stripe/webhook', StripeWebhookController::class)->name('stripe.webhook');

Route::middleware('auth:sanctum')->group(function (): void {
    Route::delete('auth/token', [TokenAuthenticationController::class, 'destroy']);

    Route::apiSingleton('user', UserController::class);
    Route::apiSingleton('password', UpdatePasswordController::class)->only(['update']);

    Route::apiSingleton('team', TeamController::class)->only(['show']);
    Route::apiResource('teams', TeamController::class)->middleware('can:team:manage');
    Route::apiResource('members', TeamController::class)->only(['index']);

    Route::apiResource('media', MediaController::class)->only(['store', 'destroy']);
});

// Domain features land here — one invokable controller per verb,
// gated by the can:feature:action middleware. Example:
//
// Route::middleware(['auth:sanctum', 'verified'])->group(function (): void {
//     Route::get('tasks', Task\IndexController::class)->middleware('can:task:read');
//     Route::post('tasks', Task\StoreController::class)->middleware('can:task:create');
// });
