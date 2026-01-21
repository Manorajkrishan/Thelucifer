<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ThreatAction extends Model
{
    use HasFactory;

    protected $fillable = [
        'threat_id',
        'action_type',
        'action_details',
        'status',
        'executed_at',
        'result',
        'metadata',
    ];

    protected $casts = [
        'action_details' => 'array',
        'result' => 'array',
        'metadata' => 'array',
        'executed_at' => 'datetime',
    ];

    /**
     * Get the threat this action belongs to
     */
    public function threat(): BelongsTo
    {
        return $this->belongsTo(Threat::class);
    }
}
