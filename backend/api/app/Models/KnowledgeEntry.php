<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class KnowledgeEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'document_id',
        'type',
        'title',
        'content',
        'category',
        'keywords',
        'confidence_score',
        'metadata',
    ];

    protected $casts = [
        'keywords' => 'array',
        'metadata' => 'array',
        'confidence_score' => 'float',
    ];

    /**
     * Get the document this knowledge entry belongs to
     */
    public function document(): BelongsTo
    {
        return $this->belongsTo(Document::class);
    }
}
