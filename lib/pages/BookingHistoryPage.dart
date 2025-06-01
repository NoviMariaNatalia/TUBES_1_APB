import 'package:flutter/material.dart';
import 'package:tubes1_apb/models/booking_model.dart';
import 'package:tubes1_apb/services/booking_service.dart';
import 'package:tubes1_apb/services/auth_service.dart';
import '../widgets/custom_app_bar.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({Key? key}) : super(key: key);

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  bool _isInitialized = false; // Track initialization status

  @override
  void initState() {
    super.initState();
    _initializeSession(); // Initialize session saat halaman dibuka
  }

  // Method untuk restore session user
  Future<void> _initializeSession() async {
    try {
      print('🔄 Initializing user session...');

      // Restore user session dari SharedPreferences
      bool isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn && _authService.currentUser != null) {
        print('✅ User session restored: ${_authService.currentUser!.name}');
      } else {
        print('❌ No valid user session found');
      }

      setState(() {
        _isInitialized = true;
      });

    } catch (e) {
      print('❌ Error initializing session: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading sementara session di-restore
    if (!_isInitialized) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat riwayat...'),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan nama user dan debug info
                    Row(
                      children: [
                        const Icon(Icons.history, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Riwayat Pengajuan ${_authService.currentUser?.name ?? "User"}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // DEBUG INFO
                              Text(
                                'User ID: ${_authService.currentUser?.id ?? "null"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // StreamBuilder untuk booking user yang sedang login
                    Expanded(
                      child: StreamBuilder<List<Booking>>(
                        stream: _authService.currentUser != null
                            ? _bookingService.getBookingsByUserId(_authService.currentUser!.id)
                            : Stream.value([]), // Empty stream jika tidak login
                        builder: (context, snapshot) {
                          // Debug info
                          print('📊 StreamBuilder state:');
                          print('   Connection: ${snapshot.connectionState}');
                          print('   Has data: ${snapshot.hasData}');
                          print('   Data count: ${snapshot.data?.length ?? 0}');
                          print('   Current user: ${_authService.currentUser?.name ?? "null"}');

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, size: 48, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text('Error: ${snapshot.error}'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isInitialized = false;
                                      });
                                      _initializeSession();
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          List<Booking> bookings = snapshot.data ?? [];

                          // Jika user belum login
                          if (_authService.currentUser == null) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login, size: 48, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Silakan login untuk melihat riwayat',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Jika tidak ada booking
                          if (bookings.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.event_note, size: 48, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Belum ada riwayat booking',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'User: ${_authService.currentUser!.name}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    'ID: ${_authService.currentUser!.id}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isInitialized = false;
                                      });
                                      _initializeSession();
                                    },
                                    child: const Text('Refresh'),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Tampilkan list booking
                          return ListView.builder(
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColor(booking.status),
                                    child: Icon(
                                      _getStatusIcon(booking.status),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    "${booking.nama} | ${booking.ruangan}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Tanggal: ${booking.tanggalMulai}'),
                                      Text('Waktu: ${booking.jamMulai} - ${booking.jamSelesai}'),
                                      Text('User ID: ${booking.userId}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(booking.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _getStatusColor(booking.status),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          _getStatusText(booking.status),
                                          style: TextStyle(
                                            color: _getStatusColor(booking.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Detail Pemesanan"),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _buildDetailRow("ID Booking", booking.id),
                                                _buildDetailRow("User ID", booking.userId),
                                                _buildDetailRow("Nama", booking.nama),
                                                _buildDetailRow("No HP", booking.noHp),
                                                _buildDetailRow("Ruangan", booking.ruangan),
                                                _buildDetailRow("Tanggal Mulai", booking.tanggalMulai),
                                                _buildDetailRow("Tanggal Selesai", booking.tanggalSelesai),
                                                _buildDetailRow("Jam Mulai", booking.jamMulai),
                                                _buildDetailRow("Jam Selesai", booking.jamSelesai),
                                                _buildDetailRow("Tujuan", booking.tujuan),
                                                _buildDetailRow("Organisasi", booking.organisasi),
                                                _buildDetailRow("Status", booking.status),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("Tutup"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Text("Detail"),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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

  // Helper method untuk detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? "-" : value),
          ),
        ],
      ),
    );
  }

  // Helper methods untuk status styling
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.pending;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
      default:
        return 'Menunggu';
    }
  }
}