<?php

use App\Http\Controllers\ApplicationController;
use App\Http\Controllers\AuthenticatedSessionController;
use App\Http\Controllers\PasswordResetLinkController;
use App\Http\Controllers\VerifyEmailController;
use Illuminate\Support\Facades\Route;

// The server-driven application document — mobile bootstraps from
// it (DI @preResolve), the webapp uses it as a fallback boot.
Route::get('/', ApplicationController::class)->name('application');

Route::middleware('guest')->group(function (): void {
    Route::post('auth/login', [AuthenticatedSessionController::class, 'store'])->middleware('throttle:6,1')->name('login');
    Route::post('password/recovery', [PasswordResetLinkController::class, 'store'])->middleware('throttle:6,1')->name('password.email');
});

Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('auth/logout', [AuthenticatedSessionController::class, 'destroy'])->name('logout');

    Route::get('email/verify/{user}/{hash}', VerifyEmailController::class)
        ->middleware(['signed:relative', 'throttle:6,1'])
        ->name('verification.verify');
});
