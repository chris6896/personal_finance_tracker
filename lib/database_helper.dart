import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  static const String tableUsers = 'users';
  static const String tableIncome = 'income';
  static const String tableExpenses = 'expenses';
  static const String tableSavings = 'savings';
  static const String tableInvestments = 'investments';

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finance_tracker.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        age INTEGER,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_login TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableIncome(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        frequency TEXT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES $tableUsers(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableExpenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES $tableUsers(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSavings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        target_amount REAL,
        interval TEXT,
        description TEXT,
        last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES $tableUsers(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableInvestments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        asset_name TEXT NOT NULL,
        quantity REAL DEFAULT 0,
        value REAL NOT NULL,
        total_value REAL AS (quantity * value),
        last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('CREATE INDEX idx_income_user_date ON $tableIncome(user_id, date)');
    await db.execute('CREATE INDEX idx_expenses_user_date ON $tableExpenses(user_id, date)');

    await _insertInitialInvestments(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableUsers ADD COLUMN last_login TIMESTAMP');
      await db.execute('ALTER TABLE $tableIncome ADD COLUMN category TEXT');
      await db.execute('ALTER TABLE $tableExpenses ADD COLUMN category TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $tableUsers ADD COLUMN age INTEGER');
      await db.execute('ALTER TABLE $tableUsers ADD COLUMN email TEXT UNIQUE');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $tableIncome ADD COLUMN frequency TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE $tableInvestments ADD COLUMN quantity REAL DEFAULT 0');
      await db.execute('ALTER TABLE $tableInvestments ADD COLUMN total_value REAL AS (quantity * value)');
    }
  }

  Future<void> _insertInitialInvestments(Database db) async {
    final investments = [
      {'asset_name': 'Gold', 'value': 1800.00, 'quantity': 1.0},
      {'asset_name': 'Bitcoin', 'value': 30000.00, 'quantity': 0.5},
      {'asset_name': 'Ethereum', 'value': 2000.00, 'quantity': 2.0},
      {'asset_name': 'SPY', 'value': 400.00, 'quantity': 10.0},
    ];

    Batch batch = db.batch();
    for (var investment in investments) {
      batch.insert(tableInvestments, investment);
    }
    await batch.commit(noResult: true);
  }

  Future<int?> insertUser(String name, int age, String email, String password) async {
    final db = await database;
    try {
      String hashedPassword = _hashPassword(password);
      return await db.insert(tableUsers, {
        'username': name,
        'age': age,
        'email': email,
        'password': hashedPassword,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error inserting user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    final db = await database;
    try {
      final hashedPassword = _hashPassword(password);
      final result = await db.query(
        tableUsers,
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );

      if (result.isNotEmpty) {
        await db.update(
          tableUsers,
          {'last_login': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [result.first['id']],
        );
        return result.first;
      }
    } catch (e) {
      print('Error during signin: $e');
    }
    return null;
  }
  Future<String?> getUsername(int userId) async {
    final db = await database;
    final result = await db.query(
      tableUsers,
      columns: ['username'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty){
      return result.first['username'] as String?;
    }
    return null;
  }
  Future<int> insertIncome(int userId, Map<String, dynamic> income) async {
    final db = await database;
    try {
      income['user_id'] = userId;
      income['created_at'] = DateTime.now().toIso8601String();
      return await db.insert(tableIncome, income);
    } catch (e) {
      print('Error inserting income: $e');
      return -1;
    }
  }

  Future<int> insertExpense(int userId, Map<String, dynamic> expense) async {
    final db = await database;
    try {
      expense['user_id'] = userId;
      expense['created_at'] = DateTime.now().toIso8601String();
      return await db.insert(tableExpenses, expense);
    } catch (e) {
      print('Error inserting expense: $e');
      return -1;
    }
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIncome(int id) async {
    final db = await database;
    return await db.delete(
      tableIncome,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertSavings(int userId, Map<String, dynamic> savings) async {
    final db = await database;
    savings['user_id'] = userId;
    return await db.insert(tableSavings, savings);
  }

  Future<int> updateSavings(int savingsId, Map<String, dynamic> savings) async {
    final db = await database;
    savings['date'] = DateTime.now().toIso8601String();
    return await db.update(
      tableSavings,
      savings,
      where: 'id = ?',
      whereArgs: [savingsId],
    );
  }

  Future<int> deleteSavings(int id) async {
    final db = await database;
    return await db.delete(
      tableSavings,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getUserSavings(int userId) async {
    final db = await database;
    return await db.query(
      tableSavings,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'last_updated DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserIncome(int userId, {String? startDate, String? endDate}) async {
    final db = await database;
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (startDate != null && endDate != null) {
      whereClause += ' AND date BETWEEN ? AND ?';
      whereArgs.addAll([startDate, endDate]);
    }

    return await db.query(
      tableIncome,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC'
    );
  }

  Future<List<Map<String, dynamic>>> getUserExpenses(int userId, {String? startDate, String? endDate}) async {
    final db = await database;
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (startDate != null && endDate != null) {
      whereClause += ' AND date BETWEEN ? AND ?';
      whereArgs.addAll([startDate, endDate]);
    }

    return await db.query(
      tableExpenses,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC'
    );
  }

  Future<List<Map<String, dynamic>>> getIncomeByCategory(int userId, String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM $tableIncome
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY category
    ''', [userId, startDate, endDate]);
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategory(int userId, String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM $tableExpenses
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY category
    ''', [userId, startDate, endDate]);
  }

  Future<double> getUserBalance(int userId) async {
    final db = await database;
    final income = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM $tableIncome
      WHERE user_id = ?
    ''', [userId]);

    final expenses = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM $tableExpenses
      WHERE user_id = ?
    ''', [userId]);

    return (income.first['total'] as num).toDouble() - 
           (expenses.first['total'] as num).toDouble();
  }

  Future<void> updateInvestmentValue(String assetName, double newValue, double quantity) async {
    final db = await database;
    await db.update(
      tableInvestments,
      {
        'value': newValue,
        'quantity': quantity,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'asset_name = ?',
      whereArgs: [assetName],
    );
  }

  Future<List<Map<String, dynamic>>> getInvestments() async {
    final db = await database;
    return await db.query(
      tableInvestments,
      orderBy: 'last_updated DESC',
    );
  }

  Future<int> insertInvestment(Map<String, dynamic> investmentData) async {
    final db = await database;
    investmentData['last_updated'] = DateTime.now().toIso8601String();
    return await db.insert(tableInvestments, investmentData);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
