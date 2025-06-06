import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import 'auth_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookings';
  final AuthService _authService = AuthService();

  // Simpan data booking ke Firestore
  Future<Booking> saveBooking(Booking booking) async {
    try {
      // Pastikan user sudah login
      if (_authService.currentUser == null) {
        throw Exception('User not logged in');
      }

      // Buat booking baru dengan user ID dari user yang sedang login
      Booking bookingWithUserId = Booking(
        userId: _authService.currentUser!.id, // Set user ID dari current user
        nama: booking.nama,
        noHp: booking.noHp,
        ruangan: booking.ruangan,
        tanggalMulai: booking.tanggalMulai,
        tanggalSelesai: booking.tanggalSelesai,
        jamMulai: booking.jamMulai,
        jamSelesai: booking.jamSelesai,
        tujuan: booking.tujuan,
        organisasi: booking.organisasi,
        status: booking.status,
      );

      // Tambahkan dokumen baru ke koleksi bookings
      DocumentReference docRef = await _firestore.collection(_collection).add(bookingWithUserId.toMap());

      // Dapatkan ID dokumen yang baru saja dibuat
      String newId = docRef.id;

      // Buat objek Booking baru dengan ID dari Firestore
      return Booking(
        id: newId,
        userId: bookingWithUserId.userId,
        nama: bookingWithUserId.nama,
        noHp: bookingWithUserId.noHp,
        ruangan: bookingWithUserId.ruangan,
        tanggalMulai: bookingWithUserId.tanggalMulai,
        tanggalSelesai: bookingWithUserId.tanggalSelesai,
        jamMulai: bookingWithUserId.jamMulai,
        jamSelesai: bookingWithUserId.jamSelesai,
        tujuan: bookingWithUserId.tujuan,
        organisasi: bookingWithUserId.organisasi,
        status: bookingWithUserId.status,
      );
    } catch (e) {
      print('Error menyimpan booking: $e');
      rethrow;
    }
  }

  // Dapatkan semua booking
  Stream<List<Booking>> getBookings() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true) // Urutkan berdasarkan waktu pembuatan
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // ===== NEW METHOD: Dapatkan hanya booking yang approved =====
  Stream<List<Booking>> getApprovedBookings() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // ===== NEW METHOD: Dapatkan approved bookings untuk tanggal tertentu =====
  Future<List<Map<String, dynamic>>> getApprovedBookingsForDate(DateTime date) async {
    try {
      String dateString = DateFormat('dd/MM/yyyy').format(date);

      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'approved')
          .where('tanggalMulai', isEqualTo: dateString)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting approved bookings for date: $e');
      return [];
    }
  }

  // ===== NEW METHOD: Dapatkan semua bookings untuk admin =====
  Stream<List<Booking>> getAllBookingsForAdmin() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Dapatkan booking berdasarkan ID
  Future<Booking?> getBookingById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error mengambil booking: $e');
      rethrow;
    }
  }

  // Dapatkan booking berdasarkan nama pengguna (untuk backward compatibility)
  Stream<List<Booking>> getBookingsByUser(String nama) {
    return _firestore
        .collection(_collection)
        .where('nama', isEqualTo: nama)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Dapatkan booking berdasarkan user ID
  Stream<List<Booking>> getBookingsByUserId(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
    // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Dapatkan booking untuk current user yang sedang login
  Stream<List<Booking>> getCurrentUserBookings() {
    if (_authService.currentUser == null) {
      // Return empty stream if no user is logged in
      return Stream.value([]);
    }
    return getBookingsByUserId(_authService.currentUser!.id);
  }

  // Update status booking
  Future<void> updateBookingStatus(String id, String status) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error update status booking: $e');
      rethrow;
    }
  }

  // Hapus booking
  Future<void> deleteBooking(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error menghapus booking: $e');
      rethrow;
    }
  }
}
