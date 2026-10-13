<?php

pest()->extend(Tests\TestCase::class)->in('Feature', 'Unit');

expect()->extend('toBeOne', fn () => $this->toBe(1));
