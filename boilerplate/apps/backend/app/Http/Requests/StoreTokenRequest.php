<?php

namespace App\Http\Requests;

use Illuminate\Http\Exceptions\ThrottleRequestsException;
use Illuminate\Support\Facades\RateLimiter;

class StoreTokenRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
            'device' => ['required', 'string', 'max:255'],
        ];
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'email' => str($this->string('email'))->lower()->toString(),
        ]);
    }

    public function ensureIsNotRateLimited(): void
    {
        if (app()->environment('local')) {
            return;
        }

        if (!RateLimiter::tooManyAttempts($this->key(), 5)) {
            return;
        }

        throw new ThrottleRequestsException('');
    }

    public function incrementRateAttempts(): void
    {
        RateLimiter::hit($this->key());
    }

    private function key(): string
    {
        return sprintf('token:%s|%s', $this->string('email'), $this->ip());
    }
}
