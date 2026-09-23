<?php

namespace App\Http\Controllers;

use App\Models\AppNotification;
use App\Models\User;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $query = AppNotification::query()->orderBy('created_at', 'desc');

        $userId = $request->user() ? $request->user()->id : $request->query('user_id');
        $role = $request->user() ? $request->user()->role : $request->query('role');
        $borrowerName = $request->query('borrower_name');

        if (empty($userId) && !empty($borrowerName)) {
            $matched = User::where('name', 'like', "%{$borrowerName}%")->first();
            if ($matched) {
                $userId = $matched->id;
            }
        }

        // Jika role user/pegawai tapi userId kosong, cari user pegawai pertama (misal Alamsyah ID: 4)
        if (empty($userId) && ($role === 'user' || $role === 'pegawai')) {
            $defaultPegawai = User::whereIn('role', ['pegawai', 'user'])->first();
            if ($defaultPegawai) {
                $userId = $defaultPegawai->id;
            }
        }

        if ($role === 'admin' || $role === 'superadmin') {
            // Admin melihat semua notifikasi permohonan masuk & info broadcast
            $query->where(function ($q) use ($userId) {
                $q->whereNull('user_id')
                  ->orWhere('title', 'like', '%Perlu Verifikasi%');
                if ($userId) {
                    $q->orWhere('user_id', $userId);
                }
            });
            // Admin tidak perlu melihat notifikasi pribadi pemohon "Permohonan Berhasil Dikirim"
            $query->where('title', 'not like', '%Permohonan Berhasil Dikirim%');
        } else {
            // User / Pegawai:
            // 1. Filter keluar SEMUA notifikasi verifikasi khusus admin
            $query->where('title', 'not like', '%Perlu Verifikasi%');

            // 2. Ambil notifikasi milik user (user_id), notifikasi status persetujuan/penolakan, dan info broadcast
            $query->where(function ($q) use ($userId) {
                if ($userId) {
                    $q->where('user_id', $userId)
                      ->orWhereIn('type', ['approved', 'rejected'])
                      ->orWhere(function ($sub) {
                          $sub->whereNull('user_id')->whereIn('type', ['welcome', 'maintenance', 'reminder']);
                      });
                } else {
                    $q->whereIn('type', ['approved', 'rejected', 'submitted', 'welcome', 'maintenance', 'reminder']);
                }
            });
        }

        $notifications = $query->get();

        return response()->json([
            'status' => 'success',
            'data' => $notifications,
        ]);
    }

    public function markRead(Request $request, $id)
    {
        $notification = AppNotification::findOrFail($id);
        $notification->update(['is_read' => true]);

        return response()->json([
            'status' => 'success',
            'message' => 'Notifikasi ditandai sudah dibaca.',
        ]);
    }

    public function markAllRead(Request $request)
    {
        $query = AppNotification::where('is_read', false);

        $userId = $request->user() ? $request->user()->id : $request->query('user_id');
        $role = $request->user() ? $request->user()->role : $request->query('role');
        $borrowerName = $request->query('borrower_name');

        if (empty($userId) && !empty($borrowerName)) {
            $matched = User::where('name', 'like', "%{$borrowerName}%")->first();
            if ($matched) {
                $userId = $matched->id;
            }
        }

        if (empty($userId) && ($role === 'user' || $role === 'pegawai')) {
            $defaultPegawai = User::whereIn('role', ['pegawai', 'user'])->first();
            if ($defaultPegawai) {
                $userId = $defaultPegawai->id;
            }
        }

        if ($role === 'admin' || $role === 'superadmin') {
            $query->where(function ($q) use ($userId) {
                $q->whereNull('user_id')
                  ->orWhere('title', 'like', '%Perlu Verifikasi%');
                if ($userId) {
                    $q->orWhere('user_id', $userId);
                }
            });
            $query->where('title', 'not like', '%Permohonan Berhasil Dikirim%');
        } else {
            $query->where('title', 'not like', '%Perlu Verifikasi%');
            $query->where(function ($q) use ($userId) {
                if ($userId) {
                    $q->where('user_id', $userId)
                      ->orWhereIn('type', ['approved', 'rejected'])
                      ->orWhere(function ($sub) {
                          $sub->whereNull('user_id')->whereIn('type', ['welcome', 'maintenance', 'reminder']);
                      });
                } else {
                    $q->whereIn('type', ['approved', 'rejected', 'submitted', 'welcome', 'maintenance', 'reminder']);
                }
            });
        }

        $query->update(['is_read' => true]);

        return response()->json([
            'status' => 'success',
            'message' => 'Semua notifikasi ditandai sudah dibaca.',
        ]);
    }
}
