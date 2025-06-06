import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/booking_model.dart';
import 'database_helper.dart';
import 'booking_service.dart';
import '../services/auth_service.dart';
import 'dart:async';

class HybridBookingService {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final BookingService _bookingService = BookingService(); // NEW: Tambahan booking service

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
      'user_id': booking.userId, // TAMBAHAN user_id
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
      'userId': booking.userId, // TAMBAHAN userId untuk Firebase
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

  /// ===== MODIFIKASI UTAMA: Get HANYA approved bookings untuk jadwal =====
  Future<List<Map<String, dynamic>>> getBookingsForDate(DateTime date) async {
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    try {
      print('📅 Getting APPROVED bookings for $formattedDate...');

      // ===== PERUBAHAN: Hanya ambil booking yang approved =====
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('tanggalMulai', isEqualTo: formattedDate)
          .where('status', isEqualTo: 'approved') // NEW: Filter hanya approved
          .get()
          .timeout(const Duration(seconds: 5)); // 5 detik timeout

      List<Map<String, dynamic>> approvedBookings = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      print('✅ Loaded ${approvedBookings.length} APPROVED bookings from Firebase');

      // ===== NEW: Cache approved bookings =====
      await _cacheApprovedBookings(approvedBookings, date);

      return approvedBookings;

    } catch (e) {
      print('🔄 Firebase failed, using SQLite cache for approved bookings...');

      // ===== FALLBACK: Ambil approved bookings dari cache =====
      List<Map<String, dynamic>> cachedApprovedBookings = await _getCachedApprovedBookings(date);
      print('📱 Loaded ${cachedApprovedBookings.length} APPROVED bookings from cache');
      return cachedApprovedBookings;
    }
  }

  /// ===== NEW METHOD: Cache approved bookings =====
  Future<void> _cacheApprovedBookings(List<Map<String, dynamic>> bookings, DateTime date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String dateKey = 'approved_bookings_${DateFormat('yyyy_MM_dd').format(date)}';
      String bookingsJson = jsonEncode(bookings);
      await prefs.setString(dateKey, bookingsJson);
      print('💾 Cached ${bookings.length} approved bookings for ${DateFormat('dd/MM/yyyy').format(date)}');
    } catch (e) {
      print('❌ Error caching approved bookings: $e');
    }
  }

  /// ===== NEW METHOD: Get cached approved bookings =====
  Future<List<Map<String, dynamic>>> _getCachedApprovedBookings(DateTime date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String dateKey = 'approved_bookings_${DateFormat('yyyy_MM_dd').format(date)}';
      String? bookingsJson = prefs.getString(dateKey);

      if (bookingsJson != null) {
        List<dynamic> decoded = jsonDecode(bookingsJson);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('❌ Error getting cached approved bookings: $e');
    }
    return [];
  }

  /// ===== MODIFIKASI: Get ALL bookings (untuk admin atau sync) =====
  Future<List<Map<String, dynamic>>> getAllBookingsForDate(DateTime date) async {
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    try {
      print('📅 Getting ALL bookings for $formattedDate...');

      // Ambil semua booking (termasuk pending, approved, rejected)
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('tanggalMulai', isEqualTo: formattedDate)
          .get()
          .timeout(const Duration(seconds: 5));

      List<Map<String, dynamic>> allBookings = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      print('✅ Loaded ${allBookings.length} ALL bookings from Firebase');
      return allBookings;

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
          // MODIFIKASI: Get current user ID, atau gunakan yang tersimpan di local data
          String userId = bookingData['user_id'] ??
              _authService.currentUser?.id ??
              'legacy_user'; // fallback untuk data lama

          // Create Booking object dengan userId
          Booking booking = Booking(
            userId: userId, // TAMBAHAN userId
            nama: bookingData['nama'] ?? '',
            noHp: bookingData['no_hp'] ?? '',
            ruangan: bookingData['ruangan'] ?? '',
            tanggalMulai: bookingData['tanggal_mulai'] ?? '',
            tanggalSelesai: bookingData['tanggal_selesai'] ?? '',
            jamMulai: bookingData['jam_mulai'] ?? '',
            jamSelesai: bookingData['jam_selesai'] ?? '',
            tujuan: bookingData['tujuan'] ?? '',
            organisasi: bookingData['organisasi'] ?? '',
          );

          // Sync to Firebase with timeout
          String firebaseId = await _syncToFirebase(booking, bookingData['id'].toString())
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

  /// ===== MODIFIKASI: Validasi konflik hanya dengan approved bookings =====
  Future<bool> hasBookingConflict({
    required String roomName,
    required DateTime startDate,
    required int startHour,
    required int endHour,
  }) async {
    try {
      // ===== PERUBAHAN: Hanya check approved bookings untuk konflik =====
      List<Map<String, dynamic>> approvedBookings = await getBookingsForDate(startDate);

      for (var booking in approvedBookings) {
        if (booking['ruangan'] == roomName) {
          String jamMulaiKey = booking.containsKey('jamMulai') ? 'jamMulai' : 'jam_mulai';
          String jamSelesaiKey = booking.containsKey('jamSelesai') ? 'jamSelesai' : 'jam_selesai';

          String jamMulaiStr = booking[jamMulaiKey] ?? '';
          String jamSelesaiStr = booking[jamSelesaiKey] ?? '';

          if (jamMulaiStr.isNotEmpty && jamSelesaiStr.isNotEmpty) {
            int existingStart = int.parse(jamMulaiStr.split(':')[0]);
            int existingEnd = int.parse(jamSelesaiStr.split(':')[0]);

            // Check overlap
            if (startHour < existingEnd && endHour > existingStart) {
              print('❌ Booking conflict detected with APPROVED booking');
              return true; // Ada konflik dengan approved booking
            }
          }
        }
      }

      print('✅ No booking conflicts with approved bookings');
      return false; // Tidak ada konflik dengan approved bookings
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

  /// ===== NEW METHOD: Clear approved bookings cache =====
  Future<void> clearApprovedBookingsCache() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs.getKeys().where((key) => key.startsWith('approved_bookings_')).toList();

      for (String key in keys) {
        await prefs.remove(key);
      }

      print('🗑️ Cleared ${keys.length} approved bookings cache entries');
    } catch (e) {
      print('❌ Error clearing approved bookings cache: $e');
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
          String userId = booking['user_id']?.toString() ?? 'No User ID';
          String bookingStatus = booking['status']?.toString() ?? 'pending';
          print('   • ${booking['nama']} → ${booking['ruangan']}');
          print('     👤 User: $userId');
          print('     📅 ${booking['tanggal_mulai']} | ⏰ ${booking['jam_mulai']}-${booking['jam_selesai']}');
          print('     📋 Status: $bookingStatus');
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