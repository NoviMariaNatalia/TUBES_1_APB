import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';
import '../services/hybrid_booking_service.dart';
import '../widgets/custom_app_bar.dart';
import 'BookingFormPage.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final MapController _mapController = MapController();
  final RoomService _roomService = RoomService();
  final HybridBookingService _hybridBookingService = HybridBookingService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _showMap = true;

  // Hardcoded building locations (akan dipetakan dengan rooms berdasarkan building name)
  final Map<String, Map<String, dynamic>> buildingLocations = {
    'GSG': {
      'location': LatLng(-6.976607225150223, 107.63055719126962),
      'image': 'GSG.jpg',
    },
    'PANAMBULAI': {
      'location': LatLng(-6.9753188056790245, 107.62978992150748),
      'image': 'panambulai.png',
    },
    'KAWALUSU': {
      'location': LatLng(-6.972072933255324, 107.63279606142424),
      'image': 'FKB.jpg',
    },
    'MANTERAWU': {
      'location': LatLng(-6.971861029176046, 107.63238609920067),
      'image': 'manterawu.jpg',
    },
    'SPORT CENTER': {
      'location': LatLng(-6.971377004689319, 107.62872216568418),
      'image': 'sport-center.jpg',
    },
    'STUDENT CENTER': {
      'location': LatLng(-6.977022667055358, 107.62945783869635),
      'image': 'student-center.jpg',
    },
  };

  final LatLng mapCenter = LatLng(-6.9730, 107.6305);

  @override
  void initState() {
    super.initState();
    _initializeSync();
  }

  Future<void> _initializeSync() async {
    try {
      print('🔄 Dashboard: Initializing hybrid sync...');

      // Initialize hybrid booking service
      await _hybridBookingService.initializeSync();
      print('✅ Dashboard: Hybrid booking sync initialized');

      // Force refresh room data from Firebase
      await _roomService.forceRefresh();
      print('✅ Dashboard: Room data refreshed');

    } catch (e) {
      print('❌ Dashboard: Sync failed - $e');
      // Continue anyway, app will work with cached data
    }
  }

  void _focusToLocation(LatLng location) {
    _mapController.move(location, 19.0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            const CustomAppBar(),

            // Header with title and toggle
            _buildHeader(),

            // Search bar
            _buildSearchBar(),

            // Map (conditional)
            if (_showMap) _buildMap(),

            // Room List
            Expanded(child: _buildRoomList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard Ruangan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showMap = !_showMap;
                  });
                },
                icon: Icon(_showMap ? Icons.map : Icons.map_outlined),
                tooltip: _showMap ? 'Sembunyikan Peta' : 'Tampilkan Peta',
              ),
              IconButton(
                onPressed: () async {
                  // Refresh data dengan sync
                  await _initializeSync();
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh & Sync',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari ruangan atau gedung...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
            icon: const Icon(Icons.clear),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: StreamBuilder<List<Room>>(
          stream: _roomService.getAllRooms(),
          builder: (context, snapshot) {
            List<Marker> markers = [];

            if (snapshot.hasData) {
              // Group rooms by building
              Map<String, List<Room>> roomsByBuilding = {};
              for (Room room in snapshot.data!) {
                if (!roomsByBuilding.containsKey(room.building)) {
                  roomsByBuilding[room.building] = [];
                }
                roomsByBuilding[room.building]!.add(room);
              }

              // Create markers for each building that has rooms
              for (String building in roomsByBuilding.keys) {
                if (buildingLocations.containsKey(building)) {
                  final location = buildingLocations[building]!['location'] as LatLng;
                  final roomCount = roomsByBuilding[building]!.length;

                  markers.add(
                    Marker(
                      point: location,
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () => _focusToLocation(location),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$roomCount ruang',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.location_on,
                              size: 32,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
            }

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: mapCenter,
                zoom: 18.0,
                interactiveFlags: InteractiveFlag.all,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.amanda.nspace',
                ),
                MarkerLayer(markers: markers),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoomList() {
    return StreamBuilder<List<Room>>(
      stream: _searchQuery.isEmpty
          ? _roomService.getAllRooms()
          : Stream.fromFuture(_roomService.searchRooms(_searchQuery)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _initializeSync();
                    setState(() {});
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.meeting_room, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'Belum ada ruangan tersedia'
                      : 'Tidak ada ruangan yang cocok',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: const Text('Hapus Filter'),
                  ),
                ],
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _initializeSync();
                      setState(() {});
                    },
                    child: const Text('Refresh Data'),
                  ),
                ],
              ],
            ),
          );
        }

        List<Room> rooms = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return _buildRoomCard(rooms[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Room Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: room.hasValidPhotoUrl
                  ? Image.network(
                room.fullPhotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Image load error for ${room.name}: $error');
                  return Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image_not_supported,
                          size: 30,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Image unavailable',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Loading...',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.meeting_room,
                      size: 40,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Room Info
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.building,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Lantai: ${room.floor}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Kapasitas: ${room.capacity}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fasilitas: ${room.facilitiesString}',
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingFormPage(roomName: room.name),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: const Size.fromHeight(32),
                    ),
                    child: const Text(
                      'Cek Ketersediaan',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}