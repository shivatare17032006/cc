class Order {
  final String id;
  final String date;
  final double total;
  final List<String> items;

  const Order({
    required this.id,
    required this.date,
    required this.total,
    required this.items,
  });

  static double _readTotal(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _shortDate(String value) {
    return value.length >= 10 ? value.substring(0, 10) : value;
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final createdAt = (json['createdAt'] ?? '').toString();
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final itemNames = rawItems.map((item) {
      if (item is Map<String, dynamic>) {
        return (item['name'] ?? '').toString();
      }
      return item.toString();
    }).toList();

    return Order(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      date: _shortDate(createdAt),
      total: _readTotal(json['totalAmount'] ?? json['total']),
      items: itemNames,
    );
  }
}