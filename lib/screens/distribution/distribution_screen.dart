import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final databaseService = DatabaseService();

    // Only Admin and Manager can add distributions
    final canAdd = authProvider.isAdmin || authProvider.isManager;
    final canEditDelete = authProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Trigger rebuild
              });
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StreamBuilder<List<Distribution>>(
          stream: databaseService.getAllDistributions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              );
            }

            final distributions = snapshot.data ?? [];

            if (distributions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No distribution entries yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: distributions.length,
              itemBuilder: (context, index) {
                final dist = distributions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        const Icon(Icons.local_shipping, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dist.shopName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(dist.date),
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.inventory,
                                size: 14, color: Colors.blue.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Stock: ₹${dist.stockAmount.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.blue.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(dist.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dist.status.displayName,
                            style: TextStyle(
                              color: _getStatusColor(dist.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: canEditDelete
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDistributionDialog(context, dist);
                              } else if (value == 'delete') {
                                _showDeleteConfirmation(context, dist);
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
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            );
          }),
      floatingActionButton: canAdd
          ? FloatingActionButton(
              onPressed: () {
                // Show simple add dialog
                _showAddDistributionDialog(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Color _getStatusColor(DistributionStatus status) {
    switch (status) {
      case DistributionStatus.pending:
        return Colors.orange;
      case DistributionStatus.accepted:
        return Colors.green;
      case DistributionStatus.rejected:
        return Colors.red;
    }
  }

  void _showAddDistributionDialog(BuildContext context) {
    final stockAmountController = TextEditingController();
    String? selectedShopName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Distribution'),
        content: StreamBuilder<List<Shop>>(
          stream: DatabaseService().getAllShops(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final shops = snapshot.data ?? [];

            if (shops.isEmpty) {
              return const Text('No shops found. Add a shop first.');
            }

            return StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedShopName,
                      decoration: const InputDecoration(
                        labelText: 'Shop',
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: shops.map((shop) {
                        return DropdownMenuItem(
                          value: shop.shopName,
                          child: Text(
                            shop.managerName != null &&
                                    shop.managerName!.isNotEmpty
                                ? '${shop.shopName} (Manager: ${shop.managerName})'
                                : shop.shopName,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedShopName = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: stockAmountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Stock Amount',
                        prefixIcon: Icon(Icons.inventory),
                        suffixText: '₹',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedShopName == null ||
                  selectedShopName!.isEmpty ||
                  stockAmountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final distribution = Distribution(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                shopName: selectedShopName!.trim(),
                date: DateTime.now(),
                stockAmount: double.parse(stockAmountController.text),
              );

              await DatabaseService().createDistribution(distribution);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Distribution added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDistributionDialog(BuildContext context, Distribution dist) {
    final stockAmountController =
        TextEditingController(text: dist.stockAmount.toString());
    String? selectedShopName = dist.shopName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Distribution'),
        content: StreamBuilder<List<Shop>>(
          stream: DatabaseService().getAllShops(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final shops = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedShopName,
                  decoration: const InputDecoration(
                    labelText: 'Shop',
                    prefixIcon: Icon(Icons.store),
                  ),
                  items: shops.map((shop) {
                    return DropdownMenuItem(
                      value: shop.shopName,
                      child: Text(shop.shopName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedShopName = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stockAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Stock Amount',
                    prefixIcon: Icon(Icons.inventory),
                    suffixText: '₹',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedShopName == null ||
                  selectedShopName!.isEmpty ||
                  stockAmountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              await DatabaseService().updateDistribution(dist.id, {
                'shopname': selectedShopName!.trim(),
                'stockamount': double.parse(stockAmountController.text),
              });

              if (context.mounted) {
                Navigator.pop(context);
                setState(() {}); // Trigger refresh
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Distribution updated successfully')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Distribution dist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Distribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this distribution?',
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
                      const Icon(Icons.store, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Shop: ${dist.shopName}',
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.inventory, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Stock: ₹${dist.stockAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ],
                  ),
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
              await DatabaseService().deleteDistribution(dist.id);
              if (context.mounted) {
                Navigator.pop(context);
                setState(() {}); // Trigger refresh
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Distribution deleted successfully'),
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
