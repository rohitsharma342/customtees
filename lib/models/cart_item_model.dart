import 'product_model.dart';
import 'design_model.dart';

class CartItem {
  final String id;
  final Product product;
  final CustomDesign? customDesign;
  final String selectedSize;
  final String selectedColor;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.customDesign,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    CustomDesign? customDesign,
    String? selectedSize,
    String? selectedColor,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      customDesign: customDesign ?? this.customDesign,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
    );
  }
}