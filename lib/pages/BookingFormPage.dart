import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BookingHistoryPage.dart';
import 'package:tubes1_apb/models/booking_model.dart';
import 'package:tubes1_apb/models/room_model.dart';
import 'package:tubes1_apb/services/booking_service.dart';
import 'package:tubes1_apb/services/room_service.dart';
import '../widgets/custom_app_bar.dart';

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
  final TextEditingController _namaOrganisasiController = TextEditingController();
  final RoomService _roomService = RoomService();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  int? _jamMulai;
  int? _jamSelesai;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkRoomExists();
  }

  // Cek apakah ruangan masih ada di database
  Future<void> _checkRoomExists() async {
    try {
      List<Room> rooms = await _roomService.getAllRooms().first;
      bool roomExists = rooms.any((room) => room.name == widget.roomName);

      if (!roomExists) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showRoomNotFoundDialog();
        });
      }
    } catch (e) {
      print('Error checking room existence: $e');
    }
  }

  void _showRoomNotFoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Ruangan Tidak Tersedia"),
        content: Text("Ruangan '${widget.roomName}' sudah tidak tersedia. Silakan pilih ruangan lain."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke Dashboard
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Ambil data booking dari Firestore untuk tanggal tertentu
  Stream<QuerySnapshot> _getBookingsForDate(DateTime date) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('tanggalMulai', isEqualTo: formattedDate)
        .snapshots();
  }

  // Cek apakah ruangan dan jam tertentu sudah dibooking
  bool _isRoomBooked(List<QueryDocumentSnapshot> bookings, String roomName, String time) {
    for (var booking in bookings) {
      Map<String, dynamic> data = booking.data() as Map<String, dynamic>;
      if (data['ruangan'] == roomName) {
        String jamMulai = data['jamMulai'];
        String jamSelesai = data['jamSelesai'];

        // Parse jam mulai dan selesai
        int startHour = int.parse(jamMulai.split(':')[0]);
        int endHour = int.parse(jamSelesai.split(':')[0]);
        int currentHour = int.parse(time.split(':')[0]);

        // Cek apakah jam saat ini berada dalam rentang booking
        if (currentHour >= startHour && currentHour < endHour) {
          return true;
        }
      }
    }
    return false;
  }

  // Validasi konflik booking sebelum submit
  Future<bool> _checkBookingConflict() async {
    try {
      String formattedDate = DateFormat('dd/MM/yyyy').format(_tanggalMulai!);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('ruangan', isEqualTo: widget.roomName)
          .where('tanggalMulai', isEqualTo: formattedDate)
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        int existingStartHour = int.parse(data['jamMulai'].split(':')[0]);
        int existingEndHour = int.parse(data['jamSelesai'].split(':')[0]);

        // Cek overlap jam
        if (_jamMulai! < existingEndHour && _jamSelesai! > existingStartHour) {
          _showConflictDialog(data);
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking booking conflict: $e');
      return false;
    }
  }

  void _showConflictDialog(Map<String, dynamic> conflictData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Jadwal Bentrok"),
        content: Text(
            "Waktu yang dipilih bertentangan dengan booking:\n\n"
                "Nama: ${conflictData['nama']}\n"
                "Organisasi: ${conflictData['organisasi']}\n"
                "Jam: ${conflictData['jamMulai']} - ${conflictData['jamSelesai']}\n\n"
                "Silakan pilih waktu lain."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    final times = [
      "09:00", "10:00", "11:00", "12:00", "13:00",
      "14:00", "15:00", "16:00", "17:00", "18:00"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Jadwal Ketersediaan Ruangan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // StreamBuilder untuk data ruangan dari RoomService
        StreamBuilder<List<Room>>(
          stream: _roomService.getAllRooms(),
          builder: (context, roomSnapshot) {
            if (roomSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (roomSnapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Error loading rooms: ${roomSnapshot.error}'),
                ),
              );
            }

            if (!roomSnapshot.hasData || roomSnapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Tidak ada ruangan tersedia'),
                ),
              );
            }

            // Ambil nama ruangan dari data RoomService
            List<String> roomNames = roomSnapshot.data!
                .map((room) => room.name)
                .toList();

            return StreamBuilder<QuerySnapshot>(
              stream: _getBookingsForDate(_selectedDate),
              builder: (context, bookingSnapshot) {
                List<QueryDocumentSnapshot> bookings = [];

                if (bookingSnapshot.hasData) {
                  bookings = bookingSnapshot.data!.docs;
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      // Header row
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Tempat/Waktu",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          ...times.map((time) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              time,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          )),
                        ],
                      ),

                      // Data rows - menggunakan data ruangan dari database
                      ...roomNames.map((roomName) => TableRow(
                        decoration: BoxDecoration(
                          color: roomName == widget.roomName
                              ? Colors.blue.shade50
                              : Colors.white,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              roomName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: roomName == widget.roomName
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                          ),
                          ...times.map((time) {
                            bool isBooked = _isRoomBooked(bookings, roomName, time);
                            bool isSelectedRoom = roomName == widget.roomName;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8
                                ),
                                decoration: BoxDecoration(
                                  color: isBooked
                                      ? Colors.red.shade100
                                      : (isSelectedRoom
                                      ? Colors.green.shade100
                                      : Colors.transparent),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isBooked ? "Booked" : "Available",
                                  style: TextStyle(
                                    color: isBooked
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }),
                        ],
                      )),
                    ],
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 8),

        // Legend
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            const Text("Sudah dibooking", style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            const Text("Tersedia", style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            const Text("Ruangan dipilih", style: TextStyle(fontSize: 12)),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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

  bool _validateForm() {
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
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            const CustomAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Tabel jadwal dinamis
                      _buildScheduleTable(),

                      // Form booking
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
                            Text(
                              "Form Booking untuk ${widget.roomName}",
                              style: const TextStyle(
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
                                    items: List.generate(10, (index) => index + 9)
                                        .map((hour) {
                                      return DropdownMenuItem<int>(
                                        value: hour,
                                        child: Text(
                                            hour.toString().padLeft(2, '0') + ":00"),
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
                                    items: List.generate(10, (index) => index + 9)
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
                                  onPressed: () async {
                                    if (_validateForm()) {
                                      // Cek konflik booking
                                      bool noConflict = await _checkBookingConflict();
                                      if (!noConflict) return;

                                      // Buat objek booking
                                      Booking booking = Booking(
                                        nama: _namaPemesanController.text,
                                        noHp: _noHpController.text,
                                        ruangan: widget.roomName,
                                        tanggalMulai: DateFormat('dd/MM/yyyy').format(_tanggalMulai!),
                                        tanggalSelesai: DateFormat('dd/MM/yyyy').format(_tanggalSelesai!),
                                        jamMulai: "${_jamMulai!}:00",
                                        jamSelesai: "${_jamSelesai!}:00",
                                        tujuan: _tujuanController.text,
                                        organisasi: _namaOrganisasiController.text,
                                      );

                                      try {
                                        // Tampilkan indicator loading
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          },
                                        );

                                        // Simpan ke Firebase
                                        BookingService bookingService = BookingService();
                                        Booking savedBooking = await bookingService.saveBooking(booking);

                                        // Tutup dialog loading
                                        Navigator.pop(context);

                                        // Tampilkan pesan sukses
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Booking berhasil disimpan! Tabel jadwal akan diperbarui otomatis."),
                                            backgroundColor: Colors.green,
                                          ),
                                        );

                                        // Reset form
                                        _resetForm();

                                        // Navigasi ke halaman riwayat
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BookingHistoryPage(),
                                          ),
                                        );
                                      } catch (e) {
                                        // Tutup dialog loading
                                        Navigator.pop(context);

                                        // Tampilkan pesan error
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Error: $e"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                  ),
                                  child: const Text("Submit Form", style: TextStyle(color: Colors.white)),
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