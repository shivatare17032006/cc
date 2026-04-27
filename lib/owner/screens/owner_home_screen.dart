import 'package:flutter/material.dart';

import '../../screens/login_screen.dart';
import '../../services/api_service.dart';
import 'owner_bookings_screen.dart';
import 'owner_dashboard_screen.dart';
import 'owner_notices_screen.dart';
import 'owner_orders_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = [
    OwnerOrdersScreen(),
    OwnerBookingsScreen(),
    OwnerNoticesScreen(),
    OwnerDashboardScreen(),
  ];

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Canteen Owner Panel'),
        backgroundColor: Colors.orange.shade700,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (value) => setState(() => _selectedIndex = value),
        selectedItemColor: Colors.orange.shade800,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_email_read),
            label: 'Notices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Revenue',
          ),
        ],
      ),
    );
  }
}
