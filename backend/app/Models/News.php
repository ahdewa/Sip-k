<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class News extends Model
{
    use HasFactory;

    protected $table = 'news';

    protected $fillable = [
        'tag',
        'title',
        'desc',
        'date',
        'image',
        'author',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];
}