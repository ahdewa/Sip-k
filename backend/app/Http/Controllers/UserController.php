<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::query();

        if ($request->filled('role')) {
            $role = $request->role;
            if ($role === 'user') $role = 'pegawai';
            $query->where('role', $role);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('nip', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('department', 'like', "%{$search}%");
            });
        }

        $users = $query->orderBy('name')->get();

        return response()->json([
            'status' => 'success',
            'data' => $users,
        ]);
    }

    public function show($id)
    {
        $cleanNip = str_replace(' ', '', $id);
        $user = User::where('id', $id)
            ->orWhere('nip', $id)
            ->orWhere('nip', $cleanNip)
            ->orWhere('email', $id)
            ->first();

        if (!$user) {
            $user = User::first();
        }

        return response()->json([
            'status' => 'success',
            'data' => $user,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'nip' => 'nullable|string|max:50',
            'email' => 'required|email|unique:users,email',
            'role' => 'nullable|in:pegawai,admin,superadmin,user',
            'department' => 'nullable|string|max:255',
            'position' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
            'profile_image_url' => 'nullable|string',
            'password' => 'nullable|string|min:6',
        ]);

        $role = $validated['role'] ?? 'pegawai';
        if ($role === 'user') $role = 'pegawai';

        $user = User::create([
            'name' => $validated['name'],
            'nip' => $validated['nip'] ?? null,
            'email' => $validated['email'],
            'role' => $role,
            'department' => $validated['department'] ?? 'Dinas Sosial Jawa Timur',
            'position' => $validated['position'] ?? 'Staf Pelaksana',
            'phone' => $validated['phone'] ?? '0812-3456-7890',
            'profile_image_url' => $validated['profile_image_url'] ?? null,
            'password' => Hash::make($validated['password'] ?? 'password123'),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Pengguna berhasil ditambahkan.',
            'data' => $user,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $cleanNip = str_replace(' ', '', $id);
        $user = User::where('id', $id)
            ->orWhere('nip', $id)
            ->orWhere('nip', $cleanNip)
            ->orWhere('email', $id)
            ->first();

        if (!$user) {
            $user = User::where('role', 'pegawai')->first() ?? User::firstOrFail();
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'nip' => 'nullable|string|max:50',
            'email' => 'sometimes|required|email|unique:users,email,' . $user->id,
            'role' => 'nullable|in:pegawai,admin,superadmin,user',
            'department' => 'nullable|string|max:255',
            'position' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
            'profile_image_url' => 'nullable|string',
            'password' => 'nullable|string|min:6',
        ]);

        if (isset($validated['role']) && $validated['role'] === 'user') {
            $validated['role'] = 'pegawai';
        }

        if (!empty($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        } else {
            unset($validated['password']);
        }

        $user->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Data pengguna berhasil diperbarui.',
            'data' => $user,
        ]);
    }

    public function destroy($id)
    {
        $cleanNip = str_replace(' ', '', $id);
        $user = User::where('id', $id)
            ->orWhere('nip', $id)
            ->orWhere('nip', $cleanNip)
            ->orWhere('email', $id)
            ->firstOrFail();
        $user->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Pengguna berhasil dihapus.',
        ]);
    }
}
