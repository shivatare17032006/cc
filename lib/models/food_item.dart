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

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final dynamic priceValue = json['price'];
    return FoodItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: priceValue is num
          ? priceValue.toDouble()
          : double.tryParse(priceValue.toString()) ?? 0,
      description: (json['description'] ?? '').toString(),
      imageIcon: (json['imageIcon'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
    );
  }
}