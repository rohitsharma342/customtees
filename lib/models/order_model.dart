import 'cart_item_model.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class ShippingAddress {
  final String name;
  final String address;
  final String city;
  final String zipCode;
  final String country;
  final String phone;

  ShippingAddress({
    required this.name,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.country,
    required this.phone,
  });
}

class Order {
  final String id;
  final List<CartItem> items;
  final ShippingAddress shippingAddress;
  final String paymentMethod;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  Order({
    required this.id,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.estimatedDelivery,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}