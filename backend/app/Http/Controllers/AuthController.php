<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'nullable',
            'login' => 'nullable',
            'password' => 'required',
            'fcm_token' => 'nullable|string',
        ]);

        $loginInput = trim($request->input('login') ?? $request->input('email') ?? '');

        if (empty($loginInput)) {
            return response()->json([
                'status' => 'error',
                'message' => 'NIP atau Nama Lengkap wajib diisi!',
            ], 422);
        }

        $cleanNip = str_replace([' ', '-', '.'], '', $loginInput);
        $lower = strtolower($loginInput);

        // 1. Cari exact match terlebih dahulu: NIP, Nama Lengkap (case-insensitive), atau Email
        $user = User::where('nip', $loginInput)
            ->orWhere('nip', $cleanNip)
            ->orWhereRaw('REPLACE(REPLACE(REPLACE(nip, " ", ""), "-", ""), ".", "") = ?', [$cleanNip])
            ->orWhereRaw('LOWER(name) = ?', [$lower])
            ->orWhereRaw('LOWER(email) = ?', [$lower])
            ->first();

        // 2. Jika belum ditemukan, coba LIKE pada nama (misal nama sebagian / panggilan)
        if (!$user) {
            $user = User::where('name', 'like', "%{$loginInput}%")->first();
        }

        // 3. Dukungan alias role default jika demo
        if (!$user) {
            if ($lower === 'superadmin' || $lower === 'super admin') {
                $user = User::where('role', 'superadmin')->first();
            } elseif ($lower === 'admin' || $lower === 'kasubag') {
                $user = User::where('role', 'admin')->first();
            } elseif ($lower === 'pegawai' || $lower === 'user') {
                $user = User::where('role', 'pegawai')->first();
            }
        }

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'NIP/Nama atau password salah!',
            ], 401);
        }

        // Update token FCM jika dikirim dari perangkat HP
        if ($request->filled('fcm_token')) {
            $user->update(['fcm_token' => $request->fcm_token]);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login berhasil.',
            'data' => [
                'token' => $token,
                'user' => $user,
            ],
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'data' => $request->user(),
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:50',
            'position' => 'nullable|string|max:255',
            'department' => 'nullable|string|max:255',
            'profile_image_url' => 'nullable|string',
        ]);

        $user->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Profil berhasil diperbarui.',
            'data' => $user,
        ]);
    }

    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        $user = $request->user();
        if (!$user && $request->filled('user_id')) {
            $user = User::find($request->user_id);
        }

        if ($user) {
            $user->update([
                'fcm_token' => $request->fcm_token,
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'FCM Token berhasil diperbarui.',
            ]);
        }

        return response()->json([
            'status' => 'error',
            'message' => 'User tidak ditemukan.',
        ], 404);
    }

    public function logout(Request $request)
    {
        if ($request->user()) {
            $request->user()->currentAccessToken()->delete();
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Logout berhasil.',
        ]);
    }
}
