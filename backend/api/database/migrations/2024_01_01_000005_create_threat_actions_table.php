<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('threat_actions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('threat_id')->constrained()->cascadeOnDelete();
            $table->string('action_type'); // firewall_rule, isolation, patch, etc.
            $table->json('action_details')->nullable();
            $table->string('status')->default('pending'); // pending, executing, completed, failed
            $table->timestamp('executed_at')->nullable();
            $table->json('result')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['threat_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('threat_actions');
    }
};
