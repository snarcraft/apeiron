<?php

namespace App\Logging;

use Monolog\Formatter\FormatterInterface;
use Monolog\LogRecord;

/**
 * Single-line JSON per log entry: level, message, context (the
 * request context shared by TrackLogContext) and extras — the
 * shape promtail ships to Loki.
 */
class ActivityFormatter implements FormatterInterface
{
    /**
     * @return string
     */
    public function format(LogRecord $record)
    {
        return json_encode([
            'env' => config('app.env'),
            'level' => $record->level->getName(),
            'message' => $record->message,
            'context' => $record->context,
            'extra' => $record->extra,
            'datetime' => $record->datetime->format(DATE_ATOM),
        ]) . "\n";
    }

    /**
     * @param array<LogRecord> $records
     *
     * @return array<string>
     */
    public function formatBatch(array $records)
    {
        return array_map(fn (LogRecord $record) => $this->format($record), $records);
    }
}
