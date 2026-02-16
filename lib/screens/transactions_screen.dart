import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    final userId = await AuthService.getCurrentUserId();
    if (userId != null) {
      _transactions = await DatabaseHelper.instance.getTransactions(userId);
    }

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_filterType == 'all') return _transactions;
    return _transactions.where((t) => t['type'] == _filterType).toList();
  }

  Future<void> _deleteTransaction(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteTransaction(id);
      _loadTransactions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF667eea),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() => _filterType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'income', child: Text('Income')),
              const PopupMenuItem(value: 'expense', child: Text('Expense')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadTransactions,
        child: _filteredTransactions.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              Text(
                'No transactions found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _filteredTransactions.length,
          itemBuilder: (context, index) {
            final transaction = _filteredTransactions[index];
            final date = DateTime.parse(transaction['date']);

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ListTile(
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
                title: Text(
                  transaction['category'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction['description']),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${transaction['amount']}',
                      style: TextStyle(
                        color: transaction['type'] == 'income'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTransaction(transaction['id']),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-transaction');
          _loadTransactions();
        },
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add),
      ),
    );
  }
}