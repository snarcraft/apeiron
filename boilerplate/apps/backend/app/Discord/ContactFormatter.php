<?php

namespace App\Discord;

class ContactFormatter extends AbstractFormatter
{
    public static string $type = 'contact';

    /**
     * @return array<string, mixed>
     */
    public function payload(): array
    {
        return [
            'embeds' => [
                [
                    'title' => 'New website inquiry',
                    'color' => 3066993,
                    'fields' => [
                        ['name' => 'Name', 'value' => (string) ($this->data['name'] ?? '—'), 'inline' => true],
                        ['name' => 'Email', 'value' => (string) ($this->data['email'] ?? '—'), 'inline' => true],
                        ['name' => 'Message', 'value' => substr((string) ($this->data['message'] ?? '—'), 0, 1024)],
                    ],
                    'timestamp' => now()->toIso8601String(),
                ],
            ],
        ];
    }
}
