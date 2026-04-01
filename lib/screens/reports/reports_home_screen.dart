import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import 'sales_reports_screen.dart';
import 'purchase_reports_screen.dart';
import 'distribution_reports_screen.dart';
import 'profit_loss_screen.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Shopkeepers have limited report access
    if (authProvider.isShopkeeper) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assessment,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Reports Access Restricted',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Detailed reports are available only for Admin and Manager roles',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Reports'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh logic can be added here
            },
            tooltip: 'Refresh Reports',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(context),
            const SizedBox(height: 24),

            // Report Categories
            _buildSectionTitle('📊 Sales Reports'),
            const SizedBox(height: 12),
            _buildSalesReportsGrid(context),
            const SizedBox(height: 24),

            _buildSectionTitle('🛒 Purchase Reports'),
            const SizedBox(height: 12),
            _buildPurchaseReportsGrid(context),
            const SizedBox(height: 24),

            _buildSectionTitle('📦 Distribution Reports'),
            const SizedBox(height: 12),
            _buildDistributionReportsGrid(context),
            const SizedBox(height: 24),

            _buildSectionTitle('💰 Financial Reports'),
            const SizedBox(height: 12),
            _buildFinancialReportsGrid(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assessment,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickStatCard(
                context,
                'Today\'s Sales',
                'Loading...',
                Colors.green,
                Icons.point_of_sale,
                'sales_today',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                context,
                'Pending Payments',
                'Loading...',
                Colors.orange,
                Icons.payment,
                'pending_payments',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                context,
                'Active Shops',
                'Loading...',
                Colors.blue,
                Icons.store,
                'active_shops',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
    String type,
  ) {
    return FutureBuilder(
      future: _getQuickStat(type),
      builder: (context, snapshot) {
        final displayValue = snapshot.hasData ? snapshot.data.toString() : value;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 12),
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
                displayValue,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getQuickStat(String type) async {
    final db = DatabaseService();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    switch (type) {
      case 'sales_today':
        final total = await db.getTotalSalesAmount(todayStart, todayEnd);
        return '₹${total.toStringAsFixed(0)}';
      case 'pending_payments':
        // This would need a new database method
        return '₹0';
      case 'active_shops':
        final shops = await db.getAllShops().first;
        return '${shops.length}';
      default:
        return 'N/A';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSalesReportsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildReportCard(
          context,
          'Sales Summary',
          'Overall sales performance',
          Icons.assessment,
          Colors.blue,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SalesReportsScreen(),
              ),
            );
          },
        ),
        _buildReportCard(
          context,
          'Shop-wise Sales',
          'Performance by shop',
          Icons.store,
          Colors.green,
          () {
            // Navigate to shop-wise sales
          },
        ),
        _buildReportCard(
          context,
          'Daily Trends',
          'Day-by-day analysis',
          Icons.trending_up,
          Colors.purple,
          () {
            // Navigate to daily trends
          },
        ),
        _buildReportCard(
          context,
          'Payment Analysis',
          'Cash vs Online',
          Icons.payment,
          Colors.orange,
          () {
            // Navigate to payment analysis
          },
        ),
      ],
    );
  }

  Widget _buildPurchaseReportsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildReportCard(
          context,
          'Purchase Summary',
          'Total purchases & vendors',
          Icons.shopping_cart,
          Colors.indigo,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PurchaseReportsScreen(),
              ),
            );
          },
        ),
        _buildReportCard(
          context,
          'Pending Payments',
          'Outstanding dues',
          Icons.warning,
          Colors.red,
          () {
            // Navigate to pending payments
          },
        ),
        _buildReportCard(
          context,
          'Vendor-wise',
          'By supplier',
          Icons.people,
          Colors.teal,
          () {
            // Navigate to vendor-wise
          },
        ),
        _buildReportCard(
          context,
          'Category-wise',
          'By expense type',
          Icons.category,
          Colors.brown,
          () {
            // Navigate to category-wise
          },
        ),
      ],
    );
  }

  Widget _buildDistributionReportsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildReportCard(
          context,
          'Stock Summary',
          'Distribution overview',
          Icons.local_shipping,
          Colors.cyan,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DistributionReportsScreen(),
              ),
            );
          },
        ),
        _buildReportCard(
          context,
          'Shop Inventory',
          'Stock per shop',
          Icons.inventory,
          Colors.lightGreen,
          () {
            // Navigate to shop inventory
          },
        ),
        _buildReportCard(
          context,
          'Acceptance Rate',
          'Accepted vs Rejected',
          Icons.check_circle,
          Colors.green,
          () {
            // Navigate to acceptance rate
          },
        ),
        _buildReportCard(
          context,
          'Pending Stock',
          'Awaiting acceptance',
          Icons.hourglass_empty,
          Colors.orange,
          () {
            // Navigate to pending stock
          },
        ),
      ],
    );
  }

  Widget _buildFinancialReportsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildReportCard(
          context,
          'Profit & Loss',
          'Net business performance',
          Icons.pie_chart,
          Colors.deepPurple,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfitLossScreen(),
              ),
            );
          },
        ),
        _buildReportCard(
          context,
          'Expense Report',
          'Adhoc & operational costs',
          Icons.money_off,
          Colors.red,
          () {
            // Navigate to expense report
          },
        ),
        _buildReportCard(
          context,
          'Export Data',
          'Download reports',
          Icons.download,
          Colors.blue,
          () {
            // Navigate to export
          },
        ),
        _buildReportCard(
          context,
          'Custom Report',
          'Build your own',
          Icons.tune,
          Colors.grey,
          () {
            // Navigate to custom report builder
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
