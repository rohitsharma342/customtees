import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/cart_provider.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String _selectedCountry = AppConstants.countries.first;
  String _selectedPaymentMethod = AppConstants.paymentMethods.first;
  bool _isProcessing = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _currentStep == 0
                    ? _buildShippingForm()
                    : _currentStep == 1
                        ? _buildPaymentForm()
                        : _buildOrderReview(),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Shipping'),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(1, 'Payment'),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(2, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : AppTheme.cardColor,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppTheme.primaryColor, width: 2)
                : null,
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: AppTheme.backgroundColor,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? AppTheme.backgroundColor : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive ? AppTheme.primaryColor : AppTheme.cardColor,
    );
  }

  Widget _buildShippingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Address',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'John Doe',
          prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textSecondary),
          validator: (value) => Validators.validateRequired(value, 'Name'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _addressController,
          label: 'Address',
          hint: '123 Main Street',
          prefixIcon: const Icon(Icons.home_outlined, color: AppTheme.textSecondary),
          validator: (value) => Validators.validateRequired(value, 'Address'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _cityController,
                label: 'City',
                hint: 'New York',
                validator: (value) => Validators.validateRequired(value, 'City'),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _zipController,
                label: 'Zip Code',
                hint: '10001',
                keyboardType: TextInputType.number,
                validator: Validators.validateZipCode,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Country',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountry,
                  isExpanded: true,
                  dropdownColor: AppTheme.surfaceColor,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  items: AppConstants.countries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCountry = value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '+1 234 567 8900',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
          validator: Validators.validatePhone,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...AppConstants.paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod == method;
          return GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = method),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentIcon(method),
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    method,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                    ),
                ],
              ),
            ),
          );
        }),
        if (_selectedPaymentMethod == 'Credit Card') ...[  
          const SizedBox(height: 20),
          const Text(
            'Card Details',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _cardNumberController,
            label: 'Card Number',
            hint: '1234 5678 9012 3456',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.credit_card, color: AppTheme.textSecondary),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: Validators.validateCardNumber,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _expiryController,
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryDateFormatter(),
                  ],
                  validator: Validators.validateExpiryDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _cvvController,
                  label: 'CVV',
                  hint: '123',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: Validators.validateCVV,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Credit Card':
        return Icons.credit_card;
      case 'PayPal':
        return Icons.account_balance_wallet;
      case 'Apple Pay':
        return Icons.apple;
      case 'Google Pay':
        return Icons.g_mobiledata;
      default:
        return Icons.payment;
    }
  }

  Widget _buildOrderReview() {
    final cartProvider = context.watch<CartProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Review',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildReviewSection(
          'Shipping Address',
          Icons.location_on_outlined,
          '${_nameController.text}\n${_addressController.text}\n${_cityController.text}, ${_zipController.text}\n$_selectedCountry\n${_phoneController.text}',
        ),
        const SizedBox(height: 16),
        _buildReviewSection(
          'Payment Method',
          _getPaymentIcon(_selectedPaymentMethod),
          _selectedPaymentMethod == 'Credit Card'
              ? '$_selectedPaymentMethod\n**** **** **** ${_cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4)}'
              : _selectedPaymentMethod,
        ),
        const SizedBox(height: 24),
        const Text(
          'Order Items',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...cartProvider.items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.checkroom,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${item.selectedSize} | ${item.selectedColor} | Qty: ${item.quantity}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
        const Divider(color: AppTheme.cardColor, height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subtotal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            Text(
              '\$${cartProvider.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Shipping',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            Text(
              cartProvider.shippingCost == 0 ? 'FREE' : '\$${cartProvider.shippingCost.toStringAsFixed(2)}',
              style: TextStyle(
                color: cartProvider.shippingCost == 0 ? AppTheme.successColor : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const Divider(color: AppTheme.cardColor, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${cartProvider.total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, IconData icon, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
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
            if (_currentStep > 0)
              Expanded(
                child: CustomButton(
                  text: 'Back',
                  isOutlined: true,
                  onPressed: () => setState(() => _currentStep--),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: _currentStep == 2 ? 'Place Order' : 'Continue',
                isLoading: _isProcessing,
                onPressed: _handleContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_currentStep == 0) {
      if (_validateShippingForm()) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      if (_validatePaymentForm()) {
        setState(() => _currentStep = 2);
      }
    } else {
      _placeOrder();
    }
  }

  bool _validateShippingForm() {
    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _zipController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return false;
    }
    return true;
  }

  bool _validatePaymentForm() {
    if (_selectedPaymentMethod == 'Credit Card') {
      if (_cardNumberController.text.replaceAll(' ', '').length != 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid card number'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return false;
      }
      if (_expiryController.text.isEmpty || _cvvController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all payment details'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return false;
      }
    }
    return true;
  }

  void _placeOrder() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      context.read<CartProvider>().clearCart();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 48,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Placed!',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order has been placed successfully.\nYou will receive a confirmation email shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Continue Shopping',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      );
    }

    setState(() => _isProcessing = false);
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && i + 1 != text.length) {
        buffer.write('/');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}