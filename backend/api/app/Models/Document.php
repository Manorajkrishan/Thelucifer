<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Document extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'filename',
        'file_path',
        'file_type',
        'file_size',
        'status',
        'processed_at',
        'extracted_data',
        'metadata',
        'uploaded_by',
    ];

    protected $casts = [
        'extracted_data' => \App\Casts\JsonOrEmptyArray::class,
        'metadata' => \App\Casts\JsonOrEmptyArray::class,
        'processed_at' => 'datetime',
        'file_size' => 'integer',
    ];

    /**
     * Get all knowledge extracted from this document
     */
    public function knowledgeEntries(): HasMany
    {
        return $this->hasMany(KnowledgeEntry::class);
    }
}
