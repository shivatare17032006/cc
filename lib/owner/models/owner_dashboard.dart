class OwnerDashboard {
  const OwnerDashboard({
    required this.dayRevenue,
    required this.weekRevenue,
    required this.monthRevenue,
    this.topCustomers = const [],
    this.topItems = const [],
  });

  factory OwnerDashboard.fromJson(Map<String, dynamic> json) {
    final revenue = (json['revenue'] as Map<String, dynamic>? ?? {});
    final topCustomersRaw = (json['topCustomers'] as List<dynamic>? ?? []);
    final topItemsRaw = (json['topItems'] as List<dynamic>? ?? []);

    return OwnerDashboard(
      dayRevenue: _toDouble(revenue['day']),
      weekRevenue: _toDouble(revenue['week']),
      monthRevenue: _toDouble(revenue['month']),
      topCustomers: topCustomersRaw
          .whereType<Map<String, dynamic>>()
          .map(TopCustomer.fromJson)
          .toList(),
      topItems: topItemsRaw
          .whereType<Map<String, dynamic>>()
          .map(TopItem.fromJson)
          .toList(),
    );
  }

  final double dayRevenue;
  final double weekRevenue;
  final double monthRevenue;
  final List<TopCustomer> topCustomers;
  final List<TopItem> topItems;

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString()) ?? 0;
  }
}

class TopCustomer {
  const TopCustomer({
    required this.name,
    required this.totalOrders,
    required this.totalSpent,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      name: (json['name'] ?? 'Unknown').toString(),
      totalOrders: OwnerDashboard._toInt(json['totalOrders']),
      totalSpent: OwnerDashboard._toDouble(json['totalSpent']),
    );
  }

  final String name;
  final int totalOrders;
  final double totalSpent;
}

class TopItem {
  const TopItem({
    required this.itemName,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  factory TopItem.fromJson(Map<String, dynamic> json) {
    return TopItem(
      itemName: (json['itemName'] ?? 'Unknown').toString(),
      totalQuantity: OwnerDashboard._toInt(json['totalQuantity']),
      totalRevenue: OwnerDashboard._toDouble(json['totalRevenue']),
    );
  }

  final String itemName;
  final int totalQuantity;
  final double totalRevenue;
}
