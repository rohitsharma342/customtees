import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/product_provider.dart';
import 'custom_button.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late RangeValues _priceRange;
  late List<String> _selectedSizes;
  late List<String> _selectedColors;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();
    _priceRange = provider.priceRange;
    _selectedSizes = List.from(provider.selectedSizes);
    _selectedColors = List.from(provider.selectedColors);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _priceRange = RangeValues(provider.minPrice, provider.maxPrice);
                    _selectedSizes = [];
                    _selectedColors = [];
                  });
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Price Range',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: provider.minPrice,
            max: provider.maxPrice,
            divisions: 20,
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.cardColor,
            labels: RangeLabels(
              '\$${_priceRange.start.toStringAsFixed(0)}',
              '\$${_priceRange.end.toStringAsFixed(0)}',
            ),
            onChanged: (values) {
              setState(() => _priceRange = values);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_priceRange.start.toStringAsFixed(0)}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              Text(
                '\$${_priceRange.end.toStringAsFixed(0)}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Sizes',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.allSizes.map((size) {
              final isSelected = _selectedSizes.contains(size);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSizes.remove(size);
                    } else {
                      _selectedSizes.add(size);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected ? AppTheme.backgroundColor : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Colors',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.allColors.map((color) {
              final isSelected = _selectedColors.contains(color);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedColors.remove(color);
                    } else {
                      _selectedColors.add(color);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    color,
                    style: TextStyle(
                      color: isSelected ? AppTheme.backgroundColor : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Apply Filters',
            onPressed: () {
              provider.setPriceRange(_priceRange);
              for (final size in provider.allSizes) {
                if (_selectedSizes.contains(size) && !provider.selectedSizes.contains(size)) {
                  provider.toggleSize(size);
                } else if (!_selectedSizes.contains(size) && provider.selectedSizes.contains(size)) {
                  provider.toggleSize(size);
                }
              }
              for (final color in provider.allColors) {
                if (_selectedColors.contains(color) && !provider.selectedColors.contains(color)) {
                  provider.toggleColor(color);
                } else if (!_selectedColors.contains(color) && provider.selectedColors.contains(color)) {
                  provider.toggleColor(color);
                }
              }
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}