import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../config/theme.dart';
import '../providers/design_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../models/design_model.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class CustomizationScreen extends StatefulWidget {
  final Product? product;

  const CustomizationScreen({super.key, this.product});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  String _selectedSize = 'M';
  String _selectedColor = 'White';
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final designProvider = context.read<DesignProvider>();
      if (designProvider.currentDesign == null) {
        designProvider.createNewDesign();
      }
      if (widget.product != null) {
        if (widget.product!.availableSizes.isNotEmpty) {
          _selectedSize = widget.product!.availableSizes.first;
        }
        if (widget.product!.availableColors.isNotEmpty) {
          _selectedColor = widget.product!.availableColors.first;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _showPreview ? null : _buildAppBar(),
      body: _showPreview ? _buildPreviewMode() : _buildEditMode(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final designProvider = context.watch<DesignProvider>();

    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      leading: widget.product != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        widget.product?.name ?? 'Customize Design',
        style: const TextStyle(fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: designProvider.canUndo ? designProvider.undo : null,
          color: designProvider.canUndo ? AppTheme.textPrimary : AppTheme.textSecondary,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: designProvider.canRedo ? designProvider.redo : null,
          color: designProvider.canRedo ? AppTheme.textPrimary : AppTheme.textSecondary,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _showResetDialog(),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCanvas(),
                _buildToolbar(),
                if (widget.product != null) _buildProductOptions(),
              ],
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildCanvas() {
    final designProvider = context.watch<DesignProvider>();
    final design = designProvider.currentDesign;

    return GestureDetector(
      onTap: () => designProvider.selectElement(null),
      child: Container(
        height: 350,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 200,
                height: 250,
                decoration: BoxDecoration(
                  color: design?.tshirtColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.checkroom,
                        size: 60,
                        color: (design?.tshirtColor ?? Colors.white).computeLuminance() > 0.5
                            ? Colors.black.withOpacity(0.1)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    if (design != null)
                      ...design.elements.map((element) {
                        return _buildDraggableElement(element, designProvider);
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableElement(DesignElement element, DesignProvider provider) {
    final isSelected = provider.selectedElementId == element.id;

    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onTap: () => provider.selectElement(element.id),
        onPanUpdate: (details) {
          provider.updateElementPosition(
            element.id,
            Offset(
              element.position.dx + details.delta.dx,
              element.position.dy + details.delta.dy,
            ),
          );
        },
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  border: Border.all(color: AppTheme.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          padding: isSelected ? const EdgeInsets.all(4) : null,
          child: Transform.scale(
            scale: element.scale,
            child: Transform.rotate(
              angle: element.rotation,
              child: element.type == DesignElementType.text
                  ? Text(
                      element.content,
                      style: TextStyle(
                        color: element.textColor ?? Colors.black,
                        fontSize: element.fontSize ?? 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Icon(Icons.image, size: 50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    final designProvider = context.watch<DesignProvider>();
    final selectedElement = designProvider.selectedElement;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolButton(
                icon: Icons.text_fields,
                label: 'Text',
                onTap: () => _showAddTextDialog(),
              ),
              _buildToolButton(
                icon: Icons.image,
                label: 'Image',
                onTap: () => _showAddImageDialog(),
              ),
              _buildToolButton(
                icon: Icons.palette,
                label: 'T-Shirt',
                onTap: () => _showTshirtColorPicker(),
              ),
              if (selectedElement != null && selectedElement.type == DesignElementType.text)
                _buildToolButton(
                  icon: Icons.format_color_text,
                  label: 'Color',
                  onTap: () => _showTextColorPicker(selectedElement),
                ),
            ],
          ),
          if (selectedElement != null) ...[  
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Size: ',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                Expanded(
                  child: Slider(
                    value: selectedElement.scale,
                    min: 0.5,
                    max: 3.0,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      designProvider.updateElementScale(selectedElement.id, value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                  onPressed: () {
                    designProvider.removeElement(selectedElement.id);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductOptions() {
    final product = widget.product!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Size',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: product.availableSizes.map((size) {
              final isSelected = _selectedSize == size;
              return GestureDetector(
                onTap: () => setState(() => _selectedSize = size),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                    ),
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
          const SizedBox(height: 16),
          const Text(
            'Color',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: product.availableColors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                    ),
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
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Preview',
                isOutlined: true,
                icon: Icons.visibility,
                onPressed: () => setState(() => _showPreview = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Save',
                icon: Icons.save,
                onPressed: () => _showSaveDialog(),
              ),
            ),
            if (widget.product != null) ...[  
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Add to Cart',
                  icon: Icons.shopping_cart,
                  onPressed: () => _addToCart(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewMode() {
    final designProvider = context.watch<DesignProvider>();
    final design = designProvider.currentDesign;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showPreview = false),
                ),
                const Expanded(
                  child: Text(
                    'Preview',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 280,
                height: 350,
                decoration: BoxDecoration(
                  color: design?.tshirtColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (design != null)
                      ...design.elements.map((element) {
                        return Positioned(
                          left: element.position.dx * 1.4,
                          top: element.position.dy * 1.4,
                          child: Transform.scale(
                            scale: element.scale * 1.2,
                            child: Transform.rotate(
                              angle: element.rotation,
                              child: element.type == DesignElementType.text
                                  ? Text(
                                      element.content,
                                      style: TextStyle(
                                        color: element.textColor ?? Colors.black,
                                        fontSize: element.fontSize ?? 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const Icon(Icons.image, size: 60),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Back to Editor',
              onPressed: () => setState(() => _showPreview = false),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTextDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Add Text',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter your text',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final error = Validators.validateDesignText(textController.text);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              context.read<DesignProvider>().addTextElement(textController.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddImageDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image upload feature - Select from gallery'),
        backgroundColor: AppTheme.cardColor,
      ),
    );
    context.read<DesignProvider>().addImageElement('placeholder_image');
  }

  void _showTshirtColorPicker() {
    final designProvider = context.read<DesignProvider>();
    Color currentColor = designProvider.currentDesign?.tshirtColor ?? Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'T-Shirt Color',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) => currentColor = color,
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              designProvider.setTshirtColor(currentColor);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showTextColorPicker(DesignElement element) {
    final designProvider = context.read<DesignProvider>();
    Color currentColor = element.textColor ?? Colors.black;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Text Color',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) => currentColor = color,
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              designProvider.updateTextColor(element.id, currentColor);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Reset Design?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This will clear all customizations. Are you sure?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              context.read<DesignProvider>().reset();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    final nameController = TextEditingController();
    final designProvider = context.read<DesignProvider>();
    nameController.text = designProvider.currentDesign?.name ?? 'Untitled Design';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Save Design',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Design name',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                designProvider.saveDesign(nameController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Design saved successfully!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    if (widget.product == null) return;

    final designProvider = context.read<DesignProvider>();
    final cartProvider = context.read<CartProvider>();

    cartProvider.addItem(
      product: widget.product!,
      size: _selectedSize,
      color: _selectedColor,
      design: designProvider.currentDesign,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart!'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    Navigator.pop(context);
  }
}