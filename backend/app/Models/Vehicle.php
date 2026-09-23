<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Vehicle extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'brand',
        'plate_number',
        'color',
        'type',
        'capacity',
        'transmission',
        'current_odometer',
        'fuel_percent',
        'fuel_type',
        'condition_note',
        'status',
        'image_url',
        'gallery_images',
    ];

    protected $casts = [
        'capacity' => 'integer',
        'current_odometer' => 'integer',
        'fuel_percent' => 'integer',
        'gallery_images' => 'array',
    ];

    public function loans()
    {
        return $this->hasMany(Loan::class, 'vehicle_id');
    }
}
