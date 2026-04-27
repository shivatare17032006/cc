class OwnerOrder {
  const OwnerOrder({
    required this.id,
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.studentName,
    required this.studentEmail,
    required this.items,
  });

  factory OwnerOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);
    final itemNames = rawItems.map((item) {
      if (item is Map<String, dynamic>) {
        final quantity = int.tryParse((item['quantity'] ?? '1').toString()) ?? 1;
        final name = (item['name'] ?? '').toString();
        return '$name x$quantity';
      }
      return item.toString();
    }).toList();

    final student = (json['student'] as Map<String, dynamic>? ?? {});

    return OwnerOrder(
      id: (json['_id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      status: _normalizeStatus((json['status'] ?? 'Pending').toString()),
      totalAmount: _toDouble(json['totalAmount']),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      studentName: (student['name'] ?? 'Unknown').toString(),
      studentEmail: (student['email'] ?? '').toString(),
      items: itemNames,
    );
  }

  final String id;
  final String orderId;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String studentName;
  final String studentEmail;
  final List<String> items;

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _normalizeStatus(String raw) {
    final value = raw.trim().toLowerCase();

    if (value == 'pending') {
      return 'Pending';
    }

    if (value == 'in progress' || value == 'preparing') {
      return 'In Progress';
    }

    if (value == 'done' || value == 'completed' || value == 'ready') {
      return 'Done';
    }

    return 'Pending';
  }
}
