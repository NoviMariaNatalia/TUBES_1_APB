import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import 'database_helper.dart';
import 'dart:async';

class HybridBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Save booking (SQLite first, then sync to Firebase with timeout)
  Future<Booking> saveBooking(Booking booking) async {
    print('💾 Saving booking to SQLite first...');

    // 1. Save to SQLite first (immediate response)
    String localId = await _saveToSQLite(booking);
    print('✅ Booking saved to SQLite with ID: $localId');

    // 2. Try to sync to Firebase with SHORT timeout (non-blocking)
    _syncToFirebaseAsync(booking, localId);

    return booking;
  }

  /// Save booking ke SQLite
  Future<String> _saveToSQLite(Booking booking) async {
    Map<String, dynamic> bookingData = {
      'nama': booking.nama,
      'no_hp': booking.noHp,
      'ruangan': booking.ruangan,
      'tanggal_mulai': booking.tanggalMulai,
      'tanggal_selesai': booking.tanggalSelesai,
      'jam_mulai': booking.jamMulai,
      'jam_selesai': booking.jamSelesai,
      'tujuan': booking.tujuan,
      'organisasi': booking.organisasi,
      'status': 'pending',
      'is_synced': 0,
      'created_at': DateTime.now().toIso8601String(),
    };

    return await _dbHelper.saveBooking(bookingData);
  }

  /// Async sync to Firebase with timeout (non-blocking)
  void _syncToFirebaseAsync(Booking booking, String localId) async {
    try {
      print('🔄 Attempting Firebase sync...');

      // Set timeout untuk Firebase operations
      String firebaseId = await _syncToFirebase(booking, localId)
          .timeout(const Duration(seconds: 10)); // 10 detik timeout

      print('✅ Booking synced to Firebase with ID: $firebaseId');

    } catch (e) {
      if (e is TimeoutException) {
        print('⏰ Firebase sync timeout - will retry later');
      } else {
        print('❌ Firebase sync failed: $e');
      }
      print('📱 Booking saved locally, will sync when online');
      // Booking tetap tersimpan di SQLite, akan di-sync nanti
    }
  }

  /// Sync booking ke Firebase dengan timeout
  Future<String> _syncToFirebase(Booking booking, String localId) async {
    DocumentReference docRef = await _firestore.collection('bookings').add({
      'nama': booking.nama,
      'noHp': booking.noHp,
      'ruangan': booking.ruangan,
      'tanggalMulai': booking.tanggalMulai,
      'tanggalSelesai': booking.tanggalSelesai,
      'jamMulai': booking.jamMulai,
      'jamSelesai': booking.jamSelesai,
      'tujuan': booking.tujuan,
      'organisasi': booking.organisasi,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 8)); // 8 detik timeout

    // Update SQLite dengan Firebase ID dan mark as synced
    await _dbHelper.markBookingAsSynced(localId, docRef.id);

    return docRef.id;
  }

  /// Get bookings untuk jadwal (offline-first approach)
  Future<List<Map<String, dynamic>>> getBookingsForDate(DateTime date) async {
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    try {
      print('📅 Getting bookings for $formattedDate...');

      // Try Firebase first with short timeout
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('tanggalMulai', isEqualTo: formattedDate)
          .get()
          .timeout(const Duration(seconds: 5)); // 5 detik timeout

      List<Map<String, dynamic>> firebaseBookings = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      print('✅ Loaded ${firebaseBookings.length} bookings from Firebase');
      return firebaseBookings;

    } catch (e) {
      print('🔄 Firebase failed, using SQLite cache...');

      // Fallback to SQLite
      List<Map<String, dynamic>> localBookings = await _dbHelper.getBookingsForDate(formattedDate);
      print('📱 Loaded ${localBookings.length} bookings from SQLite cache');
      return localBookings;
    }
  }

  /// Sync semua booking yang belum ter-sync ke Firebase
  Future<void> syncPendingBookings() async {
    try {
      List<Map<String, dynamic>> unsyncedBookings = await _dbHelper.getUnsyncedBookings();

      if (unsyncedBookings.isEmpty) {
        print('✅ No unsynced bookings found');
        return;
      }

      print('🔄 Found ${unsyncedBookings.length} unsynced bookings');

      for (var bookingData in unsyncedBookings) {
        try {
          // Create Booking object
          Booking booking = Booking(
            nama: bookingData['nama'],
            noHp: bookingData['no_hp'],
            ruangan: bookingData['ruangan'],
            tanggalMulai: bookingData['tanggal_mulai'],
            tanggalSelesai: bookingData['tanggal_selesai'],
            jamMulai: bookingData['jam_mulai'],
            jamSelesai: bookingData['jam_selesai'],
            tujuan: bookingData['tujuan'],
            organisasi: bookingData['organisasi'],
          );

          // Sync to Firebase with timeout
          String firebaseId = await _syncToFirebase(booking, bookingData['id'])
              .timeout(const Duration(seconds: 10));

          print('✅ Synced booking ${bookingData['id']} -> $firebaseId');

        } catch (e) {
          print('❌ Failed to sync booking ${bookingData['id']}: $e');
          // Continue dengan booking lainnya
        }
      }

    } catch (e) {
      print('❌ Error syncing pending bookings: $e');
    }
  }

  /// Validasi konflik booking dengan timeout
  Future<bool> hasBookingConflict({
    required String roomName,
    required DateTime startDate,
    required int startHour,
    required int endHour,
  }) async {
    try {
      List<Map<String, dynamic>> bookings = await getBookingsForDate(startDate);

      for (var booking in bookings) {
        if (booking['ruangan'] == roomName) {
          String jamMulaiKey = booking.containsKey('jamMulai') ? 'jamMulai' : 'jam_mulai';
          String jamSelesaiKey = booking.containsKey('jamSelesai') ? 'jamSelesai' : 'jam_selesai';

          int existingStart = int.parse(booking[jamMulaiKey].split(':')[0]);
          int existingEnd = int.parse(booking[jamSelesaiKey].split(':')[0]);

          // Check overlap
          if (startHour < existingEnd && endHour > existingStart) {
            print('❌ Booking conflict detected');
            return true; // Ada konflik
          }
        }
      }

      print('✅ No booking conflicts');
      return false; // Tidak ada konflik
    } catch (e) {
      print('⚠️ Error checking booking conflict: $e');
      return false; // Allow booking if check fails
    }
  }

  /// Initialize sync saat app start dengan timeout
  Future<void> initializeSync() async {
    print('🔄 Initializing booking sync...');

    try {
      await syncPendingBookings()
          .timeout(const Duration(seconds: 15)); // 15 detik timeout total
      print('✅ Booking sync completed');
    } catch (e) {
      print('⚠️ Sync initialization failed (will retry later): $e');
    }
  }

  /// Log SQLite content untuk debugging
  Future<void> logSQLiteContent() async {
    try {
      final db = await _dbHelper.database;

      print('\n🗃️  SQLite Database Content:');
      print('📍 Path: ${db.path}');
      print('🔌 Status: ${db.isOpen ? "Connected" : "Disconnected"}');

      // Log bookings
      final bookings = await db.query('bookings', orderBy: 'created_at DESC');
      print('\n📝 BOOKINGS (${bookings.length} total):');
      if (bookings.isEmpty) {
        print('   (No bookings yet)');
      } else {
        for (var booking in bookings) {
          String status = booking['is_synced'] == 1 ? "✅ Synced" : "⏳ Pending sync";
          print('   • ${booking['nama']} → ${booking['ruangan']}');
          print('     📅 ${booking['tanggal_mulai']} | ⏰ ${booking['jam_mulai']}-${booking['jam_selesai']}');
          print('     🔄 $status');
        }
      }

      // Summary
      final syncedBookings = await db.query('bookings', where: 'is_synced = ?', whereArgs: [1]);
      final unsyncedBookings = await db.query('bookings', where: 'is_synced = ?', whereArgs: [0]);

      print('\n📊 SUMMARY:');
      print('   Synced: ${syncedBookings.length} | Pending: ${unsyncedBookings.length}');
      print('═══════════════════════════════\n');

    } catch (e) {
      print('❌ Error logging SQLite content: $e');
    }
  }
}