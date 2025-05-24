import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tubes1_apb/pages/Dashboard.dart';
import 'firebase_options.dart';
import 'pages/Dashboard.dart';
import 'pages/login.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        '/dashboard': (context) => const Dashboard(),
        // Tambahkan rute lainnya di sini jika perlu
      },
    );
  }
}
