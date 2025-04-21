import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'room_list_page.dart';

class RoomBookingPage extends StatefulWidget {
  final String selectedRoom;

  const RoomBookingPage({Key? key, required this.selectedRoom})
    : super(key: key);

  @override
  _RoomBookingPageState createState() => _RoomBookingPageState();
}

class _RoomBookingPageState extends State<RoomBookingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Dummy jadwal ketersediaan
  final List<String> times = [
    "08:00",
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
  ];
  final Map<String, Map<String, String>> schedule = {
    "VIP A": {"09:00": "Booked"},
    "VIP B": {},
    "VIP C": {},
    "Lapangan Timur GSG": {},
    "Lapangan Upacara GSG": {},
  };

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _phoneController.clear();
    _orgController.clear();
    _purposeController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
      _startTime = null;
      _endTime = null;
    });
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header yang seragam dengan halaman Daftar Ruangan
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
            SizedBox(height: 20),

            // Jadwal Ketersediaan Ruangan
            Text(
              "Jadwal Ketersediaan Ruangan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildScheduleTable(),

            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, "Nama Pemesan"),
                  _buildTextField(
                    _phoneController,
                    "No. HP",
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    TextEditingController(text: widget.selectedRoom),
                    "Nama Ruangan",
                    enabled: false,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          "Tanggal Mulai",
                          _startDate,
                          () => _selectDate(true),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildDateField(
                          "Tanggal Selesai",
                          _endDate,
                          () => _selectDate(false),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeField(
                          "Jam Mulai",
                          _startTime,
                          () => _selectTime(true),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildTimeField(
                          "Jam Selesai",
                          _endTime,
                          () => _selectTime(false),
                        ),
                      ),
                    ],
                  ),

                  _buildTextField(_orgController, "Nama Organisasi"),
                  _buildTextField(_purposeController, "Tujuan", maxLines: 3),

                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _resetForm,
                          child: Text(
                            "Reset Form",
                            style: TextStyle(
                              color: Colors.white,
                            ), // Teks berwarna putih
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey, // Latar belakang abu-abu
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Lanjut ke submit logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Form berhasil dikirim!'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Submit Form",
                            style: TextStyle(
                              color: Colors.white,
                            ), // Teks berwarna putih
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blue[800], // Latar belakang biru tua
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigasi kembali ke halaman daftar ruangan
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Kembali",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Latar belakang biru
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator:
            (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: date != null ? DateFormat('dd/MM/yyyy').format(date) : '',
          ),
          validator:
              (value) =>
                  (value == null || value.isEmpty) ? 'Wajib diisi' : null,
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: time != null ? time.format(context) : '',
          ),
          validator:
              (value) =>
                  (value == null || value.isEmpty) ? 'Wajib diisi' : null,
        ),
      ),
    );
  }

  Widget _buildScheduleTable() {
    return Table(
      border: TableBorder.all(),
      columnWidths: {0: FixedColumnWidth(140)},
      children: [
        TableRow(
          children: [
            TableCell(child: _buildTableCell("Tempat/Waktu", bold: true)),
            ...times.map((t) => _buildTableCell(t, bold: true)).toList(),
          ],
        ),
        ...schedule.entries.map((entry) {
          return TableRow(
            children: [
              _buildTableCell(entry.key),
              ...times.map((time) {
                String status = entry.value[time] ?? "Available";
                return _buildTableCell(
                  status,
                  color:
                      status == "Booked" ? Colors.red[100] : Colors.blue[100],
                );
              }).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableCell(String text, {Color? color, bool bold = false}) {
    return Container(
      padding: EdgeInsets.all(8),
      color: color ?? Colors.white,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
