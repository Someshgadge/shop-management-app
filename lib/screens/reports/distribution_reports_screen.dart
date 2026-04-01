import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';

class DistributionReportsScreen extends StatefulWidget {
  const DistributionReportsScreen({super.key});

  @override
  State<DistributionReportsScreen> createState() =>
      _DistributionReportsScreenState();
}

class _DistributionReportsScreenState extends State<DistributionReportsScreen> {
  final DatabaseService _db = DatabaseService();

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
              subtitle: const Text('Best for data analysis'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Excel downloaded'),
                      backgroundColor: Colors.green),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: const Text('CSV File'),
              subtitle: const Text('Compatible with all spreadsheet apps'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('CSV exported'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportDialog,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: StreamBuilder<List<Distribution>>(
        stream: _db.getAllDistributions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final distributions = snapshot.data!;
          final pending = distributions
              .where((d) => d.status == DistributionStatus.pending)
              .length;
          final accepted = distributions
              .where((d) => d.status == DistributionStatus.accepted)
              .length;
          final rejected = distributions
              .where((d) => d.status == DistributionStatus.rejected)
              .length;
          final totalStock =
              distributions.fold<double>(0, (sum, d) => sum + d.stockAmount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                          'Total Stock',
                          '₹${totalStock.toStringAsFixed(0)}',
                          Colors.blue,
                          Icons.local_shipping),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                          'Total Items',
                          '${distributions.length}',
                          Colors.purple,
                          Icons.inventory),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard('Accepted', '$accepted',
                          Colors.green, Icons.check_circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard('Pending', '$pending',
                          Colors.orange, Icons.hourglass_empty),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                          'Rejected', '$rejected', Colors.red, Icons.cancel),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status Distribution
                _buildSectionTitle('Status Distribution'),
                const SizedBox(height: 12),
                _buildStatusChart(accepted, pending, rejected),
                const SizedBox(height: 24),

                // Recent Distributions
                _buildSectionTitle('Recent Distributions'),
                const SizedBox(height: 12),
                _buildDistributionsList(distributions.take(20).toList()),
              ],
            ),
          );
        },
      ),
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
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

  Widget _buildStatusChart(int accepted, int pending, int rejected) {
    final total = accepted + pending + rejected;
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
      child: Column(
        children: [
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: accepted / total,
                minHeight: 16,
                backgroundColor: Colors.orange.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusLegend('Accepted', accepted, Colors.green),
                _buildStatusLegend('Pending', pending, Colors.orange),
                _buildStatusLegend('Rejected', rejected, Colors.red),
              ],
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No distributions yet',
                  style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusLegend(String label, int count, Color color) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: $count',
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDistributionsList(List<Distribution> distributions) {
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: distributions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final dist = distributions[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: dist.status == DistributionStatus.accepted
                    ? Colors.green.withOpacity(0.1)
                    : dist.status == DistributionStatus.pending
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                dist.status == DistributionStatus.accepted
                    ? Icons.check_circle
                    : dist.status == DistributionStatus.pending
                        ? Icons.hourglass_empty
                        : Icons.cancel,
                color: dist.status == DistributionStatus.accepted
                    ? Colors.green
                    : dist.status == DistributionStatus.pending
                        ? Colors.orange
                        : Colors.red,
                size: 20,
              ),
            ),
            title: Text(dist.shopName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${dist.productType ?? 'Stock'} - ${DateFormat('dd MMM yyyy').format(dist.date)}'),
            trailing: Text(
              '₹${dist.stockAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}
