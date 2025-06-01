import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId; // NEW: ID user yang membuat booking
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

  Booking({
    this.id = '', // Default kosong, akan diisi dengan ID dokumen Firebase
    required this.userId, // NEW: Required user ID
    required this.nama,
    required this.noHp,
    required this.ruangan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.jamMulai,
    required this.jamSelesai,
    required this.tujuan,
    required this.organisasi,
    this.status = 'pending', // Default status adalah pending
  });

  // Metode untuk mengubah Booking menjadi Map (untuk dikirim ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // NEW: Include user ID
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
      'createdAt': FieldValue.serverTimestamp(), // Tambahkan timestamp
    };
  }

  // Metode untuk membuat Booking dari Map (ketika dibaca dari Firestore)
  factory Booking.fromMap(Map<String, dynamic> map, String documentId) {
    return Booking(
      id: documentId,
      userId: map['userId'] ?? '', // NEW: Get user ID from map
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
    );
  }
}