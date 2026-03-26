import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/sale.dart';

class EditSaleScreen extends StatefulWidget {
  final Sale sale;

  const EditSaleScreen({super.key, required this.sale});

  @override
  State<EditSaleScreen> createState() => _EditSaleScreenState();
}

class _EditSaleScreenState extends State<EditSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _onlineAmountController;
  late TextEditingController _cashAmountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late String _selectedStoreName;
  bool _isLoading = false;
  List<String> _storeNames = [];
  bool _isLoadingStores = true;
  bool _isAddingNewStore = false;
  final _newStoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStoreName = widget.sale.storeName;
    _onlineAmountController = TextEditingController(
      text: widget.sale.onlineAmount.toString(),
    );
    _cashAmountController = TextEditingController(
      text: widget.sale.cashAmount.toString(),
    );
    _notesController = TextEditingController(text: widget.sale.notes ?? '');
    _selectedDate = widget.sale.date;
    _loadStoreNames();
  }

  Future<void> _loadStoreNames() async {
    try {
      final sales = await DatabaseService().getAllSales().first;
      final uniqueStores = sales.map((s) => s.storeName).toSet().toList();
      setState(() {
        _storeNames = uniqueStores..sort();
        _isLoadingStores = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStores = false;
      });
    }
  }

  @override
  void dispose() {
    _onlineAmountController.dispose();
    _cashAmountController.dispose();
    _notesController.dispose();
    _newStoreController.dispose();
    super.dispose();
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

  Future<void> _updateSale() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseService().updateSale(widget.sale.id, {
        'storename': _selectedStoreName,
        'date': _selectedDate.toIso8601String(),
        'onlineamount': double.parse(_onlineAmountController.text),
        'cashamount': double.parse(_cashAmountController.text),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale updated successfully')),
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
        title: const Text('Edit Sale'),
        actions: [
          if (_isAddingNewStore)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_newStoreController.text.trim().isNotEmpty) {
                  setState(() {
                    _selectedStoreName = _newStoreController.text.trim();
                    if (!_storeNames.contains(_selectedStoreName)) {
                      _storeNames.add(_selectedStoreName!);
                      _storeNames.sort();
                    }
                    _isAddingNewStore = false;
                  });
                }
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.add_business),
              tooltip: 'Add New Store',
              onPressed: () {
                setState(() {
                  _isAddingNewStore = true;
                  _selectedStoreName = '';
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Store Name Dropdown or Text Field
              if (_isAddingNewStore) ...[
                TextFormField(
                  controller: _newStoreController,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'New Store Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.add_business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide:
                          BorderSide(color: Color(0xFF667EEA), width: 2),
                    ),
                    helperText: 'Enter new store name',
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    if (_newStoreController.text.trim().isNotEmpty) {
                      setState(() {
                        _selectedStoreName = _newStoreController.text.trim();
                        if (!_storeNames.contains(_selectedStoreName)) {
                          _storeNames.add(_selectedStoreName!);
                          _storeNames.sort();
                        }
                        _isAddingNewStore = false;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter store name';
                    }
                    return null;
                  },
                ),
              ] else ...[
                _buildStoreDropdown(),
              ],
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
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  labelText: 'Notes',
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

              // Update Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateSale,
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
                        'Update Sale',
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

  Widget _buildStoreDropdown() {
    if (_isLoadingStores) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Ensure current sale's store is in the list
    if (!_storeNames.contains(_selectedStoreName)) {
      _storeNames.add(_selectedStoreName);
      _storeNames.sort();
    }

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
            value: _storeNames.contains(_selectedStoreName)
                ? _selectedStoreName
                : null,
            hint: const Text('Select Store'),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF667EEA)),
            items: _storeNames.map((store) {
              return DropdownMenuItem(
                value: store,
                child: Row(
                  children: [
                    const Icon(Icons.store, size: 18, color: Color(0xFF667EEA)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        store,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStoreName = value!;
              });
            },
          ),
        ),
      ),
    );
  }
}
