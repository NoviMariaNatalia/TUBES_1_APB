import 'package:flutter/material.dart';
import 'pages/BuildingDashboardPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peminjaman Ruangan Kampus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const BuildingDashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
