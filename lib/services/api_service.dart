import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/order.dart';

class ApiService {

  static const String _configuredBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const String _mobileBaseUrl = 'http://10.118.14.218:5000/api';
  static const String _webBaseUrl = 'http://localhost:5000/api';
  static String get _baseUrl =>
      _configuredBaseUrl.isNotEmpty
          ? _configuredBaseUrl
          : (kIsWeb ? _webBaseUrl : _mobileBaseUrl);

  static String? _token;

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  static Map<String, String> _headers({bool auth = false}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static String _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['message'] ?? 'Request failed').toString();
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }

  static Future<void> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = (body['token'] ?? '').toString();
    if (token.isEmpty) {
      throw Exception('Invalid login response');
    }

    await saveToken(token);
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String location,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'location': location,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = (body['token'] ?? '').toString();
    if (token.isEmpty) {
      throw Exception('Invalid registration response');
    }

    await saveToken(token);
  }

  static Future<Map<String, dynamic>> getMyProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: _headers(auth: true),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<FoodItem>> getMenuItems() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/menu'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(FoodItem.fromJson)
        .toList();
  }

  static Future<void> seedMenu() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/menu/seed'),
      headers: _headers(),
    );

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }
  }

  static Future<void> addToCart(String menuItemId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/cart/items'),
      headers: _headers(auth: true),
      body: jsonEncode({'menuItemId': menuItemId, 'quantity': 1}),
    );

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }
  }

  static Future<List<CartItem>> getCartItems() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cart'),
      headers: _headers(auth: true),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (body['items'] as List<dynamic>? ?? []);
    return list
        .whereType<Map<String, dynamic>>()
        .map(CartItem.fromJson)
        .toList();
  }

  static Future<void> updateCartQuantity(String menuItemId, int quantity) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/cart/items/$menuItemId'),
      headers: _headers(auth: true),
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  static Future<void> removeFromCart(String menuItemId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/cart/items/$menuItemId'),
      headers: _headers(auth: true),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  static Future<void> placeOrder() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: _headers(auth: true),
    );

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }
  }

  static Future<List<Order>> getOrders() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders'),
      headers: _headers(auth: true),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList();
  }
}
