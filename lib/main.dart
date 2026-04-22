import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.orange,
      fontFamily: 'Roboto',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Canteen',
      theme: _buildTheme(),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}