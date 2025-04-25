import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class ProfilMahasiswaPage extends StatelessWidget {
  const ProfilMahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(), // tetap pakai app bar atas yang sama
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FOTO + Nama
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: 220,
                      child: Column(
                        children: [
                          const CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/images/foto-profil-mahasiswa.jpg'),
                            radius: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Jack Smith',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text('Mahasiswa'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Detail Profil
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Detail Profil',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Divider(),
                            ProfileDetailRow('Nama Lengkap', 'Jack Smith'),
                            ProfileDetailRow('Angkatan', '2022'),
                            ProfileDetailRow('NIM', '1303221234'),
                            ProfileDetailRow('Negara', 'Indonesia'),
                            ProfileDetailRow('Alamat',
                                'Jl. Dayu Utama No. 10A, Sleman, Yogyakarta'),
                            ProfileDetailRow('No. HP', '085566778899'),
                            ProfileDetailRow('Email', 'jackSmith@example.com'),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileDetailRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
