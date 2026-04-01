import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../models/models.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final databaseService = DatabaseService();

    // Only Admin and Manager can access
    if (authProvider.isShopkeeper) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Purchases'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.orange[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Access Restricted',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Only managers and admins can view purchases',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.orange[600], size: 20),
                const SizedBox(width: 8),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return StreamBuilder<List<Purchase>>(
                      stream: databaseService.getAllPurchases(),
                      builder: (context, snapshot) {
                        final purchases = snapshot.data ?? [];
                        return Text(
                          '${purchases.length} Purchases',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Purchase>>(
        stream: databaseService.getAllPurchases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading purchases',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final purchases = snapshot.data ?? [];

          if (purchases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.shopping_cart,
                      size: 80,
                      color: Colors.orange[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No purchase entries yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first purchase',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: Colors.indigo,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final purchase = purchases[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with vendor name and amount
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.business,
                                color: Colors.orange,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    purchase.vendorName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '₹${purchase.amount.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange[700],
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (purchase.billPhotoPath != null)
                              IconButton(
                                icon: const Icon(Icons.visibility,
                                    color: Colors.blue),
                                onPressed: () => _viewBillPhoto(
                                    context, purchase.billPhotoPath!),
                              ),
                            if (authProvider.isAdmin)
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditPurchaseDialog(context, purchase);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(context, purchase);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete,
                                            size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Date and category
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd MMM yyyy, hh:mm a')
                                  .format(purchase.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            if (purchase.category != null) ...[
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  purchase.category!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Bill photo indicator
                        if (purchase.billPhotoPath != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 16,
                                  color: Colors.green[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bill photo attached',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Payment Status
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: purchase.pendingAmount > 0
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: purchase.pendingAmount > 0
                                  ? Colors.orange
                                  : Colors.green,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        purchase.paymentMode == 'Online'
                                            ? Icons.credit_card
                                            : Icons.money,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Mode: ${purchase.paymentMode}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    purchase.pendingAmount > 0
                                        ? '₹${purchase.pendingAmount.toStringAsFixed(2)} Pending'
                                        : 'Fully Paid',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: purchase.pendingAmount > 0
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Paid:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '₹${purchase.paidAmount.toStringAsFixed(2)} / ₹${purchase.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Notes if available
                        if (purchase.notes != null &&
                            purchase.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.note,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  purchase.notes!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.indigo, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddPurchaseDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _viewBillPhoto(BuildContext context, String photoPath) {
    final storageService = StorageService();
    final photoUrl = storageService.getPublicUrl(photoPath);

    if (photoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo not available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Bill Photo'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Image.network(photoUrl),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddPurchaseDialog(),
    );
  }

  void _showEditPurchaseDialog(BuildContext context, Purchase purchase) {
    showDialog(
      context: context,
      builder: (context) => EditPurchaseDialog(purchase: purchase),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Purchase purchase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete purchase from "${purchase.vendorName}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Amount: ₹${purchase.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ],
                  ),
                  if (purchase.pendingAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Pending: ₹${purchase.pendingAmount.toStringAsFixed(2)} will be cleared',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService().deletePurchase(purchase.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Purchase deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class EditPurchaseDialog extends StatefulWidget {
  final Purchase purchase;

  EditPurchaseDialog({required this.purchase});

  @override
  State<EditPurchaseDialog> createState() => _EditPurchaseDialogState();
}

class _EditPurchaseDialogState extends State<EditPurchaseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vendorController;
  late TextEditingController _amountController;
  late TextEditingController _paidAmountController;
  late TextEditingController _notesController;

  XFile? _billPhoto;
  bool _isLoading = false;
  late DateTime _selectedDate;
  late String _paymentMode;

  @override
  void initState() {
    super.initState();
    _vendorController = TextEditingController(text: widget.purchase.vendorName);
    _amountController =
        TextEditingController(text: widget.purchase.amount.toString());
    _paidAmountController =
        TextEditingController(text: widget.purchase.paidAmount.toString());
    _notesController = TextEditingController(text: widget.purchase.notes ?? '');
    _selectedDate = widget.purchase.date;
    _paymentMode = widget.purchase.paymentMode;
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _amountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return double.tryParse(_amountController.text) ?? 0;
  }

  double get _paidAmount {
    return double.tryParse(_paidAmountController.text) ?? 0;
  }

  double get _pendingAmount {
    return _totalAmount - _paidAmount;
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

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final picked = await imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _billPhoto = picked);
    }
  }

  Future<void> _submitPurchase() async {
    if (!_formKey.currentState!.validate()) return;

    if (_paidAmount > _totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Paid amount cannot be greater than total amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final databaseService = DatabaseService();
      final storageService = StorageService();

      String? billPhotoPath = widget.purchase.billPhotoPath;
      if (_billPhoto != null) {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        billPhotoPath =
            await storageService.uploadBillPhoto(tempId, _billPhoto!);
      }

      await databaseService.updatePurchase(widget.purchase.id, {
        'vendorname': _vendorController.text.trim(),
        'amount': _totalAmount,
        'billphotopath': billPhotoPath,
        'date': _selectedDate.toIso8601String(),
        'category': 'Stock',
        'paymentmode': _paymentMode,
        'paidamount': _paidAmount,
        'pendingamount': _pendingAmount,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase updated successfully')),
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
    return AlertDialog(
      title: const Text('Edit Purchase'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Field
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

              // Vendor Name
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor Name',
                  prefixIcon: Icon(Icons.person),
                  helperText: 'Tip: Type to search existing vendors',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Total Amount
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Total Amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                  suffixText: '₹',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Payment Mode
              DropdownButtonFormField<String>(
                value: _paymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'Online', child: Text('Online')),
                ],
                onChanged: (value) {
                  setState(() => _paymentMode = value!);
                },
              ),
              const SizedBox(height: 16),

              // Paid Amount
              TextFormField(
                controller: _paidAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount Paid',
                  prefixIcon: Icon(Icons.currency_rupee),
                  suffixText: '₹',
                  helperText: 'Leave empty if fully paid on credit',
                ),
                validator: (value) {
                  if (value != null && double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Payment Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _pendingAmount > 0
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _pendingAmount > 0 ? Colors.orange : Colors.green,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        Text(
                          '₹${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Paid Amount:',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        Text(
                          '₹${_paidAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pending Amount:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _pendingAmount > 0
                              ? '₹${_pendingAmount.toStringAsFixed(2)}'
                              : 'Fully Paid',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _pendingAmount > 0
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes (Optional)
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Upload Bill Photo
              InkWell(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.image),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _billPhoto == null
                              ? 'Upload New Bill Photo (Optional)'
                              : 'New photo selected: ${_billPhoto!.name}',
                        ),
                      ),
                      if (_billPhoto != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() => _billPhoto = null);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitPurchase,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Update Purchase'),
        ),
      ],
    );
  }
}

class AddPurchaseDialog extends StatefulWidget {
  @override
  State<AddPurchaseDialog> createState() => _AddPurchaseDialogState();
}

class _AddPurchaseDialogState extends State<AddPurchaseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vendorController = TextEditingController();
  final _amountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _notesController = TextEditingController();

  XFile? _billPhoto;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  String _paymentMode = 'Cash';
  List<String> _existingVendors = [];
  bool _showVendorSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadExistingVendors();
  }

  Future<void> _loadExistingVendors() async {
    try {
      final purchases = await DatabaseService().getAllPurchases().first;
      final uniqueVendors = purchases.map((p) => p.vendorName).toSet().toList();
      setState(() {
        _existingVendors = uniqueVendors..sort();
      });
    } catch (e) {
      debugPrint('Error loading vendors: $e');
    }
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _amountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return double.tryParse(_amountController.text) ?? 0;
  }

  double get _paidAmount {
    return double.tryParse(_paidAmountController.text) ?? 0;
  }

  double get _pendingAmount {
    return _totalAmount - _paidAmount;
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

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final picked = await imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _billPhoto = picked);
    }
  }

  Future<void> _submitPurchase() async {
    if (!_formKey.currentState!.validate()) return;

    if (_paidAmount > _totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Paid amount cannot be greater than total amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final databaseService = DatabaseService();
      final storageService = StorageService();

      // Upload bill photo if exists
      String? billPhotoPath;
      if (_billPhoto != null) {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        billPhotoPath =
            await storageService.uploadBillPhoto(tempId, _billPhoto!);
      }

      final purchase = Purchase(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vendorName: _vendorController.text.trim(),
        amount: _totalAmount,
        billPhotoPath: billPhotoPath,
        date: _selectedDate,
        category: 'Stock',
        paymentMode: _paymentMode,
        paidAmount: _paidAmount,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await databaseService.createPurchase(purchase);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase added successfully')),
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
    return AlertDialog(
      title: const Text('Add Purchase'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Field
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

              // Vendor Name
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor Name',
                  prefixIcon: Icon(Icons.person),
                  helperText: 'Tip: Type to search existing vendors',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Total Amount
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Total Amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                  suffixText: '₹',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Payment Mode
              DropdownButtonFormField<String>(
                value: _paymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'Online', child: Text('Online')),
                ],
                onChanged: (value) {
                  setState(() => _paymentMode = value!);
                },
              ),
              const SizedBox(height: 16),

              // Paid Amount
              TextFormField(
                controller: _paidAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount Paid',
                  prefixIcon: Icon(Icons.currency_rupee),
                  suffixText: '₹',
                  helperText: 'Leave empty if fully paid on credit',
                ),
                validator: (value) {
                  if (value != null && double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Payment Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _pendingAmount > 0
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _pendingAmount > 0 ? Colors.orange : Colors.green,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Paid Amount:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${_paidAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pending Amount:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _pendingAmount > 0
                              ? '₹${_pendingAmount.toStringAsFixed(2)}'
                              : 'Fully Paid',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _pendingAmount > 0
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes (Optional)
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Upload Bill Photo
              InkWell(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.image),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _billPhoto == null
                              ? 'Upload Bill Photo (Optional)'
                              : 'Photo selected: ${_billPhoto!.name}',
                        ),
                      ),
                      if (_billPhoto != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() => _billPhoto = null);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitPurchase,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Add Purchase'),
        ),
      ],
    );
  }
}
