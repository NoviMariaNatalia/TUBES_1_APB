import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes1_apb/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookings';

  // Simpan data booking ke Firestore
  Future<Booking> saveBooking(Booking booking) async {
    try {
      // Tambahkan dokumen baru ke koleksi bookings
      DocumentReference docRef = await _firestore.collection(_collection).add(booking.toMap());

      // Dapatkan ID dokumen yang baru saja dibuat
      String newId = docRef.id;

      // Buat objek Booking baru dengan ID dari Firestore
      return Booking(
        id: newId,
        nama: booking.nama,
        noHp: booking.noHp,
        ruangan: booking.ruangan,
        tanggalMulai: booking.tanggalMulai,
        tanggalSelesai: booking.tanggalSelesai,
        jamMulai: booking.jamMulai,
        jamSelesai: booking.jamSelesai,
        tujuan: booking.tujuan,
        organisasi: booking.organisasi,
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

  // Dapatkan booking berdasarkan nama pengguna
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

  // Update status booking
  Future<void> updateBookingStatus(String id, String status) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'status': status,
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