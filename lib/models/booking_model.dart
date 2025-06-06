import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String nama;
  final String noHp;
  final String ruangan;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String jamMulai;
  final String jamSelesai;
  final String tujuan;
  final String organisasi;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    this.id = '',
    required this.userId,
    required this.nama,
    required this.noHp,
    required this.ruangan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.jamMulai,
    required this.jamSelesai,
    required this.tujuan,
    required this.organisasi,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  // Metode untuk mengubah Booking menjadi Map (untuk dikirim ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nama': nama,
      'noHp': noHp,
      'ruangan': ruangan,
      'tanggalMulai': tanggalMulai,
      'tanggalSelesai': tanggalSelesai,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'tujuan': tujuan,
      'organisasi': organisasi,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ===== FIXED: Method untuk membuat Booking dari Map dengan proper type handling =====
  factory Booking.fromMap(Map<String, dynamic> map, String documentId) {
    return Booking(
      id: documentId,
      userId: map['userId'] ?? '',
      nama: map['nama'] ?? '',
      noHp: map['noHp'] ?? '',
      ruangan: map['ruangan'] ?? '',
      tanggalMulai: map['tanggalMulai'] ?? '',
      tanggalSelesai: map['tanggalSelesai'] ?? '',
      jamMulai: map['jamMulai'] ?? '',
      jamSelesai: map['jamSelesai'] ?? '',
      tujuan: map['tujuan'] ?? '',
      organisasi: map['organisasi'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  // ===== NEW: Helper method untuk parsing DateTime dari berbagai format =====
  static DateTime? _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue == null) {
        return null;
      }

      // Jika sudah DateTime
      if (dateValue is DateTime) {
        return dateValue;
      }

      // Jika Timestamp dari Firestore
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      }

      // Jika String ISO format
      if (dateValue is String) {
        if (dateValue.isEmpty) return null;
        return DateTime.parse(dateValue);
      }

      // Jika Map dengan seconds dan nanoseconds (Firestore Timestamp format)
      if (dateValue is Map) {
        if (dateValue.containsKey('_seconds')) {
          int seconds = dateValue['_seconds'] ?? 0;
          int nanoseconds = dateValue['_nanoseconds'] ?? 0;
          return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds / 1000000).round(),
          );
        }
      }

      print('⚠️ Unknown date format: ${dateValue.runtimeType} - $dateValue');
      return null;

    } catch (e) {
      print('❌ Error parsing date: $e (Value: $dateValue)');
      return null;
    }
  }

  // ===== NEW: Helper method untuk debugging =====
  void debugPrint() {
    print('📋 Booking Debug Info:');
    print('   ID: $id');
    print('   User ID: $userId');
    print('   Nama: $nama');
    print('   Ruangan: $ruangan');
    print('   Tanggal: $tanggalMulai - $tanggalSelesai');
    print('   Jam: $jamMulai - $jamSelesai');
    print('   Status: $status');
    print('   Created: $createdAt');
    print('   Updated: $updatedAt');
  }

  // ===== NEW: Copy with method untuk update =====
  Booking copyWith({
    String? id,
    String? userId,
    String? nama,
    String? noHp,
    String? ruangan,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? jamMulai,
    String? jamSelesai,
    String? tujuan,
    String? organisasi,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      noHp: noHp ?? this.noHp,
      ruangan: ruangan ?? this.ruangan,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
      tujuan: tujuan ?? this.tujuan,
      organisasi: organisasi ?? this.organisasi,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ===== NEW: Method untuk validasi =====
  bool isValid() {
    return userId.isNotEmpty &&
        nama.isNotEmpty &&
        noHp.isNotEmpty &&
        ruangan.isNotEmpty &&
        tanggalMulai.isNotEmpty &&
        tanggalSelesai.isNotEmpty &&
        jamMulai.isNotEmpty &&
        jamSelesai.isNotEmpty &&
        tujuan.isNotEmpty &&
        organisasi.isNotEmpty;
  }

  // ===== NEW: Format untuk display =====
  String get displayDate {
    if (tanggalMulai == tanggalSelesai) {
      return tanggalMulai;
    }
    return '$tanggalMulai - $tanggalSelesai';
  }

  String get displayTime {
    return '$jamMulai - $jamSelesai';
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
      default:
        return 'Menunggu';
    }
  }
}