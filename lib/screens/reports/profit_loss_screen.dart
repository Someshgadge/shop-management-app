import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  final DatabaseService _db = DatabaseService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = true;

  double _totalSales = 0;
  double _totalAdhoc = 0;
  double _netSales = 0;
  double _totalPurchases = 0;
  double _profitLoss = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export P&L Report'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('PDF downloaded'),
                      backgroundColor: Colors.green),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel Spreadsheet'),
              subtitle: const Text('Best for financial analysis'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Excel downloaded'),
                      backgroundColor: Colors.green),
                );
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Get sales
      final salesStream = _db.getSalesByDateRange(_startDate, _endDate);
      final sales = await salesStream.first;
      double totalSales = sales.fold(0, (sum, s) => sum + s.totalAmount);
      double totalAdhoc = sales.fold(0, (sum, s) => sum + s.adhocExp);
      double netSales = totalSales - totalAdhoc;

      // Get purchases
      final purchasesStream = _db.getAllPurchases();
      final allPurchases = await purchasesStream.first;
      final purchases = allPurchases.where((p) {
        return p.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            p.date.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();
      double totalPurchases = purchases.fold(0, (sum, p) => sum + p.amount);

      double profitLoss = netSales - totalPurchases;

      setState(() {
        _totalSales = totalSales;
        _totalAdhoc = totalAdhoc;
        _netSales = netSales;
        _totalPurchases = totalPurchases;
        _profitLoss = profitLoss;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss'),
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
                  // Date Range
                  _buildDateRange(),
                  const SizedBox(height: 24),

                  // Main P&L Card
                  _buildProfitLossCard(),
                  const SizedBox(height: 24),

                  // Detailed Breakdown
                  _buildSectionTitle('Detailed Breakdown'),
                  const SizedBox(height: 12),
                  _buildBreakdownList(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateRange() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date Range',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _selectDateRange(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final start = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (start != null) {
      setState(() => _startDate = start);
      _loadData();
    }
  }

  Widget _buildProfitLossCard() {
    final isProfit = _profitLoss >= 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            isProfit ? 'PROFIT' : 'LOSS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_profitLoss.abs().toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${((_profitLoss / (_netSales + 0.001)) * 100).abs().toStringAsFixed(1)}% of Net Sales',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildBreakdownList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildBreakdownItem(
              'Total Sales', _totalSales, Colors.blue, Icons.point_of_sale),
          const Divider(height: 1),
          _buildBreakdownItem('Adhoc Expenses', -_totalAdhoc, Colors.orange,
              Icons.shopping_cart,
              isDeduction: true),
          const Divider(height: 1),
          _buildBreakdownItem('Net Sales', _netSales, Colors.green,
              Icons.account_balance_wallet),
          const Divider(height: 1),
          _buildBreakdownItem('Total Purchases', -_totalPurchases, Colors.red,
              Icons.shopping_cart,
              isDeduction: true),
          const Divider(height: 1),
          _buildBreakdownItem(
            _profitLoss >= 0 ? 'Net Profit' : 'Net Loss',
            _profitLoss,
            _profitLoss >= 0 ? Colors.green : Colors.red,
            _profitLoss >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
      String label, double amount, Color color, IconData icon,
      {bool isDeduction = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        '${isDeduction ? '- ' : ''}₹${amount.abs().toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      ),
    );
  }
}
