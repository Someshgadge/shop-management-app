import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';

enum DateFilterType { daily, weekly, monthly, yearly, custom }

class ShopSalesDetailScreen extends StatefulWidget {
  final Shop shop;

  const ShopSalesDetailScreen({super.key, required this.shop});

  @override
  State<ShopSalesDetailScreen> createState() => _ShopSalesDetailScreenState();
}

class _ShopSalesDetailScreenState extends State<ShopSalesDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();

  DateFilterType _selectedFilter = DateFilterType.daily;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  int _selectedYear = DateTime.now().year;

  List<Sale> _sales = [];
  double _totalSales = 0;
  double _totalOnline = 0;
  double _totalCash = 0;
  double _totalAdhocExp = 0;
  double _netTotal = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() async {
    setState(() => _isLoading = true);

    DateTime start, end;

    switch (_selectedFilter) {
      case DateFilterType.daily:
        start = DateTime(_startDate.year, _startDate.month, _startDate.day);
        end = start.add(const Duration(days: 1));
        break;
      case DateFilterType.weekly:
        start = _startDate.subtract(Duration(days: _startDate.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        end = start.add(const Duration(days: 7));
        break;
      case DateFilterType.monthly:
        start = DateTime(_startDate.year, _startDate.month, 1);
        end = DateTime(_startDate.year, _startDate.month + 1, 0, 23, 59, 59);
        break;
      case DateFilterType.yearly:
        start = DateTime(_selectedYear, 1, 1);
        end = DateTime(_selectedYear, 12, 31, 23, 59, 59);
        break;
      case DateFilterType.custom:
        start = DateTime(_startDate.year, _startDate.month, _startDate.day);
        end = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
        break;
    }

    try {
      // Get the shop name and normalize it
      final shopName = widget.shop.shopName.trim().toLowerCase();

      // Get all sales in date range
      final salesStream = _databaseService.getAllSalesInDateRange(start, end);

      await salesStream.first.then((allSales) {
        // Filter sales for THIS shop only (case-insensitive)
        final filteredSales = allSales.where((sale) {
          return sale.storeName.trim().toLowerCase() == shopName;
        }).toList();

        setState(() {
          _sales = filteredSales;
          _totalSales =
              filteredSales.fold(0, (sum, sale) => sum + sale.totalAmount);
          _totalOnline =
              filteredSales.fold(0, (sum, sale) => sum + sale.onlineAmount);
          _totalCash =
              filteredSales.fold(0, (sum, sale) => sum + sale.cashAmount);
          _totalAdhocExp =
              filteredSales.fold(0, (sum, sale) => sum + sale.adhocExp);
          _netTotal = filteredSales.fold(0, (sum, sale) => sum + sale.netTotal);
        });
      });
    } catch (e) {
      debugPrint('Error loading sales: $e');
      setState(() {
        _sales = [];
        _totalSales = 0;
        _totalOnline = 0;
        _totalCash = 0;
        _totalAdhocExp = 0;
        _netTotal = 0;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
      _loadSales();
    }
  }

  Future<void> _selectYear(BuildContext context) async {
    final int currentYear = DateTime.now().year;
    final int? picked = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: 100,
            height: 300,
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                final year = currentYear - index;
                return ListTile(
                  title: Text(year.toString()),
                  selected: year == _selectedYear,
                  onTap: () => Navigator.pop(context, year),
                );
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedYear = picked);
      _loadSales();
    }
  }

  String get _filterTitle {
    switch (_selectedFilter) {
      case DateFilterType.daily:
        return DateFormat('dd MMM yyyy').format(_startDate);
      case DateFilterType.weekly:
        final start =
            _startDate.subtract(Duration(days: _startDate.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
      case DateFilterType.monthly:
        return DateFormat('MMMM yyyy').format(_startDate);
      case DateFilterType.yearly:
        return _selectedYear.toString();
      case DateFilterType.custom:
        return '${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.shop.shopName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _filterTitle,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          PopupMenuButton<DateFilterType>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
              _loadSales();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DateFilterType.daily,
                child: Row(
                  children: [
                    Icon(Icons.today),
                    SizedBox(width: 8),
                    Text('Daily'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: DateFilterType.weekly,
                child: Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(width: 8),
                    Text('Weekly'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: DateFilterType.monthly,
                child: Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: 8),
                    Text('Monthly'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: DateFilterType.yearly,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 8),
                    Text('Yearly'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: DateFilterType.custom,
                child: Row(
                  children: [
                    Icon(Icons.calendar_view_month),
                    SizedBox(width: 8),
                    Text('Custom Range'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Daily', DateFilterType.daily),
                  const SizedBox(width: 8),
                  _buildFilterChip('Weekly', DateFilterType.weekly),
                  const SizedBox(width: 8),
                  _buildFilterChip('Monthly', DateFilterType.monthly),
                  const SizedBox(width: 8),
                  _buildFilterChip('Yearly', DateFilterType.yearly),
                  const SizedBox(width: 8),
                  _buildFilterChip('Custom', DateFilterType.custom),
                ],
              ),
            ),
          ),

          // Date selector for custom range
          if (_selectedFilter == DateFilterType.custom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, isStart: true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'From',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(_startDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, isStart: false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'To',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(_endDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Year selector for yearly view
          if (_selectedFilter == DateFilterType.yearly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () => _selectYear(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Year: $_selectedYear',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.purple),
                    ],
                  ),
                ),
              ),
            ),

          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Sales',
                        '₹${_totalSales.toStringAsFixed(2)}',
                        Colors.indigo,
                        Icons.point_of_sale,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Online',
                        '₹${_totalOnline.toStringAsFixed(2)}',
                        Colors.blue,
                        Icons.payment,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Cash',
                        '₹${_totalCash.toStringAsFixed(2)}',
                        Colors.green,
                        Icons.money,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Adhoc Exp',
                        '₹${_totalAdhocExp.toStringAsFixed(2)}',
                        Colors.orange,
                        Icons.shopping_cart,
                        isDeduction: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNetTotalCard(),
                    ),
                    const SizedBox(width: 12),
                    // Empty card for spacing or can show sales count
                    Expanded(
                      child: _buildSummaryCard(
                        'Sales',
                        '${_sales.length}',
                        Colors.purple,
                        Icons.receipt,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sales list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    ),
                  )
                : _sales.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No sales for this period',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different date range',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sales.length,
                        itemBuilder: (context, index) {
                          final sale = _sales[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.store,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sale.storeName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat(
                                                          'dd MMM yyyy, hh:mm a')
                                                      .format(sale.date),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '₹${sale.totalAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Payment breakdown with Adhoc and Net Total
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: const Icon(
                                                      Icons.payment,
                                                      color: Colors.blue,
                                                      size: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Online',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        '₹${sale.onlineAmount.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 1,
                                              height: 30,
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: const Icon(
                                                      Icons.money,
                                                      color: Colors.green,
                                                      size: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Cash',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        '₹${sale.cashAmount.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Adhoc Exp and Net Total row
                                        if (sale.adhocExp > 0 ||
                                            sale.netTotal !=
                                                sale.totalAmount) ...[
                                          const SizedBox(height: 12),
                                          const Divider(height: 1),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: const Icon(
                                                        Icons.shopping_cart,
                                                        color: Colors.orange,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Adhoc Exp',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        Text(
                                                          '- ₹${sale.adhocExp.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 1,
                                                height: 30,
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration: BoxDecoration(
                                                        color: sale.netTotal >=
                                                                0
                                                            ? Colors.green
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors.red
                                                                .withOpacity(
                                                                    0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .account_balance_wallet,
                                                        color:
                                                            sale.netTotal >= 0
                                                                ? Colors.green
                                                                : Colors.red,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Net Total',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        Text(
                                                          '₹${sale.netTotal.toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                sale.netTotal >= 0
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Notes if available
                                  if (sale.notes != null &&
                                      sale.notes!.isNotEmpty) ...[
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
                                            sale.notes!,
                                            style: TextStyle(
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DateFilterType type) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = type);
        _loadSales();
      },
      selectedColor: Colors.indigo,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, Color color, IconData icon,
      {bool isDeduction = false}) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(isDeduction ? Icons.remove_circle_outline : icon,
                    color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isDeduction ? '- $amount' : amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNetTotalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _netTotal >= 0
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (_netTotal >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Net Total',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${_netTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
