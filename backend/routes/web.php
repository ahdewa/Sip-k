<?php

use Illuminate\Support\Facades\Route;

// Sajikan aplikasi Flutter Web jika sudah dideploy di public/index.html
Route::get('/{any?}', function () {
    $indexPath = public_path('index.html');
    if (file_exists($indexPath)) {
        return response()->file($indexPath);
    }
    return view('welcome');
})->where('any', '^(?!api|storage).*$');
