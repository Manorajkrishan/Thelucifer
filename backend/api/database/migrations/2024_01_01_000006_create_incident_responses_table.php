<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('incident_responses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('incident_id')->constrained()->cascadeOnDelete();
            $table->string('response_type'); // automated, manual, recommendation
            $table->text('description');
            $table->json('action_taken')->nullable();
            $table->string('status')->default('open'); // open, in_progress, completed
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['incident_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('incident_responses');
    }
};
