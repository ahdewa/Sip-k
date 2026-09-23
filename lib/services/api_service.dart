import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/notification_model.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/services/api_config.dart';

class ApiService {
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (ApiConfig.authToken != null) {
      headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';
    }
    return headers;
  }

  // ─── AUTHENTICATION ─────────────────────────────────────────

  static Future<Map<String, dynamic>?> login({
    required String loginInput,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/login');
      final payload = <String, dynamic>{
        'email': loginInput,
        'password': password,
      };
      if (fcmToken != null) payload['fcm_token'] = fcmToken;

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'success') {
          final data = body['data'];
          final token = data['token'] as String?;
          ApiConfig.authToken = token;

          final u = data['user'];
          final roleStr = (u['role'] ?? 'pegawai').toString();
          final userRole = roleStr == 'superadmin'
              ? UserRole.superadmin
              : (roleStr == 'admin' ? UserRole.admin : UserRole.user);

          final appUser = AppUser(
            id: u['id'].toString(),
            name: u['name'] ?? '',
            nip: u['nip'] ?? '',
            department: u['department'] ?? '',
            email: u['email'] ?? '',
            role: userRole,
          );

          final userProfile = UserProfile(
            name: u['name'] ?? '',
            nip: u['nip'] ?? '',
            position: u['position'] ?? 'Staf Pegawai',
            department: u['department'] ?? '',
            email: u['email'] ?? '',
            phone: u['phone'] ?? '0812-3456-7890',
            profileImageUrl: u['profile_image_url'],
          );

          ApiConfig.currentUserId = u['id'].toString();
          ApiConfig.currentUserProfile = userProfile;

          return {
            'user': appUser,
            'profile': userProfile,
            'role': roleStr,
            'token': token,
          };
        }
      }
    } catch (e) {
      debugPrint('ApiService.login error: $e');
    }
    return null;
  }

  // ─── VEHICLES ────────────────────────────────────────────────

  static Future<List<Vehicle>?> fetchVehicles() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/vehicles');
      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'success') {
          final list = body['data'] as List;
          return list.map((item) {
            final typeStr = (item['type'] ?? 'mobil').toString();
            final statusStr = (item['status'] ?? 'tersedia').toString();

            VehicleStatus vStatus;
            if (statusStr == 'digunakan') {
              vStatus = VehicleStatus.digunakan;
            } else if (statusStr == 'perawatan') {
              vStatus = VehicleStatus.pemeliharaan;
            } else {
              vStatus = VehicleStatus.tersedia;
            }

            return Vehicle(
              id: item['id'].toString(),
              name: item['name'] ?? '',
              brand: item['brand'] ?? '',
              plateNumber: item['plate_number'] ?? '',
              color: item['color'] ?? '',
              type: typeStr == 'motor' ? VehicleType.motor : VehicleType.mobil,
              capacity: int.tryParse(item['capacity'].toString()) ?? 4,
              transmission: item['transmission'] ?? 'Manual',
              currentOdometer: int.tryParse(item['current_odometer'].toString()) ?? 0,
              fuelPercent: int.tryParse(item['fuel_percent'].toString()) ?? 100,
              fuelType: item['fuel_type'] ?? 'Bensin',
              conditionNote: item['condition_note'] ?? '',
              imageUrl: item['image_url'] ?? 'assets/images/logo_sipk.png',
              galleryImages: (item['gallery_images'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  const ['assets/images/logo_sipk.png'],
              status: vStatus,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService.fetchVehicles error: $e');
    }
    return null;
  }

  static Future<bool> createVehicle(Vehicle vehicle) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/vehicles');
      String statusStr = 'tersedia';
      if (vehicle.status == VehicleStatus.digunakan) {
        statusStr = 'digunakan';
      } else if (vehicle.status == VehicleStatus.pemeliharaan) {
        statusStr = 'perawatan';
      }

      final payload = <String, dynamic>{
        'name': vehicle.name,
        'brand': vehicle.brand,
        'plate_number': vehicle.plateNumber,
        'color': vehicle.color,
        'type': vehicle.type == VehicleType.motor ? 'motor' : 'mobil',
        'capacity': vehicle.capacity,
        'transmission': vehicle.transmission,
        'current_odometer': vehicle.currentOdometer,
        'fuel_percent': vehicle.fuelPercent,
        'fuel_type': vehicle.fuelType,
        'condition_note': vehicle.conditionNote,
        'status': statusStr,
        'image_url': vehicle.imageUrl,
      };

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('ApiService.createVehicle error: $e');
      return false;
    }
  }

  static Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/vehicles/${vehicle.id}');
      String statusStr = 'tersedia';
      if (vehicle.status == VehicleStatus.digunakan) {
        statusStr = 'digunakan';
      } else if (vehicle.status == VehicleStatus.pemeliharaan) {
        statusStr = 'perawatan';
      }

      final payload = <String, dynamic>{
        'name': vehicle.name,
        'brand': vehicle.brand,
        'plate_number': vehicle.plateNumber,
        'color': vehicle.color,
        'type': vehicle.type == VehicleType.motor ? 'motor' : 'mobil',
        'capacity': vehicle.capacity,
        'transmission': vehicle.transmission,
        'current_odometer': vehicle.currentOdometer,
        'fuel_percent': vehicle.fuelPercent,
        'fuel_type': vehicle.fuelType,
        'condition_note': vehicle.conditionNote,
        'status': statusStr,
        'image_url': vehicle.imageUrl,
      };

      final res = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.updateVehicle error: $e');
      return false;
    }
  }

  static Future<bool> deleteVehicle(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/vehicles/$id');
      final res = await http.delete(url, headers: _headers);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.deleteVehicle error: $e');
      return false;
    }
  }

  // ─── LOANS ───────────────────────────────────────────────────

  static LoanStatus _parseLoanStatus(String? status) {
    switch (status) {
      case 'disetujui':
      case 'approved':
        return LoanStatus.disetujui;
      case 'digunakan':
        return LoanStatus.digunakan;
      case 'ditolak':
      case 'rejected':
        return LoanStatus.ditolak;
      case 'dibatalkan':
        return LoanStatus.dibatalkan;
      case 'selesai':
        return LoanStatus.selesai;
      default:
        return LoanStatus.menunggu;
    }
  }

  static Future<List<LoanRequest>?> fetchLoans() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/loans');
      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'success') {
          final list = body['data'] as List;
          return list.map((item) {
            return LoanRequest(
              id: item['id'].toString(),
              borrowerName: item['borrower_name'] ?? '',
              department: item['department'] ?? '',
              vehicleId: item['vehicle_id'].toString(),
              vehicleName: item['vehicle_name'] ?? '',
              destination: item['destination'] ?? '',
              destinationAddress: item['destination_address'] ?? '',
              purposeDescription: item['purpose_description'] ?? '',
              startDate: DateTime.tryParse(item['start_date'] ?? '') ?? DateTime.now(),
              endDate: DateTime.tryParse(item['end_date'] ?? '') ?? DateTime.now(),
              officialNoteNumber: item['official_note_number'] ?? '-',
              simPhotoPath: item['sim_photo_path'],
              status: _parseLoanStatus(item['status']),
              submittedAt: DateTime.tryParse(item['submitted_at'] ?? '') ?? DateTime.now(),
              spkNumber: item['spk_number'],
              returnOdometer: item['return_odometer'],
              returnFuel: item['return_fuel'],
              returnNotes: item['return_notes'],
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService.fetchLoans error: $e');
    }
    return null;
  }

  static Future<bool> createLoan(LoanRequest loan) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/loans');
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'id': loan.id,
          'user_id': ApiConfig.currentUserId,
          'borrower_name': loan.borrowerName,
          'department': loan.department,
          'vehicle_id': loan.vehicleId,
          'vehicle_name': loan.vehicleName,
          'destination': loan.destination,
          'destination_address': loan.destinationAddress,
          'purpose_description': loan.purposeDescription,
          'start_date': loan.startDate.toIso8601String(),
          'end_date': loan.endDate.toIso8601String(),
          'official_note_number': loan.officialNoteNumber,
          'sim_photo_path': loan.simPhotoPath,
        }),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('ApiService.createLoan error: $e');
      return false;
    }
  }

  static Future<bool> approveLoan(String loanId, {String? spkNumber}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/loans/$loanId/approve');
      final payload = <String, dynamic>{};
      if (spkNumber != null) payload['spk_number'] = spkNumber;

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.approveLoan error: $e');
      return false;
    }
  }

  static Future<bool> rejectLoan(String loanId, {String? reason}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/loans/$loanId/reject');
      final payload = <String, dynamic>{};
      if (reason != null) payload['rejection_reason'] = reason;

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.rejectLoan error: $e');
      return false;
    }
  }

  static Future<bool> startLoan(String loanId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/loans/$loanId/start');
      final res = await http.post(url, headers: _headers);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.startLoan error: $e');
      return false;
    }
  }

  static Future<bool> completeLoan(
    String loanId, {
    int? returnOdometer,
    String? returnFuel,
    String? returnNotes,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/loans/$loanId/complete');
      final payload = <String, dynamic>{};
      if (returnOdometer != null) payload['return_odometer'] = returnOdometer;
      if (returnFuel != null) payload['return_fuel'] = returnFuel;
      if (returnNotes != null) payload['return_notes'] = returnNotes;

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.completeLoan error: $e');
      return false;
    }
  }

  static Future<bool> cancelLoan(String loanId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/loans/$loanId/cancel');
      final res = await http.post(url, headers: _headers);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.cancelLoan error: $e');
      return false;
    }
  }

  // ─── NOTIFICATIONS ───────────────────────────────────────────

  static Future<List<AppNotification>?> fetchNotifications({
    String? userId,
    String? role,
  }) async {
    try {
      final queryParams = <String, String>{};
      final uid = userId ?? ApiConfig.currentUserId;
      if (uid != null) queryParams['user_id'] = uid;
      if (role != null) queryParams['role'] = role;

      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'success') {
          final list = body['data'] as List;
          return list.map((item) {
            final typeStr = (item['type'] ?? 'submitted').toString();
            NotificationType nType;
            switch (typeStr) {
              case 'approved':
                nType = NotificationType.approved;
                break;
              case 'rejected':
                nType = NotificationType.rejected;
                break;
              case 'maintenance':
                nType = NotificationType.maintenance;
                break;
              case 'reminder':
                nType = NotificationType.reminder;
                break;
              case 'welcome':
                nType = NotificationType.welcome;
                break;
              default:
                nType = NotificationType.submitted;
            }

            final parsedDt = DateTime.tryParse(item['created_at'] ?? '');
            final dt = parsedDt != null ? parsedDt.toLocal() : DateTime.now();
            final hourStr = dt.hour.toString().padLeft(2, '0');
            final minStr = dt.minute.toString().padLeft(2, '0');
            final dayStr = dt.day.toString().padLeft(2, '0');
            final monthStr = dt.month.toString().padLeft(2, '0');

            return AppNotification(
              id: item['id'].toString(),
              title: item['title'] ?? '',
              message: item['message'] ?? '',
              time: '$hourStr:$minStr WIB',
              fullDate: '$dayStr/$monthStr/${dt.year} $hourStr:$minStr WIB',
              detailContent: item['message'] ?? '',
              referenceNumber: item['reference_number'] ?? '-',
              createdAt: dt,
              type: nType,
              isRead: item['is_read'] == true || item['is_read'] == 1,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService.fetchNotifications error: $e');
    }
    return null;
  }

  static Future<bool> markNotificationRead(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read');
      final res = await http.post(url, headers: _headers);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> markAllNotificationsRead({String? userId, String? role}) async {
    try {
      final queryParams = <String, String>{};
      final uid = userId ?? ApiConfig.currentUserId;
      if (uid != null) queryParams['user_id'] = uid;
      if (role != null) queryParams['role'] = role;

      final uri = Uri.parse('${ApiConfig.baseUrl}/notifications/read-all')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final res = await http.post(uri, headers: _headers);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── USERS ───────────────────────────────────────────────────

  static Future<List<AppUser>?> fetchUsers() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/users');
      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'success') {
          final list = body['data'] as List;
          return list.map((item) {
            final roleStr = (item['role'] ?? 'pegawai').toString();
            UserRole uRole;
            if (roleStr == 'superadmin') {
              uRole = UserRole.superadmin;
            } else if (roleStr == 'admin') {
              uRole = UserRole.admin;
            } else {
              uRole = UserRole.user;
            }

            return AppUser(
              id: item['id'].toString(),
              name: item['name'] ?? '',
              nip: item['nip'] ?? '',
              email: item['email'] ?? '',
              department: item['department'] ?? 'Dinas Sosial Jawa Timur',
              role: uRole,
              username: (item['email'] ?? '').toString().split('@').first,
              isActive: true,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService.fetchUsers error: $e');
    }
    return null;
  }

  static Future<bool> createUser(AppUser user, {String? password}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/users');
      String roleStr = 'pegawai';
      if (user.role == UserRole.superadmin) {
        roleStr = 'superadmin';
      } else if (user.role == UserRole.admin) {
        roleStr = 'admin';
      }

      final payload = <String, dynamic>{
        'name': user.name,
        'nip': user.nip,
        'email': user.email,
        'department': user.department,
        'role': roleStr,
      };
      if (password != null && password.isNotEmpty) {
        payload['password'] = password;
      }

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('ApiService.createUser error: $e');
      return false;
    }
  }

  static Future<bool> updateUser(AppUser user) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/users/${user.id}');
      String roleStr = 'pegawai';
      if (user.role == UserRole.superadmin) {
        roleStr = 'superadmin';
      } else if (user.role == UserRole.admin) {
        roleStr = 'admin';
      }

      final payload = <String, dynamic>{
        'name': user.name,
        'nip': user.nip,
        'email': user.email,
        'department': user.department,
        'role': roleStr,
      };

      final res = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.updateUser error: $e');
      return false;
    }
  }

  static Future<bool> deleteUser(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');
      final res = await http.delete(url, headers: _headers);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.deleteUser error: $e');
      return false;
    }
  }

  static Future<bool> updateProfile(UserProfile profile) async {
    try {
      final id = ApiConfig.currentUserId ?? '1';
      final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');
      final payload = <String, dynamic>{
        'name': profile.name,
        'nip': profile.nip,
        'email': profile.email,
        'department': profile.department,
        'position': profile.position,
        'phone': profile.phone,
        'profile_image_url': profile.profileImageUrl,
      };

      final res = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        ApiConfig.currentUserProfile = profile;
        return true;
      }
    } catch (e) {
      debugPrint('ApiService.updateProfile error: $e');
    }
    return false;
  }

  static Future<UserProfile?> fetchCurrentProfile() async {
    try {
      final id = ApiConfig.currentUserId ?? '1';
      final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');
      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['status'] == 'success' && body['data'] != null) {
          final u = body['data'];
          final profile = UserProfile(
            name: u['name'] ?? '',
            nip: u['nip'] ?? '',
            position: u['position'] ?? 'Staf Pelaksana',
            department: u['department'] ?? 'Dinas Sosial Jawa Timur',
            email: u['email'] ?? '',
            phone: u['phone'] ?? '0812-3456-7890',
            profileImageUrl: u['profile_image_url'],
          );
          ApiConfig.currentUserProfile = profile;
          return profile;
        }
      }
    } catch (e) {
      debugPrint('ApiService.fetchCurrentProfile error: $e');
    }
    return null;
  }

  static Future<bool> updateFcmToken(String fcmToken) async {
    try {
      final userId = ApiConfig.currentUserId;
      final url = Uri.parse('${ApiConfig.baseUrl}/fcm-token');
      final Map<String, dynamic> payload = {'fcm_token': fcmToken};
      if (userId != null) {
        payload['user_id'] = userId;
      }
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.updateFcmToken error: $e');
    }
    return false;
  }
}
