class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageIcon;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageIcon,
    this.quantity = 1,
  });

  static double _readPrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _readQuantity(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString()) ?? 1;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['menuItemId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: _readPrice(json['price']),
      imageIcon: (json['imageIcon'] ?? '').toString(),
      quantity: _readQuantity(json['quantity']),
    );
  }
}