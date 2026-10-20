<?php

namespace App\Http\Controllers;

use App\Models\Driver;
use Illuminate\Http\Request;

class DriverController extends Controller
{
    public function index(Request $request)
    {
        $query = Driver::query();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('nip', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%")
                  ->orWhere('sim_type', 'like', "%{$search}%")
                  ->orWhere('notes', 'like', "%{$search}%");
            });
        }

        $drivers = $query->orderByRaw("FIELD(status, 'siaga', 'bertugas', 'cuti', 'nonaktif')")
                         ->orderBy('name')
                         ->get();

        return response()->json([
            'status' => 'success',
            'data' => $drivers,
        ]);
    }

    public function show($id)
    {
        $driver = Driver::findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $driver,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'nip' => 'nullable|string|max:50',
            'phone' => 'nullable|string|max:30',
            'sim_type' => 'required|string|max:50',
            'sim_number' => 'nullable|string|max:50',
            'status' => 'required|string|in:siaga,bertugas,cuti,nonaktif',
            'notes' => 'nullable|string|max:500',
            'photo_url' => 'nullable|string',
        ]);

        $driver = Driver::create($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Data driver berhasil ditambahkan.',
            'data' => $driver,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $driver = Driver::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'nip' => 'nullable|string|max:50',
            'phone' => 'nullable|string|max:30',
            'sim_type' => 'sometimes|required|string|max:50',
            'sim_number' => 'nullable|string|max:50',
            'status' => 'sometimes|required|string|in:siaga,bertugas,cuti,nonaktif',
            'notes' => 'nullable|string|max:500',
            'photo_url' => 'nullable|string',
        ]);

        $driver->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Data driver berhasil diperbarui.',
            'data' => $driver,
        ]);
    }

    public function destroy($id)
    {
        $driver = Driver::findOrFail($id);
        $driver->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Data driver berhasil dihapus.',
        ]);
    }
}
