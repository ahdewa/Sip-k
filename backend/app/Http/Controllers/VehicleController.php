<?php

namespace App\Http\Controllers;

use App\Models\Vehicle;
use Illuminate\Http\Request;

class VehicleController extends Controller
{
    public function index(Request $request)
    {
        $query = Vehicle::query();

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('plate_number', 'like', "%{$search}%")
                  ->orWhere('brand', 'like', "%{$search}%");
            });
        }

        $vehicles = $query->orderBy('name')->get();

        return response()->json([
            'status' => 'success',
            'data' => $vehicles,
        ]);
    }

    public function show($id)
    {
        $vehicle = Vehicle::findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $vehicle,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'brand' => 'required|string|max:100',
            'plate_number' => 'required|string|max:50',
            'color' => 'required|string|max:50',
            'type' => 'required|in:mobil,motor',
            'capacity' => 'required|integer',
            'transmission' => 'required|string|max:50',
            'current_odometer' => 'nullable|integer',
            'fuel_percent' => 'nullable|integer',
            'fuel_type' => 'nullable|string|max:100',
            'condition_note' => 'nullable|string',
            'status' => 'nullable|in:tersedia,digunakan,perawatan',
            'image_url' => 'nullable|string',
            'gallery_images' => 'nullable|array',
        ]);

        $vehicle = Vehicle::create($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Armada berhasil ditambahkan.',
            'data' => $vehicle,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $vehicle = Vehicle::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'brand' => 'sometimes|required|string|max:100',
            'plate_number' => 'sometimes|required|string|max:50',
            'color' => 'sometimes|required|string|max:50',
            'type' => 'sometimes|required|in:mobil,motor',
            'capacity' => 'sometimes|required|integer',
            'transmission' => 'sometimes|required|string|max:50',
            'current_odometer' => 'nullable|integer',
            'fuel_percent' => 'nullable|integer',
            'fuel_type' => 'nullable|string|max:100',
            'condition_note' => 'nullable|string',
            'status' => 'nullable|in:tersedia,digunakan,perawatan',
            'image_url' => 'nullable|string',
            'gallery_images' => 'nullable|array',
        ]);

        $vehicle->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Armada berhasil diperbarui.',
            'data' => $vehicle,
        ]);
    }

    public function destroy($id)
    {
        $vehicle = Vehicle::findOrFail($id);
        $vehicle->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Armada berhasil dihapus.',
        ]);
    }
}