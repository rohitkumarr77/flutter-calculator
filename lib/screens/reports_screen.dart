import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final userId = await AuthService.getCurrentUserId();
    if (userId != null) {
      _stats = await DatabaseHelper.instance.getDashboardStats(userId);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF667eea),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Financial Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSummaryCard(
                'Total Income',
                '₹${(_stats?['total_income'] ?? 0.0).toStringAsFixed(2)}',
                Colors.green,
                Icons.trending_up,
              ),
              _buildSummaryCard(
                'Total Expense',
                '₹${(_stats?['total_expense'] ?? 0.0).toStringAsFixed(2)}',
                Colors.red,
                Icons.trending_down,
              ),
              _buildSummaryCard(
                'Net Balance',
                '₹${(_stats?['balance'] ?? 0.0).toStringAsFixed(2)}',
                Colors.blue,
                Icons.account_balance,
              ),
              const SizedBox(height: 30),
              const Text(
                'Expense Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildPieChart(),
              const SizedBox(height: 30),
              const Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildCategoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final categoryBreakdown = _stats?['category_breakdown'] as List? ?? [];

    if (categoryBreakdown.isEmpty) {
      return Card(
        elevation: 4,
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const Text(
            'No data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final expenseData = categoryBreakdown
        .where((item) => item['type'] == 'expense')
        .toList();

    if (expenseData.isEmpty) {
      return Card(
        elevation: 4,
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const Text(
            'No expense data',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: expenseData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final total = item['total'] as num;

                    return PieChartSectionData(
                      value: total.toDouble(),
                      title: item['category'],
                      color: colors[index % colors.length],
                      radius: 100,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: expenseData.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: colors[index % colors.length],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item['category']}: ₹${(item['total'] as num).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categoryBreakdown = _stats?['category_breakdown'] as List? ?? [];

    if (categoryBreakdown.isEmpty) {
      return Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: const Text(
            'No transactions yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Column(
        children: categoryBreakdown.map((item) {
          final isIncome = item['type'] == 'income';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              item['category'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(isIncome ? 'Income' : 'Expense'),
            trailing: Text(
              '₹${(item['total'] as num).toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
