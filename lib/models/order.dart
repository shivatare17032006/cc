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

  factory Order.fromJson(Map<String, dynamic> json) {
    final dynamic totalValue = json['totalAmount'] ?? json['total'];
    final List<dynamic> rawItems = (json['items'] as List<dynamic>?) ?? [];

    final itemNames = rawItems.map((item) {
      if (item is Map<String, dynamic>) {
        return (item['name'] ?? '').toString();
      }
      return item.toString();
    }).toList();

    final createdAt = (json['createdAt'] ?? '').toString();

    return Order(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      date: createdAt.isNotEmpty && createdAt.length >= 10
          ? createdAt.substring(0, 10)
          : createdAt,
      total: totalValue is num
          ? totalValue.toDouble()
          : double.tryParse(totalValue.toString()) ?? 0,
      items: itemNames,
    );
  }
}