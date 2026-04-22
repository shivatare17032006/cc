import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<FoodItem> _foodItems = [];
  bool _isLoading = true;
  String? _error;

  static const Map<String, String> _itemImageMap = {
    'sabudana vada': 'assets/menu/sabudana_vada.png',
    'vada pav': 'assets/menu/vada_pav.png',
    'bread pattis': 'assets/menu/bread_pattis.png',
    'idli': 'assets/menu/idli.png',
    'rava paratha': 'assets/menu/rava_paratha.png',
    'aloo paratha': 'assets/menu/aloo_paratha.png',
    'methi paratha': 'assets/menu/methi_paratha.png',
    'palak paratha': 'assets/menu/palak_paratha.png',
    'sandwich': 'assets/menu/sandwich.png',
    'cold coffee': 'assets/menu/cold_coffee.png',
    'orange juice': 'assets/menu/orange_juice.png',
    'plain lassi': 'assets/menu/plain_lassi.png',
    'watermelon juice': 'assets/menu/watermelon_juice.png',
    'anjir shake': 'assets/menu/anjir_shake.png',
    'papaya juice': 'assets/menu/papaya_juice.png',
    'mango lassi': 'assets/menu/mango_lassi.png',
    'dhokla': 'assets/menu/dhokla.png',
    'paneer paratha': 'assets/menu/paneer_paratha.png',
    'bajra paratha': 'assets/menu/bajra_paratha.png',
    'oreo shake': 'assets/menu/oreo_shake.png',
    'chiku shake': 'assets/menu/chiku_shake.png',
    'mix fruit rabdi': 'assets/menu/mix_fruit_rabdi.png',
    'plain rabdi': 'assets/menu/plain_rabdi.png',
    'mango rabdi': 'assets/menu/mango_rabdi.png',
    'limbu sarbat': 'assets/menu/limbu_sarbat.png',
    'mosambi juice': 'assets/menu/mosambi_juice.png',
    'guava juice': 'assets/menu/guava_juice.png',
  };

  static const Map<String, double> _itemPriceMap = {
    'sabudana vada': 45,
    'vada pav': 35,
    'bread pattis': 30,
    'idli': 40,
    'rava paratha': 55,
    'aloo paratha': 60,
    'methi paratha': 60,
    'palak paratha': 60,
    'sandwich': 50,
    'cold coffee': 70,
    'orange juice': 55,
    'plain lassi': 45,
    'watermelon juice': 50,
    'anjir shake': 90,
    'papaya juice': 50,
    'mango lassi': 55,
    'dhokla': 40,
    'paneer paratha': 75,
    'bajra paratha': 65,
    'oreo shake': 95,
    'chiku shake': 85,
    'mix fruit rabdi': 95,
    'plain rabdi': 80,
    'mango rabdi': 90,
    'limbu sarbat': 30,
    'mosambi juice': 55,
    'guava juice': 55,
  };

  void _showMessage(String text, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _titleCase(String value) {
    return value
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  List<FoodItem> _fallbackMenuItems() {
    final entries = _itemImageMap.entries.toList();
    return List.generate(entries.length, (index) {
      final key = entries[index].key;
      return FoodItem(
        id: 'local-$index',
        name: _titleCase(key),
        price: _itemPriceMap[key] ?? 50,
        description: 'Freshly prepared canteen special',
        imageIcon: '🍽',
        imageUrl: entries[index].value,
      );
    });
  }

  bool _hasAllExpectedItems(List<FoodItem> items) {
    final names = items.map((item) => item.name.trim().toLowerCase()).toSet();
    return _itemImageMap.keys.every(names.contains);
  }

  String _formatRs(double amount) => 'Rs ${amount.toStringAsFixed(0)}';

  String _resolvedImageUrl(FoodItem item) {
    final itemName = item.name.trim().toLowerCase();
    final mappedUrl = _itemImageMap[itemName];
    if (mappedUrl != null && mappedUrl.isNotEmpty) {
      return mappedUrl;
    }

    final rawUrl = item.imageUrl.trim();
    if (rawUrl.isEmpty) {
      return '';
    }


    if (rawUrl.contains('source.unsplash.com')) {
      return 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=1200&q=80';
    }

    return rawUrl;
  }

  bool _isAssetPath(String value) =>
      value.startsWith('assets/') || value.startsWith('packages/');

  Widget _menuImage(FoodItem item) {
    final imageUrl = _resolvedImageUrl(item);
    if (imageUrl.isEmpty) {
      return _fallbackImage(item);
    }

    if (_isAssetPath(imageUrl)) {
      return Image.asset(
        imageUrl,
        height: 128,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackImage(item),
      );
    }

    return Image.network(
      imageUrl,
      height: 128,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 128,
          color: Colors.orange.shade100,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _fallbackImage(item),
    );
  }

  Widget _fallbackImage(FoodItem item) {
    final fallbackIcon = item.imageIcon.trim().isEmpty ? '🍽' : item.imageIcon;
    return Container(
      height: 128,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.deepOrange.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        fallbackIcon,
        style: const TextStyle(fontSize: 52),
      ),
    );
  }

  Widget _buildMenuCard(FoodItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: _menuImage(item),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatRs(item.price),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await ApiService.addToCart(item.id);
                          if (!context.mounted) return;
                          _showMessage('${item.name} added to cart');
                        } catch (e) {
                          if (!context.mounted) return;
                          _showMessage(
                            e.toString().replaceFirst('Exception: ', ''),
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(double.infinity, 32),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadMenu,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: _foodItems.length,
      itemBuilder: (context, index) => _buildMenuCard(_foodItems[index]),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var items = await ApiService.getMenuItems();

      if (items.isEmpty || !_hasAllExpectedItems(items)) {
        await ApiService.seedMenu();
        items = await ApiService.getMenuItems();
      }

      if (items.isEmpty) {
        items = _fallbackMenuItems();
      }

      if (!mounted) return;
      setState(() {
        _foodItems = items;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _foodItems = _fallbackMenuItems();
        _error = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load menu from server. Showing local menu items.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: _buildBody(),
    );
  }
}