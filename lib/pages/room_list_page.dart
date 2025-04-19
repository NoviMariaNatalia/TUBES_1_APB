import 'package:flutter/material.dart';
// import 'dashboard_page.dart';
// import 'profile_page.dart';
// import 'login_page.dart';
// import 'booking_form_page.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({Key? key}) : super(key: key);

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  bool _showProfileMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App bar untuk logo dan foto profil
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
                  // Logo
                  GestureDetector(
                    onTap: () {
                      // Navigasi ke dashboard
                      // digunakan jika dashboard_page.dart sudah dibuat
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const DashboardPage()),
                      // );
                      print('Navigate to Dashboard');
                    },
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 40,
                    ),
                  ),
                  // Foto Profil
                  PopupMenuButton(
                    offset: const Offset(0, 50),
                    icon: const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        'assets/images/foto-profil-mahasiswa.jpg',
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jack Smith',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue[900],
                              ),
                            ),
                            const Text(
                              'Mahasiswa',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.person_outline, size: 20),
                            SizedBox(width: 10),
                            Text('Profil Saya'),
                          ],
                        ),
                        onTap: () {
                          print('Navigate to Profile');
                          // Navigasi ke profil mahasiswa
                          // digunakan jika profile_page.dart sudah dibuat
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const ProfilePage()),
                          // );
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 10),
                            Text('Keluar'),
                          ],
                        ),
                        onTap: () {
                          print('Navigate to Login');
                          // Navigasi ke login
                          // digunakan jika login_page.dart sudah dibuat
                          // Navigator.pushAndRemoveUntil(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const LoginPage()),
                          //   (route) => false,
                          // );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
                  childAspectRatio: 0.8,
                  children: [
                    _buildRoomCard(
                      'VIP A',
                      'vipA-gsg.png',
                      1,
                      50,
                      ['AC', 'Proyektor'],
                    ),
                    _buildRoomCard(
                      'VIP B',
                      'vipB-gsg.png',
                      2,
                      50,
                      ['AC', 'Toilet'],
                    ),
                    _buildRoomCard(
                      'VIP C',
                      'vipC-gsg.png',
                      3,
                      50,
                      ['AC', 'Proyektor'],
                    ),
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
                    _buildRoomCard(
                      'AULA GSG',
                      'aula-gsg.png',
                      1,
                      50,
                      ['Toilet', 'Proyektor'],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
              child: Image.asset(
                'assets/images/$image',
                fit: BoxFit.cover,
              ),
            ),
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
                ),
                const SizedBox(height: 4),
                Text(
                  'Lantai: $floor',
                  style: const TextStyle(fontSize: 12),
                ),
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
                    // Navigasi ke form peminjaman ruangan
                    // digunakan jika booking_form_page.dart sudah dibuat
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => BookingFormPage(roomName: name),
                    //   ),
                    // );
                    print('Navigate to booking form for $name');
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
                    style: TextStyle(fontSize: 12, color: Colors.white), // Warna teks putih
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