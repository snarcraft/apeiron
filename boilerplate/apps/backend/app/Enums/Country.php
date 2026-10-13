<?php

namespace App\Enums;

enum Country: string
{
    case BE = 'BE';
    case DE = 'DE';
    case ES = 'ES';
    case FR = 'FR';
    case GB = 'GB';
    case US = 'US';

    public function currency(): Currency
    {
        return match ($this) {
            Country::GB => Currency::GBP,
            Country::US => Currency::USD,
            default => Currency::EUR,
        };
    }
}
