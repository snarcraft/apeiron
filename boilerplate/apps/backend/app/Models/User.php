<?php

namespace App\Models;

use App\Enums\Device;
use App\Enums\Group;
use App\Enums\Role;
use App\Models\Concerns\Contractual;
use App\Models\Concerns\InteractsWithAbilities;
use App\Models\Concerns\InteractsWithUuid;
use App\Models\Concerns\LogsActivity;
use App\Enums\Feature;
use App\Notifications\ResetPassword;
use App\Notifications\VerifyEmail;
use App\Observers\UserObserver;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;
use Laravel\Pennant\Feature as Pennant;
use Laravel\Sanctum\HasApiTokens;

#[ObservedBy(UserObserver::class)]
class User extends Authenticatable
{
    use HasApiTokens;
    use HasFactory;
    use InteractsWithAbilities;
    use InteractsWithUuid;
    use LogsActivity;
    use Contractual;
    use Notifiable;

    public const AUTH_CACHE_TAGS = ['auth'];

    protected $table = 'users';

    protected $hidden = ['password', 'remember_token'];

    protected static string $passwordResetNotification = ResetPassword::class;

    protected static string $emailVerificationNotification = VerifyEmail::class;

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'last_seen_at' => 'datetime',
            'onboarding_completed_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function devices(): Collection
    {
        return collect($this->tokens)
            ->map(fn ($token) => Device::tryFrom($token->name))
            ->filter()
            ->unique()
            ->values();
    }

    /**
     * Flush everything derived from this user's identity: the
     * auth cache tag and their Pennant feature values.
     */
    public function clearCache(): void
    {
        Cache::tags(self::AUTH_CACHE_TAGS)->flush();

        Pennant::for($this)->forget(...Feature::all()->all());
    }
}
