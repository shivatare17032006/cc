import 'package:flutter/material.dart';

import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int? _selectedTableNumber;
  String? _selectedSlot;
  String? _selectedDate;
  int _partySize = 1;
  bool _isLoadingAvailability = false;
  bool _isSubmittingBooking = false;
  bool _isLoadingMyBookings = true;
  Set<int> _unavailableTables = <int>{};
  List<_BookingRecord> _myBookings = [];
  String? _bookingError;

  final List<int> _tables = List.generate(15, (index) => index + 1);
  final List<String> _timeSlots = [
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 1:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
    '6:00 PM - 7:00 PM',
    '7:00 PM - 8:00 PM',
    '8:00 PM - 9:00 PM',
  ];

  final Map<int, int> _tableCapacity = {
    1: 4,
    2: 4,
    3: 4,
    4: 4,
    5: 4,
    6: 4,
    7: 4,
    8: 4,
    9: 4,
    10: 4,
    11: 6,
    12: 6,
    13: 6,
    14: 6,
    15: 6,
  };

  void _showMessage(String text, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: backgroundColor,
      ),
    );
  }

  BoxDecoration _panelDecoration({required double alpha, required double spread, required double blur}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: alpha),
          spreadRadius: spread,
          blurRadius: blur,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard({required Widget child, required double alpha, required double spread, required double blur}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(alpha: alpha, spread: spread, blur: blur),
      child: child,
    );
  }

  Widget _buildTableTile(int tableNumber) {
    final seatLabel = 'Table $tableNumber';
    final isUnavailable = _unavailableTables.contains(tableNumber);
    final isSelected = _selectedTableNumber == tableNumber;

    return GestureDetector(
      onTap: isUnavailable
          ? null
          : () {
              setState(() {
                _selectedTableNumber = tableNumber;
                final capacity = _tableCapacity[tableNumber] ?? 4;
                if (_partySize > capacity) {
                  _partySize = capacity;
                }
              });
            },
      child: Container(
        decoration: BoxDecoration(
          color: isUnavailable
              ? Colors.grey.shade300
              : isSelected
                  ? Colors.orange.shade500
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            isUnavailable ? '$seatLabel\nBooked' : seatLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isUnavailable
                      ? Colors.black54
                      : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotChip(String slot) {
    final selected = _selectedSlot == slot;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSlot = slot;
        });
        _loadAvailability();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.orange.shade500 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          slot,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard() {
    return _buildInfoCard(
      alpha: 0.1,
      spread: 5,
      blur: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Your Table',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Select Date'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_selectedDate ?? 'Choose Date'),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = _formatDate(picked);
                  });
                  await _loadAvailability();
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Select Table/Seat'),
          const SizedBox(height: 10),
          if (_isLoadingAvailability)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(),
            ),
          if (_bookingError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _bookingError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _tables.length,
            itemBuilder: (context, index) => _buildTableTile(_tables[index]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Party Size',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _partySize,
                items: _partySizeOptionsForSelectedTable()
                    .map(
                      (size) => DropdownMenuItem<int>(
                        value: size,
                        child: Text(size.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _partySize = value;
                  });
                },
              ),
              const SizedBox(width: 10),
              if (_selectedTableNumber != null)
                Text(
                  'Capacity ${_tableCapacity[_selectedTableNumber] ?? 4}',
                  style: const TextStyle(color: Colors.black54),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Select Time Slot'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _timeSlots.map(_buildTimeSlotChip).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmittingBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade500,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isSubmittingBooking
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(_BookingRecord booking) {
    final active = booking.status == 'booked';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${booking.tableLabel} • ${booking.timeSlot}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.blueGrey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  active ? 'Booked' : 'Released',
                  style: TextStyle(
                    color: active ? Colors.green.shade700 : Colors.blueGrey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Date: ${booking.bookingDate}'),
          Text('Party Size: ${booking.partySize}'),
          Text('Created: ${_formatDateTime(booking.createdAtRaw)}'),
          Text('Auto-release in: ${_remainingLabel(booking.expiresAt)}'),
          if (booking.releaseReason.isNotEmpty)
            Text('Release reason: ${booking.releaseReason}'),
          if (active) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _releaseBooking(booking.id),
                icon: const Icon(Icons.lock_open),
                label: const Text('Release Seat'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyBookingsCard() {
    return _buildInfoCard(
      alpha: 0.08,
      spread: 2,
      blur: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_available, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'My Bookings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bookings auto-release after 1 hour if not manually released.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          if (_isLoadingMyBookings)
            const Center(child: CircularProgressIndicator())
          else if (_myBookings.isEmpty)
            const Text('No bookings yet.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _myBookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _buildBookingItem(_myBookings[index]),
            ),
        ],
      ),
    );
  }

  List<int> _partySizeOptionsForSelectedTable() {
    final capacity = _selectedTableNumber == null ? 6 : (_tableCapacity[_selectedTableNumber] ?? 4);
    return List.generate(capacity, (index) => index + 1);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final minute = parsed.minute.toString().padLeft(2, '0');
    final suffix = parsed.hour >= 12 ? 'PM' : 'AM';
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')} $hour:$minute $suffix';
  }

  String _remainingLabel(DateTime? expiresAt) {
    if (expiresAt == null) {
      return 'N/A';
    }
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) {
      return 'Expired';
    }
    final mins = diff.inMinutes;
    final secs = diff.inSeconds % 60;
    return '${mins}m ${secs}s';
  }

  bool get _canLoadAvailability => _selectedDate != null && _selectedSlot != null;

  Future<void> _loadAvailability() async {
    if (!_canLoadAvailability) {
      return;
    }

    setState(() {
      _isLoadingAvailability = true;
      _bookingError = null;
    });

    try {
      final unavailable = await ApiService.getUnavailableTables(
        bookingDate: _selectedDate!,
        timeSlot: _selectedSlot!,
      );
      if (!mounted) return;

      setState(() {
        _unavailableTables = unavailable.toSet();
        if (_selectedTableNumber != null && _unavailableTables.contains(_selectedTableNumber)) {
          _selectedTableNumber = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bookingError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingAvailability = false);
      }
    }
  }

  Future<void> _loadMyBookings() async {
    setState(() => _isLoadingMyBookings = true);
    try {
      final bookingMaps = await ApiService.getMyBookings();
      if (!mounted) return;
      setState(() {
        _myBookings = bookingMaps.map(_BookingRecord.fromJson).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _myBookings = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingMyBookings = false);
      }
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null || _selectedSlot == null || _selectedTableNumber == null) {
      _showMessage('Please select date, table and time slot');
      return;
    }

    if (_unavailableTables.contains(_selectedTableNumber)) {
      _showMessage('Selected table is already booked for this slot');
      return;
    }

    setState(() => _isSubmittingBooking = true);

    try {
      final booking = await ApiService.createBooking(
        bookingDate: _selectedDate!,
        timeSlot: _selectedSlot!,
        tableNumber: _selectedTableNumber!,
        partySize: _partySize,
      );

      final created = _BookingRecord.fromJson(booking);
      if (!mounted) return;

      await _loadAvailability();
      await _loadMyBookings();

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Booking Confirmed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${created.bookingDate}'),
              Text('Table: ${created.tableLabel}'),
              Text('Time: ${created.timeSlot}'),
              Text('Party Size: ${created.partySize}'),
              const SizedBox(height: 8),
              const Text('Note: This booking auto-releases after 1 hour.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedTableNumber = null;
                  _selectedSlot = null;
                  _selectedDate = null;
                  _partySize = 1;
                  _unavailableTables = <int>{};
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
      await _loadAvailability();
    } finally {
      if (mounted) {
        setState(() => _isSubmittingBooking = false);
      }
    }
  }

  Future<void> _releaseBooking(String id) async {
    try {
      await ApiService.releaseBooking(id);
      if (!mounted) return;
      await _loadMyBookings();
      await _loadAvailability();
      if (!mounted) return;
      _showMessage('Booking released successfully', backgroundColor: Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMyBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingCard(),
            const SizedBox(height: 18),
            _buildMyBookingsCard(),
          ],
        ),
      ),
    );
  }
}

class _BookingRecord {
  _BookingRecord({
    required this.id,
    required this.bookingDate,
    required this.timeSlot,
    required this.tableLabel,
    required this.partySize,
    required this.status,
    required this.releaseReason,
    required this.createdAtRaw,
    required this.expiresAt,
  });

  factory _BookingRecord.fromJson(Map<String, dynamic> json) {
    return _BookingRecord(
      id: (json['_id'] ?? '').toString(),
      bookingDate: (json['bookingDate'] ?? '').toString(),
      timeSlot: (json['timeSlot'] ?? '').toString(),
      tableLabel: (json['tableLabel'] ?? 'Table').toString(),
      partySize: int.tryParse((json['partySize'] ?? '1').toString()) ?? 1,
      status: (json['status'] ?? 'released').toString(),
      releaseReason: (json['releaseReason'] ?? '').toString(),
      createdAtRaw: (json['createdAt'] ?? '').toString(),
      expiresAt: DateTime.tryParse((json['expiresAt'] ?? '').toString()),
    );
  }

  final String id;
  final String bookingDate;
  final String timeSlot;
  final String tableLabel;
  final int partySize;
  final String status;
  final String releaseReason;
  final String createdAtRaw;
  final DateTime? expiresAt;
}