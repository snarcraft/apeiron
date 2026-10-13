<?php

namespace App\Models;

use App\Enums\Country;
use App\Enums\Currency;
use App\Enums\Device;
use App\Enums\Group;
use App\Enums\Interval;
use App\Enums\Plan;
use App\Enums\Role;

/**
 * Per-subdomain tenant settings, resolved once per request by
 * DetectSubdomain and bound as a scoped singleton.
 */
class Setting extends Model
{
    protected $table = 'settings';

    protected function casts(): array
    {
        return [
            'theme' => 'array',
            'country' => Country::class,
            'currency' => Currency::class,
        ];
    }

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public static function default(): self
    {
        return once(function () {
            return self::query()->whereNull('team_id')->first() ?? new self([
                'name' => config('app.name'),
                'title' => config('app.name'),
            ]);
        });
    }

    /**
     * The frontend bootstrapping payload: every enum option list
     * the UI renders selects from.
     *
     * @return array<string, mixed>
     */
    public function options(): array
    {
        return [
            'roles' => Role::all(),
            'groups' => Group::all(),
            'plans' => Plan::all(),
            'intervals' => Interval::all(),
            'devices' => collect(Device::cases()),
            'countries' => Country::all(),
        ];
    }
}
