<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('threats', function (Blueprint $table) {
            $table->id();
            $table->string('type'); // malware, trojan, ransomware, phishing, etc.
            $table->integer('severity')->default(1); // 1-10 scale
            $table->string('status')->default('detected'); // detected, analyzing, mitigated, resolved
            $table->ipAddress('source_ip')->nullable();
            $table->ipAddress('target_ip')->nullable();
            $table->text('description');
            $table->string('classification')->nullable();
            $table->json('metadata')->nullable();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->timestamp('detected_at');
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index(['status', 'severity']);
            $table->index('detected_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('threats');
    }
};
