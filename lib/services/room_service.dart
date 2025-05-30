import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';
import 'database_helper.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final String _collection = 'rooms';

  /// Hybrid method: SQLite first, then Firebase
  Stream<List<Room>> getAllRooms() async* {
    try {
      // 1. Emit data dari SQLite dulu (untuk UI cepat)
      List<Room> localRooms = await _getLocalRooms();
      if (localRooms.isNotEmpty) {
        print('Loading rooms from SQLite cache: ${localRooms.length} rooms');
        yield localRooms;
      }

      // 2. Sync dengan Firebase dan update cache
      await _syncRoomsFromFirebase();

      // 3. Emit data terbaru dari SQLite
      List<Room> updatedRooms = await _getLocalRooms();
      yield updatedRooms;

    } catch (e) {
      print('Error in getAllRooms: $e');
      // Fallback ke data lokal jika ada error
      List<Room> fallbackRooms = await _getLocalRooms();
      yield fallbackRooms;
    }
  }

  /// Get rooms dari SQLite
  Future<List<Room>> _getLocalRooms() async {
    try {
      final roomsData = await _dbHelper.getAllRooms();

      return roomsData.map((data) {
        return Room(
          id: data['id'],
          name: data['name'],
          building: data['building'],
          floor: data['floor'],
          capacity: data['capacity'],
          facilities: (data['facilities'] as String).split(','),
          photoUrl: data['photo_url'] ?? '',
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
        );
      }).toList();
    } catch (e) {
      print('Error getting local rooms: $e');
      return [];
    }
  }

  /// Sync rooms dari Firebase ke SQLite
  Future<void> _syncRoomsFromFirebase() async {
    try {
      print('Syncing rooms from Firebase...');

      QuerySnapshot snapshot = await _firestore.collection(_collection).get();

      List<Map<String, dynamic>> firebaseRooms = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'building': data['building'] ?? '',
          'floor': data['floor'] ?? 0,
          'capacity': data['capacity'] ?? 0,
          'facilities': (data['facilities'] as List?)?.join(',') ?? '',
          'photo_url': data['photo_url'] ?? '',
        };
      }).toList();

      // Update cache di SQLite
      await _dbHelper.updateRoomCache(firebaseRooms);

      print('Firebase sync completed: ${firebaseRooms.length} rooms');

    } catch (e) {
      print('Error syncing from Firebase: $e');
      // Jika error, tetap gunakan cache lokal
    }
  }

  /// Search rooms (dari SQLite untuk performa)
  Future<List<Room>> searchRooms(String query) async {
    try {
      final allRooms = await _getLocalRooms();

      if (query.isEmpty) return allRooms;

      return allRooms.where((room) {
        return room.name.toLowerCase().contains(query.toLowerCase()) ||
            room.building.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error searching rooms: $e');
      return [];
    }
  }

  /// Check if room exists (untuk validasi)
  Future<bool> roomExists(String roomName) async {
    try {
      final rooms = await _getLocalRooms();
      return rooms.any((room) => room.name == roomName);
    } catch (e) {
      print('Error checking room existence: $e');
      return false;
    }
  }

  /// Get room statistics
  Future<Map<String, dynamic>> getRoomStatistics() async {
    try {
      final rooms = await _getLocalRooms();

      int totalRooms = rooms.length;
      int totalCapacity = rooms.fold(0, (sum, room) => sum + room.capacity);

      Map<String, int> buildingCount = {};
      for (var room in rooms) {
        buildingCount[room.building] = (buildingCount[room.building] ?? 0) + 1;
      }

      return {
        'total_rooms': totalRooms,
        'total_capacity': totalCapacity,
        'buildings': buildingCount,
        'building_count': buildingCount.length,
      };
    } catch (e) {
      print('Error getting room statistics: $e');
      return {
        'total_rooms': 0,
        'total_capacity': 0,
        'buildings': {},
        'building_count': 0,
      };
    }
  }

  /// Force refresh dari Firebase
  Future<void> forceRefresh() async {
    await _syncRoomsFromFirebase();
  }
}