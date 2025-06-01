import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'room_booking.db');

    print('SQLite Database Path: $path');

    return await openDatabase(
      path,
      version: 2, // NAIKAN VERSION untuk trigger migration
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // TAMBAHAN migration handler
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel untuk cache ruangan
    await db.execute('''
      CREATE TABLE rooms(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        building TEXT NOT NULL,
        floor INTEGER NOT NULL,
        capacity INTEGER NOT NULL,
        facilities TEXT NOT NULL,
        photo_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');

    // Tabel untuk booking (UPDATED dengan user_id column)
    await db.execute('''
      CREATE TABLE bookings(
        id TEXT PRIMARY KEY,
        user_id TEXT, 
        nama TEXT NOT NULL,
        no_hp TEXT NOT NULL,
        ruangan TEXT NOT NULL,
        tanggal_mulai TEXT NOT NULL,
        tanggal_selesai TEXT NOT NULL,
        jam_mulai TEXT NOT NULL,
        jam_selesai TEXT NOT NULL,
        tujuan TEXT NOT NULL,
        organisasi TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        is_synced INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    print('SQLite tables created successfully');
  }

  // TAMBAHAN: Migration handler untuk update schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Add user_id column to existing bookings table
      try {
        await db.execute('ALTER TABLE bookings ADD COLUMN user_id TEXT');
        print('✅ Added user_id column to bookings table');
      } catch (e) {
        print('⚠️ user_id column might already exist: $e');
      }
    }
  }

  // Simpan ruangan ke SQLite (untuk cache)
  Future<void> saveRoom(Map<String, dynamic> roomData) async {
    final db = await database;
    await db.insert(
      'rooms',
      roomData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Ambil semua ruangan dari SQLite
  Future<List<Map<String, dynamic>>> getAllRooms() async {
    final db = await database;
    return await db.query('rooms', orderBy: 'building ASC, name ASC');
  }

  // Simpan booking ke SQLite
  Future<String> saveBooking(Map<String, dynamic> bookingData) async {
    final db = await database;

    // Generate ID jika belum ada
    if (bookingData['id'] == null) {
      bookingData['id'] = 'local_${DateTime.now().millisecondsSinceEpoch}';
    }

    // VALIDASI: Pastikan user_id ada (fallback jika null)
    if (bookingData['user_id'] == null) {
      bookingData['user_id'] = 'unknown_user';
      print('⚠️ user_id is null, using fallback value');
    }

    try {
      await db.insert(
        'bookings',
        bookingData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Booking saved to SQLite: ${bookingData['id']}');
      print('👤 User ID: ${bookingData['user_id']}');
      return bookingData['id'];
    } catch (e) {
      print('❌ Error saving booking to SQLite: $e');
      rethrow;
    }
  }

  // Ambil booking untuk tanggal tertentu
  Future<List<Map<String, dynamic>>> getBookingsForDate(String date) async {
    final db = await database;
    return await db.query(
      'bookings',
      where: 'tanggal_mulai = ?',
      whereArgs: [date],
    );
  }

  // Ambil booking yang belum sync
  Future<List<Map<String, dynamic>>> getUnsyncedBookings() async {
    final db = await database;
    return await db.query(
      'bookings',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  // Update status sync booking
  Future<void> markBookingAsSynced(String id, String firebaseId) async {
    final db = await database;
    await db.update(
      'bookings',
      {
        'id': firebaseId,
        'is_synced': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear semua cache ruangan
  Future<void> clearRoomCache() async {
    final db = await database;
    await db.delete('rooms');
  }

  // Update cache ruangan dari Firebase
  Future<void> updateRoomCache(List<Map<String, dynamic>> rooms) async {
    final db = await database;

    // Clear existing cache
    await db.delete('rooms');

    // Insert fresh data
    for (var room in rooms) {
      await db.insert(
        'rooms',
        {
          ...room,
          'is_synced': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print('Room cache updated: ${rooms.length} rooms');
  }

  // TAMBAHAN: Debug method untuk check schema
  Future<void> debugTableSchema() async {
    final db = await database;

    try {
      // Check bookings table schema
      List<Map<String, dynamic>> schema = await db.rawQuery('PRAGMA table_info(bookings)');
      print('\n📋 BOOKINGS TABLE SCHEMA:');
      for (var column in schema) {
        print('   ${column['name']} (${column['type']})');
      }

      // Check if user_id column exists
      bool hasUserId = schema.any((column) => column['name'] == 'user_id');
      print('📍 user_id column exists: ${hasUserId ? "✅ YES" : "❌ NO"}');

    } catch (e) {
      print('❌ Error checking table schema: $e');
    }
  }

  // TAMBAHAN: Reset database (jika migration gagal)
  Future<void> resetDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'room_booking.db');

      // Close current database
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Delete database file
      await deleteDatabase(path);
      print('🗑️ Database deleted successfully');

      // Recreate database
      _database = await _initDatabase();
      print('🆕 Database recreated successfully');

    } catch (e) {
      print('❌ Error resetting database: $e');
    }
  }
}