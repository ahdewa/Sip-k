<?php

namespace App\Http\Controllers;

use App\Models\Loan;
use App\Models\Vehicle;
use App\Models\AppNotification;
use App\Models\User;
use App\Services\FirebaseService;
use Illuminate\Http\Request;
use Carbon\Carbon;

class LoanController extends Controller
{
    public function index(Request $request)
    {
        $query = Loan::query()->orderBy('submitted_at', 'desc');

        if ($request->filled('status')) {
            $status = strtolower($request->status);
            if ($status === 'menunggu') {
                $query->whereIn('status', ['menunggu', 'pending']);
            } elseif ($status === 'disetujui') {
                $query->whereIn('status', ['disetujui', 'approved']);
            } elseif ($status === 'ditolak') {
                $query->whereIn('status', ['ditolak', 'rejected']);
            } else {
                $query->where('status', $status);
            }
        }

        if ($request->filled('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        if ($request->filled('month')) {
            // Format YYYY-MM
            $parts = explode('-', $request->month);
            if (count($parts) === 2) {
                $query->whereYear('start_date', $parts[0])
                      ->whereMonth('start_date', $parts[1]);
            }
        }

        $loans = $query->get();

        return response()->json([
            'status' => 'success',
            'data' => $loans,
        ]);
    }

    public function show($id)
    {
        $loan = Loan::findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $loan,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'id' => 'nullable|string|max:50',
            'user_id' => 'nullable',
            'borrower_name' => 'required|string|max:255',
            'department' => 'required|string|max:255',
            'vehicle_id' => 'required|string',
            'vehicle_name' => 'required|string|max:255',
            'destination' => 'required|string|max:255',
            'destination_address' => 'nullable|string',
            'purpose_description' => 'nullable|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date',
            'official_note_number' => 'nullable|string|max:100',
            'sim_photo_path' => 'nullable|string',
        ]);

        if (empty($validated['id'])) {
            $datePart = Carbon::now()->format('Ymd');
            $randomNum = rand(100, 999);
            $validated['id'] = "REQ-{$datePart}-{$randomNum}";
        }

        // Resolusi user_id jika kosong
        if (empty($validated['user_id'])) {
            if ($request->user()) {
                $validated['user_id'] = $request->user()->id;
            } else {
                $userMatch = User::where('name', 'like', "%{$validated['borrower_name']}%")->first();
                if ($userMatch) {
                    $validated['user_id'] = $userMatch->id;
                } else {
                    $activePegawai = User::whereIn('role', ['pegawai', 'user'])->whereNotNull('fcm_token')->first();
                    if ($activePegawai) {
                        $validated['user_id'] = $activePegawai->id;
                    }
                }
            }
        }

        $validated['submitted_at'] = Carbon::now();
        $validated['status'] = 'menunggu';

        // Simpan foto SIM jika dikirim dalam format base64 data URI
        if (!empty($validated['sim_photo_path'])) {
            if (preg_match('/^data:image\/(\w+);base64,/', $validated['sim_photo_path'], $type)) {
                $data = substr($validated['sim_photo_path'], strpos($validated['sim_photo_path'], ',') + 1);
                $type = strtolower($type[1]);
                $data = base64_decode($data);
                if ($data !== false) {
                    $fileName = 'sim_' . time() . '_' . uniqid() . '.' . $type;
                    $dir = public_path('storage/sim_photos');
                    if (!file_exists($dir)) {
                        mkdir($dir, 0777, true);
                    }
                    file_put_contents($dir . '/' . $fileName, $data);
                    $validated['sim_photo_path'] = asset('storage/sim_photos/' . $fileName);
                }
            }
        }

        $loan = Loan::create($validated);

        // 1. Notifikasi untuk pemohon di DB
        if (!empty($loan->user_id)) {
            AppNotification::create([
                'user_id' => $loan->user_id,
                'title' => 'Permohonan Berhasil Dikirim',
                'message' => "Pengajuan peminjaman unit {$loan->vehicle_name} ({$loan->id}) telah diajukan dan sedang menunggu verifikasi Kasubag.",
                'reference_number' => $loan->id,
                'type' => 'submitted',
                'is_read' => false,
            ]);
        }

        // 2. Notifikasi untuk Admin di DB (Global agar tampil di Admin Approval)
        AppNotification::create([
            'user_id' => null,
            'title' => 'Permohonan Masuk: Perlu Verifikasi',
            'message' => "{$loan->borrower_name} ({$loan->department}) mengajukan peminjaman {$loan->vehicle_name} tujuan {$loan->destination}.",
            'reference_number' => $loan->id,
            'type' => 'submitted',
            'is_read' => false,
        ]);

