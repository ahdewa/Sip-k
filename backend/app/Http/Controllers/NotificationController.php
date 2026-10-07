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
            // Admin / Superadmin:
            // Hanya melihat notifikasi operasional (verifikasi, servis, BAST, akun baru, rekapitulasi)
            $query->where(function ($q) use ($userId) {
                $q->where('title', 'like', '%Perlu Verifikasi%')
                  ->orWhere('title', 'like', '%Servis%')
                  ->orWhere('title', 'like', '%BAST%')
                  ->orWhere('title', 'like', '%Bentrok%')
                  ->orWhere('title', 'like', '%Akun Baru%')
                  ->orWhere('title', 'like', '%Pendaftaran Akun%')
                  ->orWhere('title', 'like', '%Rekapitulasi%')
                  ->orWhere('type', 'maintenance')
                  ->orWhere(function ($sub) {
                      $sub->whereNull('user_id')
                          ->where('title', 'not like', '%Selamat Datang%')
                          ->where('title', 'not like', '%Permohonan Berhasil Dikirim%')
                          ->where('title', 'not like', '%Pengajuan Terkirim%');
                  });
                if ($userId) {
                    $q->orWhere('user_id', $userId);
                }
            });
            // Admin TIDAK melihat notifikasi permohonan pribadi pegawai
            $query->where('title', 'not like', '%Permohonan Berhasil Dikirim%')
                  ->where('title', 'not like', '%Pengajuan Terkirim%')
                  ->where('title', 'not like', '%Selamat Datang di OVBS%');
        } else {
            // User / Pegawai:
            // 1. Filter KELUAR semua notifikasi verifikasi & teknis khusus admin
            $query->where('title', 'not like', '%Perlu Verifikasi%')
                  ->where('title', 'not like', '%Servis Rutin%')
                  ->where('title', 'not like', '%Peringatan Servis%')
                  ->where('title', 'not like', '%Penugasan Bentrok%')
                  ->where('title', 'not like', '%Pendaftaran Akun Pegawai%')
                  ->where('title', 'not like', '%Rekapitulasi Bulanan%');

            // 2. Ambil hanya notifikasi milik user ini atau broadcast pegawai (welcome, reminder)
            $query->where(function ($q) use ($userId) {
                if ($userId) {
                    $q->where('user_id', $userId)
                      ->orWhere(function ($sub) {
                          $sub->whereNull('user_id')
                              ->whereIn('type', ['welcome', 'reminder'])
                              ->where('title', 'not like', '%Verifikasi%')
                              ->where('title', 'not like', '%Servis%')
                              ->where('title', 'not like', '%Bentrok%')
                              ->where('title', 'not like', '%Rekapitulasi%');
                      });
                } else {
                    $q->whereIn('type', ['welcome', 'reminder'])
                      ->where('title', 'not like', '%Verifikasi%')
                      ->where('title', 'not like', '%Servis%')
                      ->where('title', 'not like', '%Bentrok%')
                      ->where('title', 'not like', '%Rekapitulasi%');
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
                $q->where('title', 'like', '%Perlu Verifikasi%')
                  ->orWhere('title', 'like', '%Servis%')
                  ->orWhere('title', 'like', '%BAST%')
                  ->orWhere('title', 'like', '%Bentrok%')
                  ->orWhere('title', 'like', '%Akun Baru%')
                  ->orWhere('title', 'like', '%Pendaftaran Akun%')
                  ->orWhere('title', 'like', '%Rekapitulasi%')
                  ->orWhere('type', 'maintenance')
                  ->orWhere(function ($sub) {
                      $sub->whereNull('user_id')
                          ->where('title', 'not like', '%Selamat Datang%')
                          ->where('title', 'not like', '%Permohonan Berhasil Dikirim%')
                          ->where('title', 'not like', '%Pengajuan Terkirim%');
                  });
                if ($userId) {
                    $q->orWhere('user_id', $userId);
                }
            });
            $query->where('title', 'not like', '%Permohonan Berhasil Dikirim%')
                  ->where('title', 'not like', '%Pengajuan Terkirim%')
                  ->where('title', 'not like', '%Selamat Datang di OVBS%');
        } else {
            $query->where('title', 'not like', '%Perlu Verifikasi%')
                  ->where('title', 'not like', '%Servis Rutin%')
                  ->where('title', 'not like', '%Peringatan Servis%')
                  ->where('title', 'not like', '%Penugasan Bentrok%')
                  ->where('title', 'not like', '%Pendaftaran Akun Pegawai%')
                  ->where('title', 'not like', '%Rekapitulasi Bulanan%');

            $query->where(function ($q) use ($userId) {
                if ($userId) {
                    $q->where('user_id', $userId)
                      ->orWhere(function ($sub) {
                          $sub->whereNull('user_id')
                              ->whereIn('type', ['welcome', 'reminder'])
                              ->where('title', 'not like', '%Verifikasi%')
                              ->where('title', 'not like', '%Servis%')
                              ->where('title', 'not like', '%Bentrok%')
                              ->where('title', 'not like', '%Rekapitulasi%');
                      });
                } else {
                    $q->whereIn('type', ['welcome', 'reminder'])
                      ->where('title', 'not like', '%Verifikasi%')
                      ->where('title', 'not like', '%Servis%')
                      ->where('title', 'not like', '%Bentrok%')
                      ->where('title', 'not like', '%Rekapitulasi%');
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
