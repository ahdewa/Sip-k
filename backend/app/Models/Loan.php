<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Loan extends Model
{
    use HasFactory;

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'id',
        'user_id',
        'borrower_name',
        'department',
        'vehicle_id',
        'vehicle_name',
        'destination',
        'destination_address',
        'purpose_description',
        'start_date',
        'end_date',
        'official_note_number',
        'sim_photo_path',
        'status',
        'submitted_at',
        'spk_number',
        'rejection_reason',
        'return_odometer',
        'return_fuel',
        'return_notes',
        'returned_at',
    ];

    protected $casts = [
        'start_date' => 'datetime',
        'end_date' => 'datetime',
        'submitted_at' => 'datetime',
        'returned_at' => 'datetime',
        'return_odometer' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function vehicle()
    {
        return $this->belongsTo(Vehicle::class, 'vehicle_id');
    }
}
