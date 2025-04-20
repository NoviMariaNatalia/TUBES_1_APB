import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'room_list_page.dart';
// import 'profile_page.dart';
// import 'login_page.dart';

class BuildingDashboardPage extends StatefulWidget {
  const BuildingDashboardPage({super.key});

  @override
  State<BuildingDashboardPage> createState() => _BuildingDashboardPageState();
}

class _BuildingDashboardPageState extends State<BuildingDashboardPage> {
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> buildings = [
    {
      'name': 'GSG',
      'image': 'GSG.jpg',
      'location': LatLng(-6.976607225150223, 107.63055719126962),
    },
    {
      'name': 'PANAMBULAI',
      'image': 'panambulai.png',
      'location': LatLng(-6.9753188056790245, 107.62978992150748),
    },
    {
      'name': 'KAWALUSU',
      'image': 'FKB.jpg',
      'location': LatLng(-6.972072933255324, 107.63279606142424),
    },
    {
      'name': 'MANTERAWU',
      'image': 'manterawu.jpg',
      'location': LatLng(-6.971861029176046, 107.63238609920067),
    },
    {
      'name': 'SPORT CENTER',
      'image': 'sport-center.jpg',
      'location': LatLng(-6.971377004689319, 107.62872216568418),
    },
    {
      'name': 'STUDENT CENTER',
      'image': 'student-center.jpg',
      'location': LatLng(-6.977022667055358, 107.62945783869635),
    },
  ];

  final LatLng mapCenter = LatLng(-6.9730, 107.6305);

  void _focusToLocation(LatLng location) {
    _mapController.move(
      location,
      19.0,
    ); // Pindahkan kamera ke lokasi dengan zoom level 19
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.png', height: 40),
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/foto-profil-mahasiswa.jpg',
                    ),
                    radius: 20,
                  ),
                ],
              ),
            ),

            // Judul
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // MAP
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: mapCenter,
                    zoom: 18.0,
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.amanda.dashboardgedung',
                    ),
                    MarkerLayer(
                      markers:
                          buildings.map((b) {
                            return Marker(
                              point: b['location'],
                              width: 60,
                              height: 60,
                              child: const Icon(
                                Icons.location_on,
                                size: 32,
                                color: Colors.red,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // GRID
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  children:
                      buildings.map((b) {
                        return _buildBuildingCard(
                          b['name'],
                          b['image'],
                          b['location'],
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingCard(String name, String image, LatLng location) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.asset('assets/images/$image', fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _focusToLocation(
                      location,
                    ); // Fokus ke marker saat tombol diklik
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: const Size.fromHeight(36),
                  ),
                  child: const Text(
                    'Lihat Ruangan',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
