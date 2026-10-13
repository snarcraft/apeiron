<?php

namespace App\Providers;

use App\Enums\Action;
use App\Enums\Feature;
use App\Enums\Language;
use App\Models\Model;
use App\Models\Setting;
use App\Models\User;
use Carbon\CarbonInterval;
use Illuminate\Auth\Middleware\Authenticate;
use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Auth\Notifications\VerifyEmail;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Foundation\Application;
use Illuminate\Http\Response;
use Illuminate\Support\Carbon;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Str;
use Illuminate\Translation\Translator;
use Illuminate\Validation\Rules\Password;
use Laravel\Pennant\Feature as Pennant;
use Laravel\Pennant\Middleware\EnsureFeaturesAreActive;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->registerAuth();
        $this->registerSettings();
    }

    public function boot(): void
    {
        $this->registerSetup();
        $this->registerMacros();
        $this->registerRateLimit();
        $this->registerUrls();
        $this->registerTranslations();
        $this->registerAbilities();
    }

    private function registerSetup(): void
    {
        Schema::defaultStringLength(191);

        Model::shouldBeStrict(!$this->app->environment('production'));
        Model::automaticallyEagerLoadRelationships();
        Model::unguard();

        Password::defaults(
            fn () => $this->app->environment('production')
            ? Password::min(8)->mixedCase()->uncompromised()->letters()->numbers()->symbols()
            : Password::min(6)
        );
    }

    private function registerRateLimit(): void
    {
        RateLimiter::for('api', function ($request) {
            return Limit::perMinute(env('API_RATE_LIMIT', 60))->by($request->user()?->id ?: $request->ip());
        });

        RateLimiter::for('contact', function ($request) {
            // The contact endpoint is guest-facing: throttle per IP and per
            // submitted email so a rotating IP cannot flood the relay.
            $key = sprintf('%s|%s', $request->ip(), $request->string('email'));

            return [
                Limit::perMinute((int) env('CONTACT_RATE_LIMIT_PER_MINUTE', 5))->by("contact:minute:{$key}"),
                Limit::perHour((int) env('CONTACT_RATE_LIMIT_PER_HOUR', 20))->by("contact:hour:{$key}"),
            ];
        });
    }

    private function registerAuth(): void
    {
        Auth::provider(
            'membership',
            fn (Application $app, $config) => (new CachedUserProvider($app['hash'], $config['model'])),
        );
    }

    /**
     * Scoped so Octane resets the binding between requests; the
     * DetectSubdomain middleware overrides it per request.
     */
    private function registerSettings(): void
    {
        $this->app->scoped(Setting::class, fn () => Setting::default());
    }

    /**
     * The ability layer: every {feature}:{action} pair becomes a
     * Pennant flag (cached per user) and a Gate ability. Admins
     * short-circuit everything; unknown pairs are denied.
     */
    private function registerAbilities(): void
    {
        foreach (Feature::cases() as $feature) {
            foreach (Action::cases() as $action) {
                Pennant::define(
                    "{$feature->value}:{$action->value}",
                    fn (User $user) => $user->may($feature, $action),
                );
            }
        }

        Gate::before(function (User $user, string $ability): ?bool {
            if ($user->isAdmin()) {
                return true;
            }

            if (!str_contains($ability, ':')) {
                return null;
            }

            [$feature, $action] = explode(':', $ability, 2);

            if (null === Feature::tryFrom($feature) || null === Action::tryFrom($action)) {
                return false;
            }

            return Pennant::for($user)->active($ability);
        });

        EnsureFeaturesAreActive::whenInactive(fn () => new Response(status: 403));
    }

    private function registerMacros(): void
    {
        Auth::macro('clear', function () {
            Cache::tags(User::AUTH_CACHE_TAGS)->flush();
            Pennant::purge();
        });
    }

    private function registerUrls(): void
    {
        ResetPassword::createUrlUsing(
            fn (User $user, string $token) => sprintf(
                '%s/password/reset/%s?email=%s',
                config('app.frontend_url'),
                $token,
                $user->getEmailForPasswordReset(),
            ),
        );

        VerifyEmail::createUrlUsing(
            fn (User $user) => sprintf(
                '%s%s',
                config('app.url'),
                URL::temporarySignedRoute(
                    name: 'verification.verify',
                    expiration: Carbon::now()->addMinutes(config('auth.verification.expire', 60)),
                    parameters: [
                        'user' => $user->uuid,
                        'hash' => sha1($user->getEmailForVerification()),
                    ],
                    absolute: false,
                ),
            ),
        );

        Authenticate::redirectUsing(fn () => config('app.frontend_url') . '/login');
    }

    private function registerTranslations(): void
    {
        $this->callAfterResolving('translator', function (Translator $translator) {
            Language::locales()->each(function (string $locale) use ($translator) {
                $messages = Cache::tags('lang')->rememberForever(
                    sprintf('lang/%s.json', $locale),
                    fn () => Storage::json(sprintf('lang/%s.json', $locale)),
                );

                // Lang files are nested objects — flatten so every
                // dotted key registers as a translatable line.
                collect(Arr::dot($messages ?? []))
                    ->each(fn (string $message, string $key) => $translator->addLines([
                        sprintf('*.%s', $key) => $message,
                    ], $locale));
            });
        });
    }
}
