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

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final dynamic priceValue = json['price'];
    final dynamic quantityValue = json['quantity'];
    return CartItem(
      id: (json['menuItemId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: priceValue is num
          ? priceValue.toDouble()
          : double.tryParse(priceValue.toString()) ?? 0,
      imageIcon: (json['imageIcon'] ?? '').toString(),
      quantity: quantityValue is num
          ? quantityValue.toInt()
          : int.tryParse(quantityValue.toString()) ?? 1,
    );
  }
}