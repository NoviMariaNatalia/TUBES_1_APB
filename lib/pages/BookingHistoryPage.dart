import 'package:flutter/material.dart';
import 'package:tubes1_apb/models/booking_model.dart';
import 'package:tubes1_apb/services/booking_service.dart';

class BookingHistoryPage extends StatelessWidget {
  final BookingService _bookingService = BookingService();

  BookingHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pemesanan')),
      body: StreamBuilder<List<Booking>>(
        stream: _bookingService.getBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data booking'));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("${booking.nama} | ${booking.ruangan} | ${booking.status}"),
                  trailing: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Detail Pemesanan"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nama       : ${booking.nama}"),
                              Text("No HP      : ${booking.noHp}"),
                              Text("Ruangan    : ${booking.ruangan}"),
                              Text(
                                  "Tanggal & Jam: ${booking.tanggalMulai} jam ${booking.jamMulai} - ${booking.tanggalSelesai} jam ${booking.jamSelesai}"),
                              Text("Tujuan     : ${booking.tujuan}"),
                              Text("Organisasi : ${booking.organisasi}"),
                              Text("Status     : ${booking.status}"),
                            ],
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
    );
  }
}