<?php

use App\Events\SendMailFailed;
use App\Http\Middleware\DetectDevice;
use App\Http\Middleware\DetectSubdomain;
use App\Http\Middleware\Localization;
use App\Http\Middleware\TrackAuthActivity;
use App\Http\Middleware\TrackLogContext;
use App\Runtime\Secrets;
use Illuminate\Auth\Middleware\EnsureEmailIsVerified;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Symfony\Component\Mime\Exception\RfcComplianceException;

Secrets::addToEnvironment();

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        channels: __DIR__ . '/../routes/channels.php',
        api: __DIR__ . '/../routes/api.php',
        web: __DIR__ . '/../routes/web.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->statefulApi();

        $middleware->prepend(DetectDevice::class);

        $middleware->append(Localization::class);

        $middleware->api(append: [
            DetectSubdomain::class,
            TrackLogContext::class,
            TrackAuthActivity::class,
        ]);

        $middleware->alias([
            'verified' => EnsureEmailIsVerified::class,
        ]);
    })
    ->withBroadcasting(
        sprintf('%s/../routes/channels.php', __DIR__),
        ['prefix' => 'api', 'middleware' => ['api', 'auth:sanctum']],
    )
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );

        $exceptions->report(function (RfcComplianceException $exception) {
            $closure = collect($exception->getTrace())->where(
                fn (array $trace) => 'send' === data_get($trace, 'function')
                && is_callable(data_get($trace, 'args.0'))
            )->values()->slice(0, 1)->pluck('args.0')->first();

            if ($closure instanceof Closure) {
                SendMailFailed::dispatch(new ReflectionFunction($closure)->getClosureThis());

                return false;
            }
        });
    })
    ->withSchedule(function (Schedule $schedule) {
        $schedule->command('model:prune')->dailyAt('04:00');
        $schedule->command('pennant:purge')->dailyAt('04:00');
        $schedule->command('auth:clear-cache')->dailyAt('04:00');
        $schedule->command('auth:clear-resets')->dailyAt('04:00');
        $schedule->command('horizon:snapshot')->everyFiveMinutes();
        $schedule->command('sanctum:prune-expired')->dailyAt('04:00');
    })
    ->create();
