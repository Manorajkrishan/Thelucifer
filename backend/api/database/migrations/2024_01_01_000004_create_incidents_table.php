<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('incidents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('threat_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description');
            $table->string('status')->default('open'); // open, investigating, resolved, closed
            $table->integer('priority')->default(1); // 1-5 scale
            $table->integer('severity')->default(1); // 1-10 scale
            $table->timestamp('reported_at');
            $table->timestamp('resolved_at')->nullable();
            $table->foreignId('assigned_to')->nullable()->constrained('users')->nullOnDelete();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['status', 'priority']);
            $table->index('reported_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('incidents');
    }
};
