import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/sale.dart';
import '../../models/shop.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _onlineAmountController = TextEditingController();
  final _cashAmountController = TextEditingController();
  final _adhocExpController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _selectedShopName;
  List<Shop> _shops = [];
  bool _isLoadingShops = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final shops = await DatabaseService().getAllShops().first;

      setState(() {
        _shops = shops..sort((a, b) => a.shopName.compareTo(b.shopName));
        _isLoadingShops = false;

        // Auto-select shop for shopkeepers
        if (authProvider.isShopkeeper &&
            authProvider.currentUser?.shopId != null) {
          final assignedShop = _shops.firstWhere(
            (shop) => shop.id == authProvider.currentUser!.shopId,
            orElse: () => _shops.first,
          );
          _selectedShopName = assignedShop.shopName;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingShops = false;
      });
    }
  }

  @override
  void dispose() {
    _onlineAmountController.dispose();
    _cashAmountController.dispose();
    _adhocExpController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _onlineAmount {
    return double.tryParse(_onlineAmountController.text) ?? 0;
  }

  double get _cashAmount {
    return double.tryParse(_cashAmountController.text) ?? 0;
  }

  double get _adhocExpTotal {
    final text = _adhocExpController.text.trim();
    if (text.isEmpty) return 0;

    double total = 0;
    // Parse format: "milk-25, sugar-30, bread-50"
    final items = text.split(',');
    for (var item in items) {
      final parts = item.trim().split('-');
      if (parts.length >= 2) {
        final amount = double.tryParse(parts.last.trim());
        if (amount != null) {
          total += amount;
        }
      }
    }
    return total;
  }

  double get _cashDeposited {
    return _cashAmount - _adhocExpTotal;
  }

  List<Map<String, dynamic>> get _adhocExpItems {
    final text = _adhocExpController.text.trim();
    if (text.isEmpty) return [];

    List<Map<String, dynamic>> items = [];
    final entries = text.split(',');
    for (var entry in entries) {
      final parts = entry.trim().split('-');
      if (parts.length >= 2) {
        final name = parts.sublist(0, parts.length - 1).join('-').trim();
        final amount = double.tryParse(parts.last.trim());
        if (name.isNotEmpty && amount != null) {
          items.add({'name': name, 'amount': amount});
        }
      }
    }
    return items;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitSale() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedShopName == null || _selectedShopName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shop')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sale = Sale(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        storeName: _selectedShopName!.trim(),
        date: _selectedDate,
        onlineAmount: _onlineAmount,
        cashAmount: _cashAmount,
        adhocExp: _adhocExpTotal,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await DatabaseService().createSale(sale);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sale'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Shop Name Dropdown
              _buildShopDropdown(),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Online Amount
              TextFormField(
                controller: _onlineAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  labelText: 'Online Amount',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.payment),
                  suffixText: '₹',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF667EEA), width: 2),
                  ),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Cash Amount
              TextFormField(
                controller: _cashAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cash Amount',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.money),
                  suffixText: '₹',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF667EEA), width: 2),
                  ),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Adhoc Expenses (Multi-item format)
              TextFormField(
                controller: _adhocExpController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  labelText: 'Adhoc Exp (item-amount, item-amount)',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.shopping_cart),
                  hintText: 'milk-25, sugar-30, bread-50',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF667EEA), width: 2),
                  ),
                  helperText:
                      'Format: item-amount, item-amount (Total will be deducted)',
                ),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),

              // Show parsed adhoc items
              if (_adhocExpItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expense Breakdown:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._adhocExpItems
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '• ${item['name']}',
                                      style:
                                          const TextStyle(color: Colors.orange),
                                    ),
                                    Text(
                                      '₹${item['amount']}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Expenses:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            '₹${_adhocExpTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Cash deposited (NET TOTAL) - Read-only field
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cashDeposited >= 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _cashDeposited >= 0 ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color:
                              _cashDeposited >= 0 ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cash deposited',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${_cashDeposited.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _cashDeposited >= 0
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes (Optional)
              TextFormField(
                controller: _notesController,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF667EEA), width: 2),
                  ),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Add Sale',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopDropdown() {
    if (_isLoadingShops) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_shops.isEmpty) {
      return Card(
        color: Colors.amber.withOpacity(0.1),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No shops found. Please add shops from Shop Management first.',
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final authProvider = context.watch<AuthProvider>();
    final isShopkeeper = authProvider.isShopkeeper;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedShopName,
            hint: Text(isShopkeeper ? 'Your assigned shop' : 'Select Shop'),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF667EEA)),
            items: _shops.map((shop) {
              return DropdownMenuItem(
                value: shop.shopName,
                child: Row(
                  children: [
                    const Icon(Icons.store, size: 18, color: Color(0xFF667EEA)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shop.shopName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isShopkeeper &&
                        authProvider.currentUser?.shopId == shop.id)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Yours',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: isShopkeeper
                ? null // Shopkeepers cannot change shop
                : (value) {
                    setState(() {
                      _selectedShopName = value;
                    });
                  },
          ),
        ),
      ),
    );
  }
}
