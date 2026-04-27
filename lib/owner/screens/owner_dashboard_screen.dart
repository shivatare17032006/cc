import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../models/owner_dashboard.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  OwnerDashboard? _dashboard;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final json = await ApiService.getOwnerRevenueDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = OwnerDashboard.fromJson(json);
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

  Widget _metricCard(String title, String value, {Color? color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topCustomerChart(List<TopCustomer> entries) {
    if (entries.isEmpty) {
      return _metricCard('Top 5 Customers', 'No completed orders yet');
    }

    final maxSpent = entries
        .map((e) => e.totalSpent)
        .fold<double>(0, (prev, curr) => curr > prev ? curr : prev);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 5 Customers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) {
              final ratio = maxSpent <= 0 ? 0.0 : (entry.totalSpent / maxSpent).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.name} • ${entry.totalOrders} orders • Rs ${entry.totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: Colors.orange.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _topItemsChart(List<TopItem> entries) {
    if (entries.isEmpty) {
      return _metricCard('Top 5 Items', 'No completed orders yet');
    }

    final maxQty = entries
        .map((e) => e.totalQuantity)
        .fold<int>(0, (prev, curr) => curr > prev ? curr : prev)
        .toDouble();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 5 Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) {
              final ratio = maxQty <= 0 ? 0.0 : (entry.totalQuantity / maxQty).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.itemName} • ${entry.totalQuantity} sold • Rs ${entry.totalRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: Colors.orange.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange.shade400),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _loadDashboard, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final data = _dashboard;
    if (data == null) {
      return const Scaffold(body: Center(child: Text('No dashboard data')));
    }

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _metricCard('Revenue (Today)', 'Rs ${data.dayRevenue.toStringAsFixed(2)}', color: Colors.orange.shade700),
            _metricCard('Revenue (This Week)', 'Rs ${data.weekRevenue.toStringAsFixed(2)}', color: Colors.orange.shade700),
            _metricCard('Revenue (This Month)', 'Rs ${data.monthRevenue.toStringAsFixed(2)}', color: Colors.orange.shade700),
            const SizedBox(height: 8),
            _topCustomerChart(data.topCustomers),
            _topItemsChart(data.topItems),
          ],
        ),
      ),
    );
  }
}
