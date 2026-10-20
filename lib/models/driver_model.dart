import 'package:flutter/material.dart';

enum DriverStatus {
  siaga,
  bertugas,
  cuti,
  nonaktif,
}

extension DriverStatusX on DriverStatus {
  String get label {
    switch (this) {
      case DriverStatus.siaga:
        return 'Siaga';
      case DriverStatus.bertugas:
        return 'Bertugas';
      case DriverStatus.cuti:
        return 'Cuti';
      case DriverStatus.nonaktif:
        return 'Nonaktif';
    }
  }

  Color get color {
    switch (this) {
      case DriverStatus.siaga:
        return const Color(0xFF16A34A);
      case DriverStatus.bertugas:
        return const Color(0xFFD97706);
      case DriverStatus.cuti:
        return const Color(0xFF2563EB);
      case DriverStatus.nonaktif:
        return const Color(0xFF64748B);
    }
  }
}

class Driver {
  final String id;
  String name;
  String nip;
  String phone;
  String simType;
  String simNumber;
  DriverStatus status;
  String notes;
  String? photoUrl;

  Driver({
    required this.id,
    required this.name,
    this.nip = '',
    this.phone = '',
    this.simType = 'SIM A',
    this.simNumber = '',
    this.status = DriverStatus.siaga,
    this.notes = '',
    this.photoUrl,
  });

  bool get isAvailable => status == DriverStatus.siaga;

  String get statusLabel {
    switch (status) {
      case DriverStatus.siaga:
        return 'Siaga';
      case DriverStatus.bertugas:
        return 'Bertugas';
      case DriverStatus.cuti:
        return 'Cuti';
      case DriverStatus.nonaktif:
        return 'Nonaktif';
    }
  }

  Color get statusColor {
    switch (status) {
      case DriverStatus.siaga:
        return const Color(0xFF16A34A); // Hijau
      case DriverStatus.bertugas:
        return const Color(0xFF2563EB); // Biru
      case DriverStatus.cuti:
        return const Color(0xFFD97706); // Kuning/Oranye
      case DriverStatus.nonaktif:
        return const Color(0xFF64748B); // Abu-abu
    }
  }

  String get detailDisplay {
    final parts = <String>[];
    if (notes.isNotEmpty) {
      parts.add(notes);
    } else {
      parts.add('Driver Operasional');
      parts.add(simType);
      parts.add(statusLabel);
    }
    return parts.join(' • ');
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nip: json['nip']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      simType: json['sim_type']?.toString() ?? 'SIM A',
      simNumber: json['sim_number']?.toString() ?? '',
      status: _parseStatus(json['status']),
      notes: json['notes']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nip': nip,
      'phone': phone,
      'sim_type': simType,
      'sim_number': simNumber,
      'status': status.name,
      'notes': notes,
      'photo_url': photoUrl,
    };
  }

  Driver copyWith({
    String? id,
    String? name,
    String? nip,
    String? phone,
    String? simType,
    String? simNumber,
    DriverStatus? status,
    String? notes,
    String? photoUrl,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      nip: nip ?? this.nip,
      phone: phone ?? this.phone,
      simType: simType ?? this.simType,
      simNumber: simNumber ?? this.simNumber,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  static DriverStatus _parseStatus(dynamic val) {
    final s = val?.toString().toLowerCase().trim() ?? '';
    switch (s) {
      case 'bertugas':
        return DriverStatus.bertugas;
      case 'cuti':
        return DriverStatus.cuti;
      case 'nonaktif':
        return DriverStatus.nonaktif;
      default:
        return DriverStatus.siaga;
    }
  }
}
