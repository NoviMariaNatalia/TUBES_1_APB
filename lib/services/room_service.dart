import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'rooms';

  /// Stream untuk mendapatkan semua ruangan secara real-time (tanpa orderBy)
  Stream<List<Room>> getAllRooms() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      List<Room> rooms = snapshot.docs.map((doc) {
        try {
          return Room.fromFirestore(doc.data(), doc.id);
        } catch (e) {
          print('Error parsing room ${doc.id}: $e');
          return null;
        }
      }).where((room) => room != null).cast<Room>().toList();

      // Sort di client side
      rooms.sort((a, b) {
        int buildingCompare = a.building.compareTo(b.building);
        if (buildingCompare != 0) return buildingCompare;
        return a.name.compareTo(b.name);
      });

      return rooms;
    });
  }

  /// Get rooms berdasarkan building name
  Stream<List<Room>> getRoomsByBuilding(String building) {
    return _firestore
        .collection(_collection)
        .where('building', isEqualTo: building)
        .snapshots()
        .map((snapshot) {
      List<Room> rooms = snapshot.docs.map((doc) {
        try {
          return Room.fromFirestore(doc.data(), doc.id);
        } catch (e) {
          print('Error parsing room ${doc.id}: $e');
          return null;
        }
      }).where((room) => room != null).cast<Room>().toList();

      // Sort by name
      rooms.sort((a, b) => a.name.compareTo(b.name));
      return rooms;
    });
  }

  /// Get single room by ID
  Future<Room?> getRoomById(String roomId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(roomId)
          .get();

      if (doc.exists && doc.data() != null) {
        return Room.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting room $roomId: $e');
      return null;
    }
  }

  /// Get unique building names
  Future<List<String>> getBuildingNames() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .get();

      Set<String> buildingNames = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final building = data['building'] as String?;
        if (building != null && building.isNotEmpty) {
          buildingNames.add(building);
        }
      }

      List<String> sortedBuildings = buildingNames.toList();
      sortedBuildings.sort();
      return sortedBuildings;
    } catch (e) {
      print('Error getting building names: $e');
      return [];
    }
  }

  /// Search rooms by name or building
  Stream<List<Room>> searchRooms(String query) {
    if (query.isEmpty) {
      return getAllRooms();
    }

    // Get all rooms and filter on client side
    return getAllRooms().map((rooms) {
      return rooms.where((room) {
        return room.name.toLowerCase().contains(query.toLowerCase()) ||
            room.building.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  /// Get room statistics
  Future<Map<String, dynamic>> getRoomStatistics() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .get();

      int totalRooms = snapshot.docs.length;
      int totalCapacity = 0;
      Map<String, int> buildingCount = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final capacity = data['capacity'] as int? ?? 0;
        final building = data['building'] as String? ?? '';

        totalCapacity += capacity;
        buildingCount[building] = (buildingCount[building] ?? 0) + 1;
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
}