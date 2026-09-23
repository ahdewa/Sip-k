<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\VehicleController;
use App\Http\Controllers\LoanController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\UserController;

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
