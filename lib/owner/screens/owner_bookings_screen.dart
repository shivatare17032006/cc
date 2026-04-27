import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await ApiService.getOwnerBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }
    return value;
  }

  Future<void> _releaseBooking(Map<String, dynamic> booking) async {
    try {
      final updated = await ApiService.releaseOwnerBooking(
        bookingId: (booking['_id'] ?? '').toString(),
      );
      if (!mounted) return;

      setState(() {
        final index = _bookings.indexWhere((b) => b['_id'] == booking['_id']);
        if (index >= 0) {
          _bookings[index] = updated;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seat released successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildStatusChip(String status) {
    final lowered = status.toLowerCase();
    final color = lowered == 'booked' ? Colors.orange.shade700 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _loadBookings, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return const Center(child: Text('No table bookings available'));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: _bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final booking = _bookings[index];
          final student = (booking['student'] as Map<String, dynamic>? ?? {});
          final status = (booking['status'] ?? '').toString();
          final isBooked = status.toLowerCase() == 'booked';

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${booking['tableLabel'] ?? 'Table'} • ${booking['timeSlot'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      _buildStatusChip(status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Date: ${_formatDate((booking['bookingDate'] ?? '').toString())}'),
                  Text('Party Size: ${(booking['partySize'] ?? 0).toString()}'),
                  Text('Student: ${(student['name'] ?? 'Unknown').toString()}'),
                  Text('Email: ${(student['email'] ?? '').toString()}'),
                  const SizedBox(height: 10),
                  if (isBooked)
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => _releaseBooking(booking),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                        ),
                        icon: const Icon(Icons.event_seat),
                        label: const Text('Release Seat'),
                      ),
                    )
                  else
                    Text(
                      'Released: ${(booking['releaseReason'] ?? 'manual').toString()}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: _buildBody(),
    );
  }
}
