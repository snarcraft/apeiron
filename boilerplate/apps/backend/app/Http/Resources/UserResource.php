<?php

namespace App\Http\Resources;

use App\Enums\Feature;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Laravel\Pennant\Feature as Pennant;

/**
 * @mixin \App\Models\User
 */
class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'name' => $this->name,
            'email' => $this->email,
            'group' => $this->group,
            'role' => $this->role,
            'email_verified_at' => $this->email_verified_at?->toIso8601String(),
            'last_seen_at' => $this->last_seen_at?->toIso8601String(),
            'onboarding_completed_at' => $this->onboarding_completed_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),

            // The policy map rides along with the user payload —
            // the frontend's useAuth().can() reads exactly this.
            'policies' => Pennant::for($this->resource)->values(Feature::all()),
        ];
    }
}
