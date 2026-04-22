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

  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

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

  static Future<http.Response> _get(String path, {bool auth = false}) {
    return http.get(_uri(path), headers: _headers(auth: auth));
  }

  static Future<http.Response> _post(
    String path, {
    bool auth = false,
    Object? body,
  }) {
    return http.post(
      _uri(path),
      headers: _headers(auth: auth),
      body: body,
    );
  }

  static Future<http.Response> _patch(
    String path, {
    bool auth = false,
    Object? body,
  }) {
    return http.patch(
      _uri(path),
      headers: _headers(auth: auth),
      body: body,
    );
  }

  static Future<http.Response> _delete(String path, {bool auth = false}) {
    return http.delete(_uri(path), headers: _headers(auth: auth));
  }

  static List<Map<String, dynamic>> _decodeMapList(String body) {
    return (jsonDecode(body) as List<dynamic>).whereType<Map<String, dynamic>>().toList();
  }

  static Map<String, dynamic> _decodeMap(String body) {
    return jsonDecode(body) as Map<String, dynamic>;
  }

  static Future<void> login({required String email, required String password}) async {
    final response = await _post(
      '/auth/login',
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
    final response = await _post(
      '/auth/register',
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

    final body = _decodeMap(response.body);
    final token = (body['token'] ?? '').toString();
    if (token.isEmpty) {
      throw Exception('Invalid registration response');
    }

    await saveToken(token);
  }

  static Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _get('/auth/me', auth: true);

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return _decodeMap(response.body);
  }

  static Future<List<FoodItem>> getMenuItems() async {
    final response = await _get('/menu');

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return _decodeMapList(response.body).map(FoodItem.fromJson).toList();
  }

  static Future<void> seedMenu() async {
    final response = await _post('/menu/seed');

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }
  }

  static Future<void> addToCart(String menuItemId) async {
    final response = await _post(
      '/cart/items',
      auth: true,
      body: jsonEncode({'menuItemId': menuItemId, 'quantity': 1}),
    );

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }
  }

  static Future<List<CartItem>> getCartItems() async {
    final response = await _get('/cart', auth: true);

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final body = _decodeMap(response.body);
    final list = (body['items'] as List<dynamic>? ?? []);
    return list
        .whereType<Map<String, dynamic>>()
        .map(CartItem.fromJson)
        .toList();
  }

  static Future<void> updateCartQuantity(String menuItemId, int quantity) async {
    final response = await _patch(
      '/cart/items/$menuItemId',
      auth: true,
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  static Future<void> removeFromCart(String menuItemId) async {
    final response = await _delete('/cart/items/$menuItemId', auth: true);

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }

  static Future<void> placeOrder() async {
    final response = await _post('/orders', auth: true);

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }
  }

  static Future<List<Order>> getOrders() async {
    final response = await _get('/orders', auth: true);

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return _decodeMapList(response.body).map(Order.fromJson).toList();
  }

  static Future<List<Map<String, dynamic>>> getComplaints() async {
    final response = await _get('/complaints', auth: true);

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return _decodeMapList(response.body);
  }

  static Future<Map<String, dynamic>> submitComplaint({
    required String type,
    required String description,
    required String priority,
    required bool isAnonymous,
    required String contactEmail,
  }) async {
    final response = await _post(
      '/complaints',
      auth: true,
      body: jsonEncode({
        'type': type,
        'description': description,
        'priority': priority,
        'isAnonymous': isAnonymous,
        'contactEmail': contactEmail,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }

    return _decodeMap(response.body);
  }

  static Future<Map<String, dynamic>> resolveComplaint(String complaintDbId) async {
    final response = await _patch('/complaints/$complaintDbId/resolve', auth: true);

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return _decodeMap(response.body);
  }

  static Future<List<int>> getUnavailableTables({
    required String bookingDate,
    required String timeSlot,
  }) async {
    final response = await _get(
      '/bookings/availability?date=$bookingDate&slot=${Uri.encodeQueryComponent(timeSlot)}',
      auth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final body = _decodeMap(response.body);
    final list = (body['unavailableTables'] as List<dynamic>? ?? []);
    return list.map((value) => int.tryParse(value.toString()) ?? 0).where((value) => value > 0).toList();
  }

  static Future<Map<String, dynamic>> createBooking({
    required String bookingDate,
    required String timeSlot,
    required int tableNumber,
    required int partySize,
  }) async {
    final response = await _post(
      '/bookings',
      auth: true,
      body: jsonEncode({
        'bookingDate': bookingDate,
        'timeSlot': timeSlot,
        'tableNumber': tableNumber,
        'partySize': partySize,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }

    return _decodeMap(response.body);
  }

  static Future<List<Map<String, dynamic>>> getMyBookings() async {
    final response = await _get('/bookings/my', auth: true);

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return _decodeMapList(response.body);
  }

  static Future<Map<String, dynamic>> releaseBooking(String bookingId) async {
    final response = await _patch('/bookings/$bookingId/release', auth: true);

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    return _decodeMap(response.body);
  }
}
