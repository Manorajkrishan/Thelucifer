<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Threat extends Model
{
    use HasFactory;

    protected $fillable = [
        'type',
        'severity',
        'status',
        'source_ip',
        'target_ip',
        'description',
        'classification',
        'detected_at',
        'resolved_at',
        'metadata',
        'user_id',
    ];

    protected $casts = [
        'metadata' => 'array',
        'detected_at' => 'datetime',
        'resolved_at' => 'datetime',
        'severity' => 'integer',
    ];

    /**
     * Get the user that detected this threat
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get all incidents related to this threat
     */
    public function incidents(): HasMany
    {
        return $this->hasMany(Incident::class);
    }

    /**
     * Get all actions taken for this threat
     */
    public function actions(): HasMany
    {
        return $this->hasMany(ThreatAction::class);
    }
}
