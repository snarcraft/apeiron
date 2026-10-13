<?php

namespace App\Enums;

use Illuminate\Support\Collection;

enum Language: string
{
    case EN = 'en';
    case FR = 'fr';
    case DE = 'de';
    case ES = 'es';

    /**
     * @return Collection<string>
     */
    public static function locales(): Collection
    {
        return collect(self::cases())->map(fn (Language $language) => $language->value);
    }

    public function intl(): string
    {
        return \Locale::composeLocale([
            'language' => $this->value,
            'region' => config('app.country', 'FR'),
        ]);
    }
}
