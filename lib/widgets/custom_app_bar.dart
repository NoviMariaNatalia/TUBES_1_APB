import 'package:flutter/material.dart';
import '../pages/profile_mahasiswa_page.dart'; // (halaman yang nanti kita buat)
import '../pages/login.dart'; // pastikan halaman login kamu juga ada
import '../pages/BuildingDashboardPage.dart';
import '../pages/BookingHistoryPage.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
          // Di dalam Container (Header bagian atas)
          GestureDetector(
            onTap: () {
              // Navigasi ke halaman Dashboard
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuildingDashboardPage(),
                ),
              );
            },
            child: Image.asset('assets/images/logo.png', height: 40),
          ),

          // Foto profil dengan dropdown
          Row(
            children: [
              PopupMenuButton(
                offset: const Offset(0, 45),
                icon: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18, // Lebih kecil
                      backgroundImage: AssetImage(
                        'assets/images/foto-profil-mahasiswa.jpg',
                      ),
                    ),
                    // Icon dropdown sebagai indikator
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue[900],
                      size: 20,
                    ),
                  ],
                ),
                itemBuilder: (context) => [
                  // Info profil
                  PopupMenuItem(
                    enabled: false,
                    height: 40, // Lebih pendek
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jack Smith',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Lebih kecil
                            color: Colors.blue[900],
                          ),
                        ),
                        Text(
                          'Mahasiswa',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(height: 10), // Lebih pendek
                      ],
                    ),
                  ),

                  // Menu Riwayat (baru)
                  PopupMenuItem(
                    height: 40, // Lebih pendek
                    child: const Row(
                      children: [
                        Icon(Icons.history, size: 18),
                        SizedBox(width: 10),
                        Text('Riwayat Pengajuan'),
                      ],
                    ),
                    onTap: () {
                      print('Navigate to Riwayat');
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const BookingHistoryPage(),
                      //   ),
                      // );
                    },
                  ),

                  // Menu Profil Saya
                  PopupMenuItem(
                    height: 40, // Lebih pendek
                    child: const Row(
                      children: [
                        Icon(Icons.person_outline, size: 18),
                        SizedBox(width: 10),
                        Text('Profil Saya'),
                      ],
                    ),
                    onTap: () {
                      print('Navigate to Profil Saya');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilMahasiswaPage(),
                        ),
                      );
                    },
                  ),

                  // Menu Keluar
                  PopupMenuItem(
                    height: 40, // Lebih pendek
                    child: const Row(
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 10),
                        Text('Keluar'),
                      ],
                    ),
                    onTap: () {
                      print('Navigate to Keluar');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}