import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/design_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class StaticData {
  static final List<Product> products = [
    Product(
      id: '1',
      name: 'Classic Crew Neck',
      description: 'Premium cotton crew neck t-shirt perfect for everyday wear and custom designs.',
      price: 24.99,
      imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
      category: 'Men',
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      availableColors: ['White', 'Black', 'Navy', 'Gray'],
      isTrending: true,
    ),
    Product(
      id: '2',
      name: 'V-Neck Essential',
      description: 'Comfortable v-neck style with soft fabric blend for a modern look.',
      price: 27.99,
      imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400',
      category: 'Women',
      availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
      availableColors: ['White', 'Pink', 'Lavender', 'Mint'],
      isTrending: true,
    ),
    Product(
      id: '3',
      name: 'Kids Fun Tee',
      description: 'Durable and soft t-shirt designed for active kids who love to express themselves.',
      price: 19.99,
      imageUrl: 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=400',
      category: 'Kids',
      availableSizes: ['3-4Y', '5-6Y', '7-8Y', '9-10Y', '11-12Y'],
      availableColors: ['White', 'Yellow', 'Blue', 'Red'],
      isTrending: false,
    ),
    Product(
      id: '4',
      name: 'Premium Oversized',
      description: 'Trendy oversized fit with dropped shoulders for a relaxed streetwear vibe.',
      price: 34.99,
      imageUrl: 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=400',
      category: 'New Arrivals',
      availableSizes: ['S', 'M', 'L', 'XL'],
      availableColors: ['Black', 'Charcoal', 'Olive', 'Cream'],
      isTrending: true,
    ),
    Product(
      id: '5',
      name: 'Athletic Performance',
      description: 'Moisture-wicking fabric perfect for workouts and active lifestyles.',
      price: 29.99,
      imageUrl: 'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=400',
      category: 'Men',
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      availableColors: ['Black', 'Navy', 'Red', 'Gray'],
      isTrending: false,
    ),
    Product(
      id: '6',
      name: 'Cropped Comfort',
      description: 'Stylish cropped tee with a comfortable fit for casual outings.',
      price: 26.99,
      imageUrl: 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=400',
      category: 'Women',
      availableSizes: ['XS', 'S', 'M', 'L'],
      availableColors: ['White', 'Black', 'Blush', 'Sage'],
      isTrending: true,
    ),
    Product(
      id: '7',
      name: 'Vintage Washed',
      description: 'Pre-washed for a vintage feel with soft, lived-in comfort.',
      price: 32.99,
      imageUrl: 'https://images.unsplash.com/photo-1529374255404-311a2a4f1fd9?w=400',
      category: 'New Arrivals',
      availableSizes: ['S', 'M', 'L', 'XL'],
      availableColors: ['Vintage Black', 'Vintage Blue', 'Vintage Gray'],
      isTrending: false,
    ),
    Product(
      id: '8',
      name: 'Long Sleeve Basic',
      description: 'Classic long sleeve tee for layering or standalone wear.',
      price: 29.99,
      imageUrl: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=400',
      category: 'Men',
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      availableColors: ['White', 'Black', 'Navy', 'Burgundy'],
      isTrending: false,
    ),
  ];

  static final List<String> categories = ['All', 'Men', 'Women', 'Kids', 'New Arrivals'];

  static final List<CustomDesign> savedDesigns = [
    CustomDesign(
      id: 'd1',
      name: 'Summer Vibes',
      tshirtColor: Colors.white,
      elements: [
        DesignElement(
          id: 'e1',
          type: DesignElementType.text,
          content: 'Summer 2024',
          position: const Offset(120, 150),
          textColor: Colors.orange,
          fontSize: 24,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CustomDesign(
      id: 'd2',
      name: 'Cool Design',
      tshirtColor: Colors.black,
      elements: [
        DesignElement(
          id: 'e2',
          type: DesignElementType.text,
          content: 'BE COOL',
          position: const Offset(100, 180),
          textColor: Colors.white,
          fontSize: 28,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  static final List<Order> recentOrders = [
    Order(
      id: 'ORD001',
      items: [
        CartItem(
          id: 'ci1',
          product: products[0],
          selectedSize: 'M',
          selectedColor: 'White',
          quantity: 2,
        ),
      ],
      shippingAddress: ShippingAddress(
        name: 'John Doe',
        address: '123 Main Street',
        city: 'New York',
        zipCode: '10001',
        country: 'United States',
        phone: '+1 234 567 8900',
      ),
      paymentMethod: 'Credit Card',
      totalAmount: 49.98,
      status: OrderStatus.shipped,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
    ),
    Order(
      id: 'ORD002',
      items: [
        CartItem(
          id: 'ci2',
          product: products[3],
          selectedSize: 'L',
          selectedColor: 'Black',
          quantity: 1,
        ),
      ],
      shippingAddress: ShippingAddress(
        name: 'John Doe',
        address: '123 Main Street',
        city: 'New York',
        zipCode: '10001',
        country: 'United States',
        phone: '+1 234 567 8900',
      ),
      paymentMethod: 'PayPal',
      totalAmount: 34.99,
      status: OrderStatus.processing,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}