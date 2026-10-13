<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('teams', function (Blueprint $table): void {
            $table->id();
            $table->ulid('uuid')->unique();
            $table->string('stripe_id')->nullable()->index();
            $table->string('name')->index();
            $table->string('group', 32)->index();
            $table->string('pm_type', 32)->nullable();
            $table->string('pm_last_four', 4)->nullable();
            $table->string('registration_number')->nullable();
            $table->string('vat_number')->nullable();
            $table->json('theme')->nullable();
            $table->timestamp('trial_ends_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->index('created_at');
        });

        Schema::create('members', function (Blueprint $table): void {
            $table->id();
            $table->ulid('uuid')->unique();
            $table->foreignIdFor(\App\Models\User::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(\App\Models\Team::class)->constrained()->cascadeOnDelete();
            $table->string('role', 32)->index();
            $table->timestamps();
            $table->unique(['user_id', 'team_id']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('members');
        Schema::dropIfExists('teams');
    }
};
