<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class IncidentResponse extends Model
{
    use HasFactory;

    protected $fillable = [
        'incident_id',
        'response_type',
        'description',
        'action_taken',
        'status',
        'created_at',
        'created_by',
        'metadata',
    ];

    protected $casts = [
        'action_taken' => 'array',
        'metadata' => 'array',
        'created_at' => 'datetime',
    ];

    /**
     * Get the incident this response belongs to
     */
    public function incident(): BelongsTo
    {
        return $this->belongsTo(Incident::class);
    }
}
