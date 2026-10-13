<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin \App\Models\Setting
 */
class SettingResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'name' => $this->name,
            'title' => $this->title,
            'subdomain' => $this->subdomain,
            'locale' => app()->getLocale(),
            'theme' => $this->theme,
            'options' => $this->when(true, fn () => $this->options()),
        ];
    }
}
