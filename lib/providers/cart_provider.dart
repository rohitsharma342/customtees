import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/design_model.dart';
import '../utils/constants.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final _uuid = const Uuid();

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get shippingCost {
    if (subtotal >= AppConstants.freeShippingThreshold || _items.isEmpty) {
      return 0;
    }
    return AppConstants.shippingCost;
  }

  double get total => subtotal + shippingCost;

  bool get isEmpty => _items.isEmpty;

  void addItem({
    required Product product,
    required String size,
    required String color,
    CustomDesign? design,
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color &&
          item.customDesign?.id == design?.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: _uuid.v4(),
        product: product,
        customDesign: design,
        selectedSize: size,
        selectedColor: color,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity < 1) return;
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void incrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0 && _items[index].quantity < _items[index].product.stock) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}