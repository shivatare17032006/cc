import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../models/owner_order.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  final List<String> _statusOptions = ['Pending', 'In Progress', 'Done'];
  List<OwnerOrder> _orders = [];
  bool _isLoading = true;
  String? _error;

  String _safeStatus(String raw) {
    final value = raw.trim().toLowerCase();
    if (value == 'pending') return 'Pending';
    if (value == 'in progress' || value == 'preparing') return 'In Progress';
    if (value == 'done' || value == 'completed' || value == 'ready') return 'Done';
    return 'Pending';
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await ApiService.getOwnerOrders();
      if (!mounted) return;
      setState(() {
        _orders = list.map(OwnerOrder.fromJson).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _fmt(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Future<void> _updateStatus(OwnerOrder order, String status) async {
    try {
      final updatedMap = await ApiService.updateOwnerOrderStatus(
        orderId: order.id,
        status: status,
      );
      final updated = OwnerOrder.fromJson(updatedMap);
      if (!mounted) return;
      setState(() {
        final index = _orders.indexWhere((o) => o.id == order.id);
        if (index >= 0) {
          _orders[index] = updated;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _statusActionButton({
    required OwnerOrder order,
    required String selectedStatus,
    required String actionStatus,
    required IconData icon,
  }) {
    final isActive = selectedStatus == actionStatus;

    return FilledButton.icon(
      onPressed: isActive ? null : () => _updateStatus(order, actionStatus),
      style: FilledButton.styleFrom(
        backgroundColor: isActive ? Colors.orange.shade700 : Colors.orange.shade100,
        foregroundColor: isActive ? Colors.white : Colors.orange.shade900,
      ),
      icon: Icon(icon, size: 18),
      label: Text(actionStatus),
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
            ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(child: Text('No orders raised by students yet'));
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final order = _orders[index];
          final selectedStatus = _safeStatus(order.status);
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
                          order.orderId,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          selectedStatus,
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Student: ${order.studentName}'),
                  Text('Email: ${order.studentEmail}'),
                  Text('Created: ${_fmt(order.createdAt)}'),
                  Text('Total: Rs ${order.totalAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: order.items.map((item) => Chip(label: Text(item))).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Update Order Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statusActionButton(
                        order: order,
                        selectedStatus: selectedStatus,
                        actionStatus: _statusOptions[0],
                        icon: Icons.pending_actions,
                      ),
                      _statusActionButton(
                        order: order,
                        selectedStatus: selectedStatus,
                        actionStatus: _statusOptions[1],
                        icon: Icons.restaurant,
                      ),
                      _statusActionButton(
                        order: order,
                        selectedStatus: selectedStatus,
                        actionStatus: _statusOptions[2],
                        icon: Icons.check_circle,
                      ),
                    ],
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
