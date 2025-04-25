import 'package:flutter/material.dart';
import 'BookingFormPage.dart';
import 'package:tubes1_apb/models/booking_model.dart';

class BookingHistoryPage extends StatelessWidget {
  final List<Booking> bookings;

  const BookingHistoryPage({Key? key, required this.bookings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pemesanan')),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text("${booking.nama} | ${booking.ruangan} | Pending"),
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
      ),
    );
  }
}
