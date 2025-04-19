import 'package:flutter/material.dart';
import 'pages/room_list_page.dart';

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
      home: const RoomListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}