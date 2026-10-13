<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateUserRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function show(): UserResource
    {
        return UserResource::make(request()->user());
    }

    public function update(UpdateUserRequest $request): UserResource
    {
        $request->user()->update($request->validated());

        return UserResource::make($request->user()->fresh());
    }
}
