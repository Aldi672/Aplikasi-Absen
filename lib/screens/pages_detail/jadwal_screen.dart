import 'package:aplikasi_absen/api/get_history.dart';
import 'package:aplikasi_absen/models/get_history_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class RiwayatAbsensiContent extends StatefulWidget {
  final VoidCallback? onDeleteSuccess;
  const RiwayatAbsensiContent({super.key, this.onDeleteSuccess});

  @override
  RiwayatAbsensiContentState createState() => RiwayatAbsensiContentState();
}

class RiwayatAbsensiContentState extends State<RiwayatAbsensiContent> {
  List<Datum> _historyData = [];
  List<Datum> _filteredHistory = [];
  bool _isLoading = true;
  bool _isLocaleInitialized = false;

  bool _isDeleting = false;
  String? _deletingId;

  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  // Initialize Indonesian locale first
  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('id_ID', null);
      if (mounted) {
        setState(() {
          _isLocaleInitialized = true;
        });
        fetchHistory();
      }
    } catch (e) {
      // Fallback to default locale if Indonesian locale fails
      await initializeDateFormatting();
      if (mounted) {
        setState(() {
          _isLocaleInitialized = true;
        });
        fetchHistory();
      }
    }
  }

  void _generateLast5Days() {
    // Removed - no longer needed
  }

  void _onCalendarDaySelected(DateTime selectedDate, DateTime focusedDate) {
    _filterByDate(selectedDate);
  }

  Future<void> _handleDelete(String id, DateTime date) async {
    setState(() {
      _isDeleting = true;
      _deletingId = id;
    });

    try {
      final response = await HistoryAPI.deleteHistory(id);

      if (response != null && response.data != null) {
        setState(() {
          _historyData.removeWhere((item) => item.id.toString() == id);
          _filterByDate(date);
        });
        widget.onDeleteSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Riwayat absensi berhasil dihapus"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isDeleting = false;
        _deletingId = null;
      });
    }
  }

  Future<void> fetchHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final result = await HistoryAPI.getHistory();
    if (result != null && result.data != null) {
      setState(() {
        _historyData = result.data!;
        _filteredHistory = _historyData;
        _filterByDate(_selectedDay);
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

  String _formatDate(DateTime date) {
    if (!_isLocaleInitialized) return '...';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hari Ini';
    } else if (targetDate == yesterday) {
      return 'Kemarin';
    } else {
      try {
        return DateFormat('dd MMM', 'id_ID').format(date);
      } catch (e) {
        // Fallback to default locale if Indonesian fails
        return DateFormat('dd MMM').format(date);
      }
    }
  }

  String _formatDayName(DateTime date) {
    if (!_isLocaleInitialized) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '';
    } else {
      try {
        return DateFormat('EEE', 'id_ID').format(date);
      } catch (e) {
        // Fallback to default locale if Indonesian fails
        return DateFormat('EEE').format(date);
      }
    }
  }

  String _formatFullDate(DateTime date) {
    if (!_isLocaleInitialized) return 'Loading...';

    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      // Fallback to default locale if Indonesian fails
      return DateFormat('EEEE, dd MMMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while locale is being initialized
    if (!_isLocaleInitialized) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Memuat aplikasi...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Riwayat Absensi",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lihat riwayat absensi 5 hari terakhir",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Calendar untuk pilih tanggal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Pilih Tanggal",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.blue.shade600,
                              onPrimary: Colors.black45,
                              onSurface: Colors.black87,
                            ),
                          ),
                          child: CalendarDatePicker(
                            initialDate: _selectedDay,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),

                            onDateChanged: (DateTime selectedDate) {
                              _filterByDate(selectedDate);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Konten riwayat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header tanggal yang dipilih
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatFullDate(_selectedDay),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List riwayat
                    if (_isLoading)
                      Container(
                        height: 200,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                "Memuat data...",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_filteredHistory.isEmpty)
                      Container(
                        height: 150,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Tidak ada absensi pada tanggal ini",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredHistory.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey.shade200),
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
                            isDeleting: _deletingId == history.id!.toString(),
                            onDelete: () async {
                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Hapus Absensi?'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus riwayat absensi ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String id;
  final String date;
  final String status;
  final String? alasanIzin;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const _HistoryItem({
    required this.id,
    required this.date,
    required this.status,
    this.alasanIzin,
    this.onDelete,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMasuk = status.toLowerCase().contains('masuk');
    final bool isIzin = status.toLowerCase().contains('izin');

    final Color statusColor = isIzin
        ? Colors.blue.shade600
        : isMasuk
        ? Colors.green.shade600
        : Colors.orange.shade600;

    final IconData statusIcon = isIzin
        ? Icons.edit_calendar_rounded
        : isMasuk
        ? Icons.login_rounded
        : Icons.logout_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Status icon dengan background
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                if (alasanIzin != null && alasanIzin!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Alasan: $alasanIzin",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Delete button
          if (onDelete != null)
            isDeleting
                ? Container(
                    width: 40,
                    height: 40,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      onPressed: onDelete,
                    ),
                  ),
        ],
      ),
    );
  }
}
