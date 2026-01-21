<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('knowledge_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('document_id')->constrained()->cascadeOnDelete();
            $table->string('type'); // attack_technique, exploit_pattern, defense_strategy, etc.
            $table->string('title');
            $table->text('content');
            $table->string('category')->nullable();
            $table->json('keywords')->nullable();
            $table->float('confidence_score')->default(0.0);
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['type', 'category']);
            $table->index('confidence_score');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('knowledge_entries');
    }
};
