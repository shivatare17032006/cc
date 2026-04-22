class FoodItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageIcon;
  final String imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageIcon,
    required this.imageUrl,
  });

  static double _readPrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: _readPrice(json['price']),
      description: (json['description'] ?? '').toString(),
      imageIcon: (json['imageIcon'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
    );
  }
}