<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settings', function (Blueprint $table): void {
            $table->id();
            $table->ulid('uuid')->unique();
            $table->foreignIdFor(\App\Models\Team::class)->nullable()->constrained()->cascadeOnDelete();
            $table->string('subdomain')->nullable()->unique();
            $table->string('name')->index();
            $table->string('title')->nullable();
            $table->string('country', 2)->default('FR');
            $table->string('currency', 3)->default('EUR');
            $table->json('theme')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('settings');
    }
};
