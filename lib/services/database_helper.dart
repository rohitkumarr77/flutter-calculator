import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final expenseCategories = [
      {'name': 'Food', 'type': 'expense', 'icon': '🍔'},
      {'name': 'Transport', 'type': 'expense', 'icon': '🚗'},
      {'name': 'Shopping', 'type': 'expense', 'icon': '🛒'},
      {'name': 'Bills', 'type': 'expense', 'icon': '📄'},
      {'name': 'Entertainment', 'type': 'expense', 'icon': '🎬'},
      {'name': 'Health', 'type': 'expense', 'icon': '⚕️'},
      {'name': 'Education', 'type': 'expense', 'icon': '📚'},
      {'name': 'Other', 'type': 'expense', 'icon': '📦'},
    ];

    final incomeCategories = [
      {'name': 'Salary', 'type': 'income', 'icon': '💰'},
      {'name': 'Business', 'type': 'income', 'icon': '💼'},
      {'name': 'Investment', 'type': 'income', 'icon': '📈'},
      {'name': 'Gift', 'type': 'income', 'icon': '🎁'},
      {'name': 'Other', 'type': 'income', 'icon': '💵'},
    ];

    for (var category in [...expenseCategories, ...incomeCategories]) {
      await db.insert('categories', category);
    }
  }

  // User operations
  Future<Map<String, dynamic>?> registerUser(
      String username,
      String email,
      String password,
      ) async {
    final db = await database;

    // Check if email exists
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existing.isNotEmpty) {
      return null; // Email already exists
    }

    // Hash password
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final userId = await db.insert('users', {
      'username': username,
      'email': email,
      'password': hashedPassword,
      'created_at': DateTime.now().toIso8601String(),
    });

    return {
      'id': userId,
      'username': username,
      'email': email,
    };
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Transaction operations
  Future<int> addTransaction({
    required int userId,
    required String type,
    required double amount,
    required String category,
    required String description,
    required String date,
  }) async {
    final db = await database;

    return await db.insert('transactions', {
      'user_id': userId,
      'type': type,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getTransactions(int userId) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, created_at DESC',
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTransaction({
    required int id,
    required String type,
    required double amount,
    required String category,
    required String description,
    required String date,
  }) async {
    final db = await database;
    return await db.update(
      'transactions',
      {
        'type': type,
        'amount': amount,
        'category': category,
        'description': description,
        'date': date,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics
  Future<Map<String, dynamic>> getDashboardStats(int userId) async {
    final db = await database;

    // Total income
    final incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = "income"',
      [userId],
    );
    final totalIncome = incomeResult.first['total'] ?? 0.0;

    // Total expense
    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = "expense"',
      [userId],
    );
    final totalExpense = expenseResult.first['total'] ?? 0.0;

    // Recent transactions
    final recentTransactions = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 10,
    );

    // Category breakdown
    final categoryBreakdown = await db.rawQuery('''
      SELECT category, SUM(amount) as total, type 
      FROM transactions 
      WHERE user_id = ? 
      GROUP BY category, type
      ORDER BY total DESC
    ''', [userId]);

    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'balance': (totalIncome as double) - (totalExpense as double),
      'recent_transactions': recentTransactions,
      'category_breakdown': categoryBreakdown,
    };
  }

  Future<List<Map<String, dynamic>>> getCategories(String type) async {
    final db = await database;
    return await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
