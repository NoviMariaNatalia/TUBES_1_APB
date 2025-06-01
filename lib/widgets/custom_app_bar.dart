import 'package:flutter/material.dart';
import '../pages/login.dart';
import '../pages/Dashboard.dart';
import '../pages/BookingHistoryPage.dart';
import '../services/auth_service.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final AuthService _authService = AuthService();
  String userName = 'User'; // Default value

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Load nama user dari AuthService
  void _loadUserName() {
    if (_authService.currentUser != null) {
      setState(() {
        userName = _authService.currentUser!.name;
      });
    } else {
      // Jika currentUser null, coba reload dari SharedPreferences
      _authService.isLoggedIn().then((isLoggedIn) {
        if (isLoggedIn && _authService.currentUser != null) {
          setState(() {
            userName = _authService.currentUser!.name;
          });
        }
      });
    }
  }

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
          GestureDetector(
            onTap: () {
              // Navigasi ke halaman Dashboard
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Dashboard(),
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
                    Text(
                      userName, // Gunakan userName dari state
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue[900],
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
                    height: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mahasiswa',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(height: 10),
                      ],
                    ),
                  ),

                  // Menu Riwayat
                  PopupMenuItem(
                    height: 40,
                    child: const Row(
                      children: [
                        Icon(Icons.history, size: 18),
                        SizedBox(width: 10),
                        Text('Riwayat Pengajuan'),
                      ],
                    ),
                    onTap: () {
                      print('Navigate to Riwayat');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingHistoryPage(),
                        ),
                      );
                    },
                  ),

                  // Menu Keluar
                  PopupMenuItem(
                    height: 40,
                    child: const Row(
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 10),
                        Text('Keluar'),
                      ],
                    ),
                    onTap: () async {
                      print('Navigate to Keluar');
                      // Logout user
                      await _authService.logout();

                      // Navigate to login page
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()
                          ),
                              (route) => false,
                        );
                      }
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