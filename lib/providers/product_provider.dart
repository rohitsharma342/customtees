import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../data/static_data.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 100);
  List<String> _selectedSizes = [];
  List<String> _selectedColors = [];

  ProductProvider() {
    _products = StaticData.products;
    _filteredProducts = _products;
  }

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => _priceRange;
  List<String> get selectedSizes => _selectedSizes;
  List<String> get selectedColors => _selectedColors;

  List<Product> get trendingProducts =>
      _products.where((p) => p.isTrending).toList();

  double get minPrice =>
      _products.map((p) => p.price).reduce((a, b) => a < b ? a : b);

  double get maxPrice =>
      _products.map((p) => p.price).reduce((a, b) => a > b ? a : b);

  List<String> get allSizes {
    final sizes = <String>{};
    for (final product in _products) {
      sizes.addAll(product.availableSizes);
    }
    return sizes.toList();
  }

  List<String> get allColors {
    final colors = <String>{};
    for (final product in _products) {
      colors.addAll(product.availableColors);
    }
    return colors.toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    _applyFilters();
  }

  void toggleSize(String size) {
    if (_selectedSizes.contains(size)) {
      _selectedSizes.remove(size);
    } else {
      _selectedSizes.add(size);
    }
    _applyFilters();
  }

  void toggleColor(String color) {
    if (_selectedColors.contains(color)) {
      _selectedColors.remove(color);
    } else {
      _selectedColors.add(color);
    }
    _applyFilters();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _priceRange = RangeValues(minPrice, maxPrice);
    _selectedSizes = [];
    _selectedColors = [];
    _filteredProducts = _products;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      if (_selectedCategory != 'All' && product.category != _selectedCategory) {
        return false;
      }

      if (_searchQuery.isNotEmpty &&
          !product.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !product.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      if (product.price < _priceRange.start || product.price > _priceRange.end) {
        return false;
      }

      if (_selectedSizes.isNotEmpty &&
          !_selectedSizes.any((size) => product.availableSizes.contains(size))) {
        return false;
      }

      if (_selectedColors.isNotEmpty &&
          !_selectedColors.any((color) => product.availableColors.contains(color))) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}