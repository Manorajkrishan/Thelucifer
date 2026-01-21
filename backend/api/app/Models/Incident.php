<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Incident extends Model
{
    use HasFactory;

    protected $fillable = [
        'threat_id',
        'title',
        'description',
        'status',
        'priority',
        'severity',
        'reported_at',
        'resolved_at',
        'assigned_to',
        'metadata',
    ];

    protected $casts = [
        'metadata' => 'array',
        'reported_at' => 'datetime',
        'resolved_at' => 'datetime',
        'priority' => 'integer',
        'severity' => 'integer',
    ];

    /**
     * Get the threat associated with this incident
     */
    public function threat(): BelongsTo
    {
        return $this->belongsTo(Threat::class);
    }

    /**
     * Get all responses to this incident
     */
    public function responses(): HasMany
    {
        return $this->hasMany(IncidentResponse::class);
    }
}
