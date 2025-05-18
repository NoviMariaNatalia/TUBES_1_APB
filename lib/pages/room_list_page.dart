import 'package:flutter/material.dart';
import 'BuildingDashboardPage.dart';
import 'profile_mahasiswa_page.dart';
import 'login.dart';
import 'BookingFormPage.dart';
import '../widgets/custom_app_bar.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({Key? key}) : super(key: key);

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  // bool _showProfileMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            const CustomAppBar(),

            // Judul Halaman
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Daftar Ruangan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Daftar Ruangan
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _buildRoomCard('VIP A', 'vipA-gsg.png', 1, 50, [
                      'AC',
                      'Proyektor',
                    ]),
                    _buildRoomCard('VIP B', 'vipB-gsg.png', 2, 50, [
                      'AC',
                      'Toilet',
                    ]),
                    _buildRoomCard('VIP C', 'vipC-gsg.png', 3, 50, [
                      'AC',
                      'Proyektor',
                    ]),
                    _buildRoomCard('AULA GSG', 'aula-gsg.png', 1, 50, [
                      'Toilet',
                      'Proyektor',
                    ]),
                    _buildRoomCard(
                      'LAPANGAN TIMUR GSG',
                      'lapanganTimur-gsg.png',
                      0,
                      50,
                      [],
                    ),
                    _buildRoomCard(
                      'LAPANGAN UPACARA GSG',
                      'lapanganUpacara-gsg.png',
                      0,
                      50,
                      [],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(
    String name,
    String image,
    int floor,
    int capacity,
    List<String> facilities,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16/9,
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              child: Image.asset(
                  'assets/images/$image',
                  fit: BoxFit.cover,
                  // height: double.infinity,
                  // width: double.infinity,
              ),
            )
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  // maxLines: 1,
                  // overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('Lantai: $floor', style: const TextStyle(fontSize: 12)),
                Text(
                  'Kapasitas: $capacity',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fasilitas: ${facilities.isEmpty ? '-' : facilities.join(', ')}',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingFormPage(roomName: name),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: const Size.fromHeight(36),
                  ),
                  child: const Text(
                    'Cek Ketersediaan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ), // Warna teks putih
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
