import 'package:finance_manager/services/auth_service.dart';
import 'package:finance_manager/services/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _user = await AuthService.getCurrentUser();
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
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile').then((_) => _loadData());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsCards(),
              _buildQuickActions(),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-transaction');
          _loadData();
        },
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF667eea),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/transactions').then((_) => _loadData());
              break;
            case 2:
              Navigator.pushNamed(context, '/reports').then((_) => _loadData());
              break;
            case 3:
              Navigator.pushNamed(context, '/profile').then((_) => _loadData());
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${_user?['username'] ?? 'User'}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here\'s your financial overview',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalIncome = (_stats?['total_income'] ?? 0.0).toDouble();
    final totalExpense = (_stats?['total_expense'] ?? 0.0).toDouble();
    final balance = (_stats?['balance'] ?? 0.0).toDouble();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Income',
                  '₹${totalIncome.toStringAsFixed(2)}',
                  Icons.arrow_downward,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Expense',
                  '₹${totalExpense.toStringAsFixed(2)}',
                  Icons.arrow_upward,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Balance',
            '₹${balance.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            balance >= 0 ? Colors.blue : Colors.orange,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      String amount,
      IconData icon,
      Color color, {
        bool isLarge = false,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(isLarge ? 24 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.7), color],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: Colors.white, size: isLarge ? 32 : 24),
              ],
            ),
            SizedBox(height: isLarge ? 16 : 12),
            Text(
              amount,
              style: TextStyle(
                color: Colors.white,
                fontSize: isLarge ? 32 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    'Add Income',
                    Icons.add_circle,
                    Colors.green,
                        () {
                      Navigator.pushNamed(context, '/add-transaction', arguments: 'income')
                          .then((_) => _loadData());
                    },
                  ),
                  _buildQuickActionButton(
                    'Add Expense',
                    Icons.remove_circle,
                    Colors.red,
                        () {
                      Navigator.pushNamed(context, '/add-transaction', arguments: 'expense')
                          .then((_) => _loadData());
                    },
                  ),
                  _buildQuickActionButton(
                    'View Reports',
                    Icons.bar_chart,
                    Colors.blue,
                        () {
                      Navigator.pushNamed(context, '/reports').then((_) => _loadData());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
      String label,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final recentTransactions = _stats?['recent_transactions'] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/transactions').then((_) => _loadData());
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (recentTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...recentTransactions.take(5).map((transaction) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction['type'] == 'income'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      child: Icon(
                        transaction['type'] == 'income'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction['type'] == 'income'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(transaction['category'] ?? 'Unknown'),
                    subtitle: Text(transaction['description'] ?? ''),
                    trailing: Text(
                      '₹${transaction['amount']}',
                      style: TextStyle(
                        color: transaction['type'] == 'income'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}