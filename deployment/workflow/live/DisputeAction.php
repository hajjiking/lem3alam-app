<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DisputeAction extends Model
{
    public const RESPONDENT_ACTIONS = ['appeal', 'propose_resolution'];
    public const COMPLAINANT_ACTIONS = ['accept_resolution', 'request_other_solution'];

    protected $fillable = [
        'dispute_id',
        'actor_id',
        'action',
        'message',
        'metadata',
    ];

    protected $casts = [
        'metadata' => 'array',
    ];

    public function dispute(): BelongsTo
    {
        return $this->belongsTo(Dispute::class);
    }

    public function actor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'actor_id');
    }
}

