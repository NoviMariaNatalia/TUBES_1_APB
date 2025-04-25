import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'BookingHistoryPage.dart';
import 'package:tubes1_apb/models/booking_model.dart';

class BookingFormPage extends StatefulWidget {
  final String roomName;

  const BookingFormPage({Key? key, required this.roomName}) : super(key: key);

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final TextEditingController _namaPemesanController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _namaOrganisasiController =
      TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  int? _jamMulai;
  int? _jamSelesai;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _tanggalMulai = picked;
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  void _resetForm() {
    setState(() {
      _namaPemesanController.clear();
      _noHpController.clear();
      _tujuanController.clear();
      _namaOrganisasiController.clear();
      _tanggalMulai = null;
      _tanggalSelesai = null;
      _jamMulai = null;
      _jamSelesai = null;
    });
  }

  void _submitForm() {
    String errorMessage = "";

    if (_namaPemesanController.text.isEmpty ||
        _noHpController.text.isEmpty ||
        _tujuanController.text.isEmpty ||
        _namaOrganisasiController.text.isEmpty ||
        _tanggalMulai == null ||
        _tanggalSelesai == null ||
        _jamMulai == null ||
        _jamSelesai == null) {
      errorMessage = "Semua field harus diisi.";
    } else if (_tanggalMulai!.isAfter(_tanggalSelesai!)) {
      errorMessage = "Tanggal mulai tidak boleh setelah tanggal selesai.";
    } else if (_tanggalMulai!.isAtSameMomentAs(_tanggalSelesai!) &&
        _jamMulai! >= _jamSelesai!) {
      errorMessage = "Jam mulai harus sebelum jam selesai.";
    }

    if (errorMessage.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Validasi Gagal"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Pengajuan"),
        content: const Text(
            "Apakah Anda yakin ingin mengajukan peminjaman ruangan?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Form berhasil diajukan.")),
              );
              _resetForm();
            },
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    final rooms = [
      "VIP A",
      "VIP B",
      "VIP C",
      "Lapangan Timur GSG",
      "Lapangan Upacara GSG"
    ];
    final times = [
      "08:00",
      "09:00",
      "10:00",
      "11:00",
      "12:00",
      "13:00",
      "14:00"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jadwal Ketersediaan Ruangan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Tempat/Waktu",
                        style: TextStyle(color: Colors.white)),
                  ),
                  ...times.map((t) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(t,
                            style: const TextStyle(color: Colors.white)),
                      )),
                ],
              ),
              ...rooms.map((room) => TableRow(
                    decoration: BoxDecoration(
                        color: room == "VIP A"
                            ? Colors.white
                            : Colors.green.shade50),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          room,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...times.map((t) {
                        if (room == "VIP A" && t == "09:00") {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Booked",
                                style: TextStyle(color: Colors.red)),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Available"),
                          );
                        }
                      }),
                    ],
                  ))
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
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
                  Image.asset('assets/images/logo.png', height: 40),
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/foto-profil-mahasiswa.jpg',
                    ),
                    radius: 20,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildScheduleTable(),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Isi Form Pengajuan di Bawah ini",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _namaPemesanController,
                              decoration: const InputDecoration(
                                  labelText: "Nama Pemesan"),
                            ),
                            TextField(
                              controller: _noHpController,
                              decoration:
                                  const InputDecoration(labelText: "No. Hp"),
                              keyboardType: TextInputType.phone,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Nama Ruangan",
                                hintText: widget.roomName,
                              ),
                              readOnly: true,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: "Tanggal Mulai",
                                      hintText: _tanggalMulai != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(_tanggalMulai!)
                                          : 'dd/mm/yyyy',
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.calendar_today),
                                        onPressed: () =>
                                            _selectDate(context, true),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: "Tanggal Selesai",
                                      hintText: _tanggalSelesai != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(_tanggalSelesai!)
                                          : 'dd/mm/yyyy',
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.calendar_today),
                                        onPressed: () =>
                                            _selectDate(context, false),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    decoration: const InputDecoration(
                                        labelText: "Jam Mulai"),
                                    value: _jamMulai,
                                    items: List.generate(24, (index) => index)
                                        .map((hour) {
                                      return DropdownMenuItem<int>(
                                        value: hour,
                                        child: Text(
                                            hour.toString().padLeft(2, '0') +
                                                ":00"),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _jamMulai = val;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    decoration: const InputDecoration(
                                        labelText: "Jam Selesai"),
                                    value: _jamSelesai,
                                    items: List.generate(24, (index) => index)
                                        .map((hour) {
                                      return DropdownMenuItem<int>(
                                        value: hour,
                                        child: Text(
                                            hour.toString().padLeft(2, '0') +
                                                ":00"),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _jamSelesai = val;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            TextField(
                              controller: _tujuanController,
                              decoration:
                                  const InputDecoration(labelText: "Tujuan"),
                              maxLines: 3,
                            ),
                            TextField(
                              controller: _namaOrganisasiController,
                              decoration: const InputDecoration(
                                  labelText: "Nama Organisasi"),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _resetForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: const Text("Reset Form",
                                      style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Tutup dialog konfirmasi

                                    // Buat objek booking
                                    Booking booking = Booking(
                                      nama: _namaPemesanController.text,
                                      noHp: _noHpController.text,
                                      ruangan: widget.roomName,
                                      tanggalMulai: DateFormat('dd/MM/yyyy')
                                          .format(_tanggalMulai!),
                                      tanggalSelesai: DateFormat('dd/MM/yyyy')
                                          .format(_tanggalSelesai!),
                                      jamMulai: "${_jamMulai!}:00",
                                      jamSelesai: "${_jamSelesai!}:00",
                                      tujuan: _tujuanController.text,
                                      organisasi:
                                          _namaOrganisasiController.text,
                                    );

                                    // Arahkan langsung ke BookingHistoryPage
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BookingHistoryPage(
                                                bookings: [booking]),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                  ),
                                  child: const Text("Submit Form",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
