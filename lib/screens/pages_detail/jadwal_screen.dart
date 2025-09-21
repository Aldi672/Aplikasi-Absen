import 'package:aplikasi_absen/api/get_history.dart';
import 'package:aplikasi_absen/models/get_history_models.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class RiwayatAbsensiContent extends StatefulWidget {
  const RiwayatAbsensiContent({super.key});

  @override
  State<RiwayatAbsensiContent> createState() => _RiwayatAbsensiContentState();
}

class _RiwayatAbsensiContentState extends State<RiwayatAbsensiContent> {
  List<Datum> _historyData = [];
  List<Datum> _filteredHistory = [];
  bool _isLoading = true;

  bool _isDeleting = false;
  String? _deletingId;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _handleDelete(String id, DateTime date) async {
    // Set state untuk menampilkan indikator loading
    setState(() {
      _isDeleting = true;
      _deletingId = id;
    });

    try {
      final response = await HistoryAPI.deleteHistory(id);

      if (response != null && response.data != null) {
        // Hapus item dari daftar lokal setelah berhasil dari API
        setState(() {
          _historyData.removeWhere((item) => item.id.toString() == id);
          _filterByDate(date); // Perbarui tampilan setelah menghapus
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Riwayat absensi berhasil dihapus"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response?.message ?? "Gagal menghapus riwayat");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Sembunyikan indikator loading
      setState(() {
        _isDeleting = false;
        _deletingId = null;
      });
    }
  }

  Future<void> _fetchHistory() async {
    final result = await HistoryAPI.getHistory();
    if (result != null && result.data != null) {
      setState(() {
        _historyData = result.data!;
        _filteredHistory = _historyData; // default tampil semua
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterByDate(DateTime selectedDate) {
    setState(() {
      _selectedDay = selectedDate;
      _focusedDay = selectedDate;

      _filteredHistory = _historyData.where((history) {
        if (history.attendanceDate == null) return false;

        final date = DateTime(
          history.attendanceDate!.year,
          history.attendanceDate!.month,
          history.attendanceDate!.day,
        );

        return date ==
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📅 Kalender filter
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDay != null &&
                day.year == _selectedDay!.year &&
                day.month == _selectedDay!.month &&
                day.day == _selectedDay!.day,
            onDaySelected: (selectedDay, focusedDay) {
              _filterByDate(selectedDay);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              "Riwayat Absensi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "Tidak ada absensi pada tanggal ini.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true, // biar muat dalam scroll
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredHistory.length,
              itemBuilder: (context, index) {
                final history = _filteredHistory[index];

                final String dateText =
                    "${history.attendanceDate?.toLocal().toString().split(' ')[0]} "
                    "${history.checkInTime ?? history.checkOutTime ?? ''}";

                final String statusText = history.status == "izin"
                    ? "Izin"
                    : history.checkInTime != null &&
                          history.checkOutTime == null
                    ? "Absen Masuk"
                    : history.checkOutTime != null
                    ? "Absen Keluar"
                    : "Tidak diketahui";

                return _HistoryItem(
                  id: history.id!.toString(),
                  date: dateText,
                  status: statusText,
                  alasanIzin: history.alasanIzin,
                  isFirst: index == 0,
                  isLast: index == _filteredHistory.length - 1,
                  isDeleting: _deletingId == history.id!.toString(),
                  onDelete: () async {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Absensi?'),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus riwayat absensi ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // Panggil fungsi hapus hanya jika pengguna mengkonfirmasi
                      _handleDelete(
                        history.id!.toString(),
                        history.attendanceDate!,
                      );
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String id;
  final String date;
  final String status;
  final String? alasanIzin;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const _HistoryItem({
    required this.id,
    required this.date,
    required this.status,
    this.alasanIzin,
    required this.isFirst,
    required this.isLast,
    this.onDelete,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMasuk = status.toLowerCase().contains('masuk');
    final bool isIzin = status.toLowerCase().contains('izin');

    final Color statusColor = isIzin
        ? Colors.blue
        : isMasuk
        ? Colors.green.shade600
        : Colors.orange.shade800;

    final IconData statusIcon = isIzin
        ? Icons.edit_calendar
        : isMasuk
        ? Icons.arrow_downward
        : Icons.arrow_upward;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : Colors.grey[300],
                  ),
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: Colors.white, size: 16),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),

          // Card Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        if (onDelete != null)
                          isDeleting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: onDelete,
                                ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    if (alasanIzin != null && alasanIzin!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Alasan: $alasanIzin",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
