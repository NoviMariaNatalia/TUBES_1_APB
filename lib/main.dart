import 'package:flutter/material.dart';
import 'pages/BuildingDashboardPage.dart';
import 'pages/login.dart';
import 'pages/profile_mahasiswa_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'N-Space',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/dashboard': (context) => const BuildingDashboardPage(),
        '/profil-mahasiswa': (context) => const ProfilMahasiswaPage(),
        // Tambahkan rute lainnya di sini jika perlu
      },
    );
  }
}