        // Push Notifikasi Firebase
        try {
            if (!empty($loan->user_id)) {
                FirebaseService::sendToUser(
                    $loan->user_id,
                    'Permohonan Berhasil Dikirim',
                    "Pengajuan armada {$loan->vehicle_name} ({$loan->id}) telah terkirim.",
                    ['type' => 'submitted', 'loan_id' => (string)$loan->id]
                );
            }
            FirebaseService::sendToAdmins(
                'Pengajuan Armada Baru',
                "{$loan->borrower_name} mengajukan peminjaman {$loan->vehicle_name}.",
                ['type' => 'submitted', 'loan_id' => (string)$loan->id]
            );
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::warning("FCM store notification error: " . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Permohonan pinjaman berhasil dikirim.',
            'data' => $loan,
        ], 201);
    }

    public function approve(Request $request, $id)
    {
        $loan = Loan::findOrFail($id);

        $spkNumber = $request->input('spk_number', 'ND-' . rand(1000, 9999) . '/DINSOS/' . Carbon::now()->year);

        $loan->update([
            'status' => 'disetujui',
            'spk_number' => $spkNumber,
        ]);

        // Update status armada jika ada
        $vehicle = Vehicle::find($loan->vehicle_id);
        if ($vehicle) {
            $vehicle->update(['status' => 'digunakan']);
        }

        // Cari user pemohon jika user_id kosong
        $targetUserId = $loan->user_id;
        if (empty($targetUserId)) {
            $userMatch = User::where('name', 'like', "%{$loan->borrower_name}%")->first();
            if ($userMatch) {
                $targetUserId = $userMatch->id;
                $loan->update(['user_id' => $targetUserId]);
            } else {
                $pegawai = User::whereIn('role', ['pegawai', 'user'])->whereNotNull('fcm_token')->first();
                if ($pegawai) {
                    $targetUserId = $pegawai->id;
                    $loan->update(['user_id' => $targetUserId]);
                }
            }
        }

        // Notifikasi ke pemohon di DB
        AppNotification::create([
            'user_id' => $targetUserId,
            'title' => 'Pengajuan Disetujui (Nota Dinas Terbit)',
            'message' => "Permohonan armada {$loan->vehicle_name} telah disetujui dengan nomor {$spkNumber}. Silakan ambil kunci dan cetak berkas.",
            'reference_number' => $spkNumber,
            'type' => 'approved',
            'is_read' => false,
        ]);

        // Push Notifikasi Firebase ke Pemohon
        try {
            if (!empty($targetUserId)) {
                FirebaseService::sendToUser(
                    $targetUserId,
                    'Pengajuan Disetujui (Nota Dinas Terbit)',
                    "Permohonan armada {$loan->vehicle_name} telah disetujui ({$spkNumber}). Silakan ambil kunci.",
                    ['type' => 'approved', 'loan_id' => (string)$loan->id, 'spk_number' => (string)$spkNumber]
                );
            } else {
                $usersWithFcm = User::whereNotNull('fcm_token')->whereNotIn('role', ['admin', 'superadmin'])->get();
                foreach ($usersWithFcm as $u) {
                    FirebaseService::sendToUser(
                        $u->id,
                        'Pengajuan Disetujui (Nota Dinas Terbit)',
                        "Permohonan armada {$loan->vehicle_name} telah disetujui ({$spkNumber}). Silakan ambil kunci.",
                        ['type' => 'approved', 'loan_id' => (string)$loan->id, 'spk_number' => (string)$spkNumber]
                    );
                }
            }
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::warning("FCM approve notification error: " . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Permohonan berhasil disetujui.',
            'data' => $loan,
        ]);
    }

    public function reject(Request $request, $id)
    {
        $loan = Loan::findOrFail($id);

        $reason = $request->input('rejection_reason', 'Jadwal armada bertabrakan dengan penugasan dinas prioritas.');

        $loan->update([
            'status' => 'ditolak',
            'rejection_reason' => $reason,
        ]);

        // Cari user pemohon jika user_id kosong
        $targetUserId = $loan->user_id;
        if (empty($targetUserId)) {
            $userMatch = User::where('name', 'like', "%{$loan->borrower_name}%")->first();
            if ($userMatch) {
                $targetUserId = $userMatch->id;
                $loan->update(['user_id' => $targetUserId]);
            } else {
                $pegawai = User::whereIn('role', ['pegawai', 'user'])->whereNotNull('fcm_token')->first();
                if ($pegawai) {
                    $targetUserId = $pegawai->id;
                    $loan->update(['user_id' => $targetUserId]);
                }
            }
        }

        // Notifikasi ke pemohon di DB
        AppNotification::create([
            'user_id' => $targetUserId,
            'title' => 'Pengajuan Tidak Disetujui',
            'message' => "Permohonan {$loan->vehicle_name} ({$loan->id}) ditolak: {$reason}",
            'reference_number' => $loan->id,
            'type' => 'rejected',
            'is_read' => false,
        ]);

        // Push Notifikasi Firebase ke Pemohon
        try {
            if (!empty($targetUserId)) {
                FirebaseService::sendToUser(
                    $targetUserId,
                    'Pengajuan Tidak Disetujui',
                    "Permohonan {$loan->vehicle_name} ({$loan->id}) ditolak: {$reason}",
                    ['type' => 'rejected', 'loan_id' => (string)$loan->id, 'reason' => (string)$reason]
                );
            } else {
                $usersWithFcm = User::whereNotNull('fcm_token')->whereNotIn('role', ['admin', 'superadmin'])->get();
                foreach ($usersWithFcm as $u) {
                    FirebaseService::sendToUser(
                        $u->id,
                        'Pengajuan Tidak Disetujui',
                        "Permohonan {$loan->vehicle_name} ({$loan->id}) ditolak: {$reason}",
                        ['type' => 'rejected', 'loan_id' => (string)$loan->id, 'reason' => (string)$reason]
                    );
                }
            }
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::warning("FCM reject notification error: " . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Permohonan berhasil ditolak.',
            'data' => $loan,
        ]);
    }

    public function start(Request $request, $id)
    {
        $loan = Loan::findOrFail($id);

        $loan->update([
            'status' => 'digunakan',
        ]);

        $vehicle = Vehicle::find($loan->vehicle_id);
        if ($vehicle) {
            $vehicle->update(['status' => 'digunakan']);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Kendaraan telah mulai digunakan.',
            'data' => $loan,
        ]);
    }

    public function complete(Request $request, $id)
    {
        $loan = Loan::findOrFail($id);

        $validated = $request->validate([
            'return_odometer' => 'nullable|integer',
            'return_fuel' => 'nullable|string',
            'return_notes' => 'nullable|string',
        ]);

        $loan->update([
            'status' => 'selesai',
            'return_odometer' => $validated['return_odometer'] ?? $loan->return_odometer,
            'return_fuel' => $validated['return_fuel'] ?? $loan->return_fuel,
            'return_notes' => $validated['return_notes'] ?? $loan->return_notes,
        ]);

        // Update status armada kembali tersedia
        $vehicle = Vehicle::find($loan->vehicle_id);
        if ($vehicle) {
            $vehicle->update(['status' => 'tersedia']);
        }

        // Cari user pemohon jika user_id kosong
        $targetUserId = $loan->user_id;
        if (empty($targetUserId)) {
            $userMatch = User::where('name', 'like', "%{$loan->borrower_name}%")->first();
            if ($userMatch) {
                $targetUserId = $userMatch->id;
                $loan->update(['user_id' => $targetUserId]);
            } else {
                $pegawai = User::whereIn('role', ['pegawai', 'user'])->whereNotNull('fcm_token')->first();
                if ($pegawai) $targetUserId = $pegawai->id;
            }
        }

        // Notifikasi BAST Selesai di DB
        AppNotification::create([
            'user_id' => $targetUserId,
            'title' => 'Peminjaman Selesai (BAST Terbit)',
            'message' => "Unit {$loan->vehicle_name} telah selesai digunakan dan dikembalikan ke pool kendaraan. Terima kasih.",
            'reference_number' => $loan->id,
            'type' => 'returned',
            'is_read' => false,
        ]);

        // Push Notifikasi Firebase
        try {
            if (!empty($targetUserId)) {
                FirebaseService::sendToUser(
                    $targetUserId,
                    'Peminjaman Selesai (BAST Terbit)',
                    "Unit {$loan->vehicle_name} telah berhasil dikembalikan.",
                    ['type' => 'returned', 'loan_id' => (string)$loan->id]
                );
            }
            FirebaseService::sendToAdmins(
                'Armada Telah Dikembalikan',
                "Unit {$loan->vehicle_name} telah dikembalikan oleh {$loan->borrower_name}.",
                ['type' => 'returned', 'loan_id' => (string)$loan->id]
            );
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::warning("FCM complete notification error: " . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Peminjaman berhasil diselesaikan dan unit telah dikembalikan.',
            'data' => $loan,
        ]);
    }

    public function cancel(Request $request, $id)
    {
        $loan = Loan::findOrFail($id);

        $loan->update([
            'status' => 'dibatalkan',
        ]);

        // Jika status kendaraan sebelumnya digunakan karena loan ini, kembalikan ke tersedia
        $vehicle = Vehicle::find($loan->vehicle_id);
        if ($vehicle && $vehicle->status === 'digunakan') {
            $vehicle->update(['status' => 'tersedia']);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Peminjaman berhasil dibatalkan.',
            'data' => $loan,
        ]);
    }
}
