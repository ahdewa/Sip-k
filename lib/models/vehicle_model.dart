enum VehicleType { mobil, motor }

enum VehicleStatus { tersedia, digunakan, pemeliharaan }

class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String plateNumber;
  final String color;
  final VehicleType type;
  final int capacity;
  final String transmission;
  int currentOdometer;
  final int fuelPercent; // 0 - 100
  final String fuelType; // Pertalite, Pertamax, Dexlite, Solar
  final String conditionNote;
  final String imageUrl; // Gambar cover utama
  final List<String>
  galleryImages; // Galeri foto tambahan (bebas diubah/ditambah)
  VehicleStatus status;
  final String? chassisNumber; // Nomor Rangka (VIN)
  final String? engineNumber; // Nomor Mesin

  Vehicle({
    required this.id,
    required this.name,
    required this.brand,
    required this.plateNumber,
    required this.color,
    required this.type,
    required this.capacity,
    required this.transmission,
    required this.currentOdometer,
    required this.fuelPercent,
    required this.fuelType,
    required this.conditionNote,
    required this.imageUrl,
    this.galleryImages = const [],
    this.status = VehicleStatus.tersedia,
    this.chassisNumber,
    this.engineNumber,
  });

  String get fuelDisplay =>
      fuelPercent >= 100 ? 'Full (100%)' : '$fuelPercent%';

  String get chassisNumberDisplay {
    if (chassisNumber != null && chassisNumber!.trim().isNotEmpty) {
      return chassisNumber!;
    }
    final p = plateNumber.replaceAll(' ', '');
    return type == VehicleType.mobil ? 'MH1$p-KD$id' : 'MH3$p-JB$id';
  }

  String get engineNumberDisplay {
    if (engineNumber != null && engineNumber!.trim().isNotEmpty) {
      return engineNumber!;
    }
    final p = plateNumber.replaceAll(' ', '');
    return type == VehicleType.mobil ? '2KD-$p-$id' : 'JB51E-$p-$id';
  }

  // Mengembalikan semua foto armada yang tersedia untuk digeser oleh user di katalog
  List<String> get allImages {
    final availableImages = <String>[
      if (imageUrl.trim().isNotEmpty) imageUrl.trim(),
      ...galleryImages.where(
        (image) => image.trim().isNotEmpty && image.trim() != imageUrl.trim(),
      ),
    ];

    if (availableImages.isEmpty) {
      return const ['assets/images/logo_sipk.png'];
    }

    return availableImages;
  }
}
