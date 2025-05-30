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
      version: 1,
      onCreate: _onCreate,
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

    // Tabel untuk booking (lokal dan yang belum sync)
    await db.execute('''
      CREATE TABLE bookings(
        id TEXT PRIMARY KEY,
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

    await db.insert(
      'bookings',
      bookingData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('Booking saved to SQLite: ${bookingData['id']}');
    return bookingData['id'];
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
}