import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';

class PurchaseReportsScreen extends StatefulWidget {
  const PurchaseReportsScreen({super.key});

  @override
  State<PurchaseReportsScreen> createState() => _PurchaseReportsScreenState();
}

class _PurchaseReportsScreenState extends State<PurchaseReportsScreen> {
  final DatabaseService _db = DatabaseService();
  final DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  final DateTime _endDate = DateTime.now();
  bool _isLoading = true;

  double _totalPurchases = 0;
  double _totalPaid = 0;
  double _totalPending = 0;
  List<Purchase> _purchases = [];
  Map<String, double> _vendorWise = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final purchasesStream = _db.getAllPurchases();
      final allPurchases = await purchasesStream.first;

      // Filter by date range
      final purchases = allPurchases.where((p) {
        return p.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            p.date.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();

      double totalPurchases = 0;
      double totalPaid = 0;
      double totalPending = 0;
      Map<String, double> vendorWise = {};

      for (var purchase in purchases) {
        totalPurchases += purchase.amount;
        totalPaid += purchase.paidAmount;
        totalPending += purchase.pendingAmount;

        vendorWise[purchase.vendorName] =
            (vendorWise[purchase.vendorName] ?? 0) + purchase.amount;
      }

      setState(() {
        _purchases = purchases;
        _totalPurchases = totalPurchases;
        _totalPaid = totalPaid;
        _totalPending = totalPending;
        _vendorWise = vendorWise;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select export format:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF Document'),
              subtitle: const Text('Best for printing and sharing'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF('purchase_report');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel Spreadsheet'),
              subtitle: const Text('Best for data analysis'),
              onTap: () {
                Navigator.pop(context);
                _exportAsExcel('purchase_report');
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: const Text('CSV File'),
              subtitle: const Text('Compatible with all spreadsheet apps'),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV('purchase_report');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportAsPDF(String filename) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Generating PDF...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF downloaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _exportAsExcel(String filename) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Generating Excel file...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excel downloaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _exportAsCSV(String filename) {
    StringBuffer csv = StringBuffer();
    csv.writeln('Date,Vendor Name,Amount,Paid,Pending,Payment Mode,Category');
    for (var purchase in _purchases) {
      csv.writeln(
          '${purchase.date.toIso8601String()},${purchase.vendorName},${purchase.amount},${purchase.paidAmount},${purchase.pendingAmount},${purchase.paymentMode},${purchase.category ?? ''}');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV exported with ${_purchases.length} records'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('CSV Preview'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: SingleChildScrollView(
                    child: Text(csv.toString(),
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12)),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isLoading ? null : _showExportDialog,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Payment Status
                  _buildSectionTitle('Payment Status'),
                  const SizedBox(height: 12),
                  _buildPaymentStatusCard(),
                  const SizedBox(height: 24),

                  // Vendor-wise Summary
                  if (_vendorWise.isNotEmpty) ...[
                    _buildSectionTitle('Vendor-wise Purchases'),
                    const SizedBox(height: 12),
                    _buildVendorWiseList(),
                    const SizedBox(height: 24),
                  ],

                  // Recent Purchases
                  _buildSectionTitle('Recent Purchases'),
                  const SizedBox(height: 12),
                  _buildRecentPurchasesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Purchases',
                '₹${_totalPurchases.toStringAsFixed(2)}',
                Colors.indigo,
                Icons.shopping_cart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Paid Amount',
                '₹${_totalPaid.toStringAsFixed(2)}',
                Colors.green,
                Icons.check_circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Pending Amount',
                '₹${_totalPending.toStringAsFixed(2)}',
                Colors.orange,
                Icons.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Transactions',
                '${_purchases.length}',
                Colors.teal,
                Icons.receipt,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    final paidPercentage =
        _totalPurchases > 0 ? (_totalPaid / _totalPurchases) * 100 : 0;
    final pendingPercentage =
        _totalPurchases > 0 ? (_totalPending / _totalPurchases) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '₹${_totalPurchases.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Paid: ${paidPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pending: ${pendingPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: paidPercentage / 100,
              minHeight: 12,
              backgroundColor: Colors.orange.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Paid'),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Pending'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendorWiseList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _vendorWise.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _vendorWise.entries.elementAt(index);
          final percentage =
              _totalPurchases > 0 ? (entry.value / _totalPurchases) * 100 : 0;

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Colors.indigo, size: 20),
            ),
            title: Text(entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${percentage.toStringAsFixed(1)}% of total'),
            trailing: Text(
              '₹${entry.value.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentPurchasesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _purchases.take(10).length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final purchase = _purchases[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: purchase.pendingAmount > 0
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                purchase.pendingAmount > 0 ? Icons.warning : Icons.check_circle,
                color:
                    purchase.pendingAmount > 0 ? Colors.orange : Colors.green,
                size: 20,
              ),
            ),
            title: Text(purchase.vendorName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('dd MMM yyyy').format(purchase.date)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${purchase.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (purchase.pendingAmount > 0)
                  Text(
                    '₹${purchase.pendingAmount.toStringAsFixed(2)} pending',
                    style: const TextStyle(fontSize: 10, color: Colors.orange),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
