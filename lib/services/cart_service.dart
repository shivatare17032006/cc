import '../models/food_item.dart';
import '../models/cart_item.dart';

class CartService {
  static List<CartItem> _cartItems = [];

  static void addToCart(FoodItem foodItem) {
    final existingItem = _cartItems.firstWhere(
          (item) => item.id == foodItem.id,
      orElse: () => CartItem(
        id: '',
        name: '',
        price: 0,
        imageIcon: '',
      ),
    );

    if (existingItem.id.isNotEmpty) {
      existingItem.quantity++;
    } else {
      _cartItems.add(CartItem(
        id: foodItem.id,
        name: foodItem.name,
        price: foodItem.price,
        imageIcon: foodItem.imageIcon,
      ));
    }
  }

  static List<CartItem> getCartItems() {
    return List.from(_cartItems);
  }

  static void removeFromCart(String id) {
    _cartItems.removeWhere((item) => item.id == id);
  }

  static void updateQuantity(String id, int newQuantity) {
    final item = _cartItems.firstWhere((item) => item.id == id);
    if (newQuantity <= 0) {
      removeFromCart(id);
    } else {
      item.quantity = newQuantity;
    }
  }

  static void clearCart() {
    _cartItems.clear();
  }
}