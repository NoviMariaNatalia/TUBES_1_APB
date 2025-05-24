class Room {
  final String id;
  final String name;
  final String building;
  final int floor;
  final int capacity;
  final List<String> facilities;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.facilities,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor untuk membuat Room dari Firebase document
  factory Room.fromFirestore(Map<String, dynamic> data, String documentId) {
    try {
      return Room(
        id: documentId,
        name: data['name']?.toString() ?? '',
        building: data['building']?.toString() ?? '',
        floor: _parseInt(data['floor']),
        capacity: _parseInt(data['capacity']),
        facilities: _parseStringList(data['facilities']),
        photoUrl: data['photo_url']?.toString() ?? '',
        createdAt: DateTime.now(), // Simplified: gunakan current time
        updatedAt: DateTime.now(), // Simplified: gunakan current time
      );
    } catch (e) {
      print('Error creating Room from data: $e');
      print('Data: $data');
      // Return default room jika error
      return Room(
        id: documentId,
        name: 'Unknown Room',
        building: 'Unknown Building',
        floor: 0,
        capacity: 0,
        facilities: [],
        photoUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Helper method untuk parse integer dengan safety
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Helper method untuk parse string list dengan safety
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  // Convert Room object ke Map (untuk send ke Firebase jika diperlukan)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'building': building,
      'floor': floor,
      'capacity': capacity,
      'facilities': facilities,
      'photo_url': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method untuk mendapatkan facilities sebagai string
  String get facilitiesString {
    return facilities.isEmpty ? '-' : facilities.join(', ');
  }

  // Helper method untuk mendapatkan full photo URL
  String get fullPhotoUrl {
    if (photoUrl.isEmpty) return '';
    const String baseUrl = 'http://10.0.2.2:8000/storage/'; // ← Pastikan ini
    return baseUrl + photoUrl;
  }

  // Helper method untuk check apakah image URL valid
  bool get hasValidPhotoUrl {
    return photoUrl.isNotEmpty && photoUrl != 'null' && photoUrl != '';
  }

  @override
  String toString() {
    return 'Room{id: $id, name: $name, building: $building, floor: $floor, capacity: $capacity, facilities: $facilities}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Room && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}