<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invitations', function (Blueprint $table): void {
            $table->id();
            $table->ulid('uuid')->unique();
            $table->foreignIdFor(\App\Models\Team::class)->nullable()->constrained()->nullOnDelete();
            $table->string('email')->index();
            $table->string('role', 32);
            $table->timestamps();
            $table->softDeletes();
            $table->unique(['team_id', 'email']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invitations');
    }
};
