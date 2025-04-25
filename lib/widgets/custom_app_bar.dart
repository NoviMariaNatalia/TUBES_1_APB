import 'package:flutter/material.dart';
import '../pages/profile_mahasiswa_page.dart'; // (halaman yang nanti kita buat)
import '../pages/login.dart'; // pastikan halaman login kamu juga ada

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            child: Image.asset('assets/images/logo.png', height: 40),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profil') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilMahasiswaPage(),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profil',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profil Saya'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Keluar'),
                ),
              ),
            ],
            child: Row(
              children: [
                const Text('J. Smith', style: TextStyle(color: Colors.black)),
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundImage: AssetImage(
                    'assets/images/foto-profil-mahasiswa.jpg',
                  ),
                  radius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
