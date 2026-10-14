<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\VehicleController;
use App\Http\Controllers\LoanController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\NewsController;

/*
|--------------------------------------------------------------------------
| API Routes SIP-K Jatim
|--------------------------------------------------------------------------
*/

// Auth & Tokens
Route::post('/login', [AuthController::class, 'login']);
Route::post('/user/fcm-token', [AuthController::class, 'updateFcmToken']);
Route::post('/fcm-token', [AuthController::class, 'updateFcmToken']);

// Vehicles (Armada)
Route::get('/vehicles', [VehicleController::class, 'index']);
Route::get('/vehicles/{id}', [VehicleController::class, 'show']);
Route::post('/vehicles', [VehicleController::class, 'store']);
Route::put('/vehicles/{id}', [VehicleController::class, 'update']);
Route::delete('/vehicles/{id}', [VehicleController::class, 'destroy']);

// Loans (Peminjaman)
Route::get('/loans', [LoanController::class, 'index']);
Route::get('/loans/{id}', [LoanController::class, 'show']);
Route::post('/loans', [LoanController::class, 'store']);
Route::post('/loans/{id}/approve', [LoanController::class, 'approve']);
Route::post('/loans/{id}/reject', [LoanController::class, 'reject']);
Route::post('/loans/{id}/start', [LoanController::class, 'start']);
Route::post('/loans/{id}/complete', [LoanController::class, 'complete']);
Route::post('/loans/{id}/cancel', [LoanController::class, 'cancel']);

// Users (Pegawai & Admin)
Route::get('/users', [UserController::class, 'index']);
Route::get('/users/{id}', [UserController::class, 'show']);
Route::post('/users', [UserController::class, 'store']);
Route::put('/users/{id}', [UserController::class, 'update']);
Route::delete('/users/{id}', [UserController::class, 'destroy']);


// News (Berita & Pengumuman Dinsos)
Route::get('/news', [NewsController::class, 'index']);
Route::post('/news/sync', [NewsController::class, 'sync']);
Route::post('/news', [NewsController::class, 'store']);
Route::put('/news/{id}', [NewsController::class, 'update']);
Route::delete('/news/{id}', [NewsController::class, 'destroy']);

// Image Proxy (Bypass CORS untuk Flutter Web & Serve Local Storage)
Route::get('/image-proxy', function (\Illuminate\Http\Request $request) {
    $url = $request->query('url');
    if (!$url) {
        return response('Missing url parameter', 400);
    }

    // 1. Jika URL merujuk ke file storage lokal (misal: /storage/loan_documents/...)
    // Baca langsung dari disk server tanpa cURL loopback (mencegah Hairpin NAT timeout)
    $parsedPath = parse_url($url, PHP_URL_PATH);
    if ($parsedPath && str_contains($parsedPath, '/storage/')) {
        $subPath = substr($parsedPath, strpos($parsedPath, '/storage/') + strlen('/storage/'));
        $localFile = public_path('storage/' . $subPath);
        if (!file_exists($localFile)) {
            $localFile = storage_path('app/public/' . $subPath);
        }

        if (file_exists($localFile)) {
            $mime = @mime_content_type($localFile) ?: 'image/jpeg';
            return response()->file($localFile, [
                'Content-Type' => $mime,
                'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => 'GET, OPTIONS',
                'Cache-Control' => 'public, max-age=86400',
            ]);
        }
    }

    // 2. Jika remote URL, lakukan cURL dengan bypass SSL
    try {
        $host = parse_url($url, PHP_URL_HOST);
        $fetchUrl = $url;
        if ($host === '20.244.48.18') {
            $fetchUrl = str_replace('http://20.244.48.18', 'http://127.0.0.1', $url);
        }

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $fetchUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_TIMEOUT, 15);
        curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
        $content = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $contentType = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
        curl_close($ch);

        if ($httpCode >= 200 && $httpCode < 300 && !empty($content)) {
            return response($content, 200)
                ->header('Content-Type', $contentType ?: 'image/jpeg')
                ->header('Access-Control-Allow-Origin', '*')
                ->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
                ->header('Cache-Control', 'public, max-age=86400');
        }

        return response('Failed to fetch image', $httpCode ?: 404);
    } catch (\Throwable $e) {
        return response('Proxy error: ' . $e->getMessage(), 500);
    }
});

// Notifications
Route::get('/notifications', [NotificationController::class, 'index']);
Route::post('/notifications/{id}/read', [NotificationController::class, 'markRead']);
Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);

// Protected routes (Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/user/profile', [AuthController::class, 'updateProfile']);
    Route::post('/logout', [AuthController::class, 'logout']);
});

// Proxy API Wilayah Jawa Timur (Bypass CORS di Web/Chrome)
Route::get('/wilayah/regencies/{provCode}', function ($provCode) {
    try {
        $opts = ['http' => ['method' => 'GET', 'header' => "User-Agent: Mozilla/5.0\r\n"]];
        $ctx = stream_context_create($opts);
        $json = @file_get_contents("https://wilayah.id/api/regencies/{$provCode}.json", false, $ctx);
        if ($json) return response($json, 200)->header('Content-Type', 'application/json');
    } catch (\Throwable $e) {}
    return response()->json(['data' => []]);
});

Route::get('/wilayah/districts/{regCode}', function ($regCode) {
    try {
        $opts = ['http' => ['method' => 'GET', 'header' => "User-Agent: Mozilla/5.0\r\n"]];
        $ctx = stream_context_create($opts);
        $json = @file_get_contents("https://wilayah.id/api/districts/{$regCode}.json", false, $ctx);
        if ($json) return response($json, 200)->header('Content-Type', 'application/json');
    } catch (\Throwable $e) {}
    return response()->json(['data' => []]);
});

Route::get('/wilayah/villages/{distCode}', function ($distCode) {
    try {
        $opts = ['http' => ['method' => 'GET', 'header' => "User-Agent: Mozilla/5.0\r\n"]];
        $ctx = stream_context_create($opts);
        $json = @file_get_contents("https://wilayah.id/api/villages/{$distCode}.json", false, $ctx);
        if ($json) return response($json, 200)->header('Content-Type', 'application/json');
    } catch (\Throwable $e) {}
    return response()->json(['data' => []]);
});