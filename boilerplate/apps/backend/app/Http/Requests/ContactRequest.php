<?php

namespace App\Http\Requests;

class ContactRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email'],
            'message' => ['required', 'string', 'max:4000'],
        ];
    }
}
