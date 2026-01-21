<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('documents', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('filename');
            $table->string('file_path');
            $table->string('file_type'); // pdf, docx, txt, doc
            $table->bigInteger('file_size');
            $table->string('status')->default('uploaded'); // uploaded, processing, processed, failed
            $table->timestamp('processed_at')->nullable();
            $table->json('extracted_data')->nullable();
            $table->json('metadata')->nullable();
            $table->foreignId('uploaded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index('status');
            $table->index('file_type');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('documents');
    }
};
