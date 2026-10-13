<?php

namespace App\Discord;

/**
 * A formatted Discord webhook payload. Implementations build the
 * embed for their notification type; resolve() picks the right
 * formatter for a ->notify(type, data) call.
 */
abstract class AbstractFormatter
{
    /**
     * @param array<string, mixed> $data
     */
    public function __construct(public array $data)
    {
    }

    /**
     * @return array<string, mixed>
     */
    abstract public function payload(): array;

    public static string $type = '';

    /**
     * @param array<string, mixed> $data
     */
    public static function resolve(string $type, array $data): self
    {
        $formatter = collect([ContactFormatter::class])
            ->first(fn (string $class) => $class::$type === $type);

        throw_unless($formatter, \InvalidArgumentException::class, sprintf('Unknown formatter [%s].', $type));

        return new $formatter($data);
    }
}
