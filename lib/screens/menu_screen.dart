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
    'sabudana vada': 'https://images.unsplash.com/photo-1505253758473-96b7015fcd40?auto=format&fit=crop&w=1200&q=80',
    'vada pav': 'https://images.unsplash.com/photo-1606491048164-fad4a855d1f1?auto=format&fit=crop&w=1200&q=80',
    'bread pattis': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=1200&q=80',
    'idli': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=1200&q=80',
    'rava paratha': 'https://images.unsplash.com/photo-1619021693030-3d50d0b5dbf0?auto=format&fit=crop&w=1200&q=80',
    'aloo paratha': 'https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&w=1200&q=80',
    'methi paratha': 'https://images.unsplash.com/photo-1619021419847-d8a7a6aba5b4?auto=format&fit=crop&w=1200&q=80',
    'palak paratha': 'https://images.unsplash.com/photo-1626074353764-517a681e40be?auto=format&fit=crop&w=1200&q=80',
    'sandwich': 'https://images.unsplash.com/photo-1528736235302-52922df5c122?auto=format&fit=crop&w=1200&q=80',
    'bajra paratha': 'https://images.unsplash.com/photo-1619021419847-d8a7a6aba5b4?auto=format&fit=crop&w=1200&q=80',
    'paneer paratha': 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=1200&q=80',
    'dhokla': 'https://images.unsplash.com/photo-1601050690117-94f5f6fa3bd2?auto=format&fit=crop&w=1200&q=80',
    'plain lassi': 'https://images.unsplash.com/photo-1623428454614-abaf00244e52?auto=format&fit=crop&w=1200&q=80',
    'mango lassi': 'https://images.unsplash.com/photo-1623428454614-abaf00244e52?auto=format&fit=crop&w=1200&q=80',
    'watermelon juice': 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?auto=format&fit=crop&w=1200&q=80',
    'papaya juice': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=1200&q=80',
    'orange juice': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=1200&q=80',
    'guava juice': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=1200&q=80',
    'mosambi juice': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=1200&q=80',
    'limbu sarbat': 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?auto=format&fit=crop&w=1200&q=80',
    'mango rabdi': 'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=1200&q=80',
    'plain rabdi': 'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=1200&q=80',
    'mix fruit rabdi': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=1200&q=80',
    'cold coffee': 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=80',
    'anjir shake': 'https://images.unsplash.com/photo-1577805947697-89e18249d767?auto=format&fit=crop&w=1200&q=80',
    'chiku shake': 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=1200&q=80',
    'oreo shake': 'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?auto=format&fit=crop&w=1200&q=80',
  };

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

    // source.unsplash can throttle/redirect in a way that often fails in-app.
    // Use a stable, keyword-based image source to keep images food/drink relevant.
    if (rawUrl.contains('source.unsplash.com')) {
      return 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=1200&q=80';
    }

    return rawUrl;
  }

  Widget _menuImage(FoodItem item) {
    final imageUrl = _resolvedImageUrl(item);
    if (imageUrl.isEmpty) {
      return _fallbackImage(item);
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
      if (items.isEmpty) {
        await ApiService.seedMenu();
        items = await ApiService.getMenuItems();
      }

      if (!mounted) return;
      setState(() {
        _foodItems = items;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
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
                )
              : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.66,
        ),
        itemCount: _foodItems.length,
        itemBuilder: (context, index) {
          final item = _foodItems[index];
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.name} added to cart'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceFirst('Exception: ', ''),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade500,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
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
        },
      ),
    );
  }
}