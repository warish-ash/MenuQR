// lib/providers/cart_provider.dart

import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String nameUrdu;
  final double price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.nameUrdu,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  bool get isEmpty => _items.isEmpty;

  /// Add item to cart
  void addItem(Map<String, dynamic> menuItem) {
    String itemId = menuItem['id'];

    if (_items.containsKey(itemId)) {
      // Item already in cart, increase quantity
      _items[itemId]!.quantity++;
    } else {
      // New item, add to cart
      _items[itemId] = CartItem(
        id: itemId,
        name: menuItem['name'],
        nameUrdu: menuItem['name_urdu'] ?? '',
        price: (menuItem['price'] as num).toDouble(),
        imageUrl: menuItem['image_url'],
      );
    }

    notifyListeners();
  }

  /// Remove item from cart
  void removeItem(String itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  /// Increase quantity
  void increaseQuantity(String itemId) {
    if (_items.containsKey(itemId)) {
      _items[itemId]!.quantity++;
      notifyListeners();
    }
  }

  /// Decrease quantity
  void decreaseQuantity(String itemId) {
    if (_items.containsKey(itemId)) {
      if (_items[itemId]!.quantity > 1) {
        _items[itemId]!.quantity--;
      } else {
        // If quantity is 1, remove item
        _items.remove(itemId);
      }
      notifyListeners();
    }
  }

  /// Clear cart
  void clear() {
    _items = {};
    notifyListeners();
  }

  /// Get items as list for order submission
  List<Map<String, dynamic>> getOrderItems() {
    return _items.values.map((item) {
      return {
        'item_id': item.id,
        'name': item.name,
        'name_urdu': item.nameUrdu,
        'quantity': item.quantity,
        'price': item.price,
        'subtotal': item.subtotal,
      };
    }).toList();
  }
}