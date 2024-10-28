import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'income_tracking_screen.dart';
import 'expense_tracking_screen.dart';
import 'investments_screen.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;
  static int? currentUserId;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'finance_tracker.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'finance_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');

        // Create expenses table
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            amount REAL,
            category TEXT,
            date TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
              ON DELETE CASCADE
          )
        ''');

        // Create income table
        await db.execute('''
          CREATE TABLE income(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            amount REAL,
            frequency TEXT,
            date TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
              ON DELETE CASCADE
          )
        ''');

        // Create investments table
        await db.execute('''
          CREATE TABLE investments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            name TEXT,
            amount REAL,
            quantity REAL,
            type TEXT,
            date TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
              ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // User methods
  Future<int> insertUser(String name, int age, String email, String password) async {
    final db = await database;
    return await db.insert(
      'users',
      {'name': name, 'age': age, 'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      currentUserId = maps.first['id'];
      return maps.first;
    }
    return null;
  }

  // Expense methods
  Future<int> insertExpense(ExpenseEntry expense) async {
    final db = await database;
    return await db.insert(
      'expenses',
      {
        'user_id': currentUserId,
        'amount': expense.amount,
        'category': expense.category,
        'date': expense.date.toIso8601String(),
      },
    );
  }

  Future<List<ExpenseEntry>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [currentUserId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => ExpenseEntry(
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    )).toList();
  }

  Future<int> deleteExpense(ExpenseEntry expense) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'user_id = ? AND amount = ? AND category = ? AND date = ?',
      whereArgs: [
        currentUserId,
        expense.amount,
        expense.category,
        expense.date.toIso8601String(),
      ],
    );
  }

  // Income methods
  Future<int> insertIncome(IncomeEntry income) async {
    final db = await database;
    return await db.insert(
      'income',
      {
        'user_id': currentUserId,
        'amount': income.amount,
        'frequency': income.frequency,
        'date': income.date.toIso8601String(),
      },
    );
  }

  Future<List<IncomeEntry>> getIncome() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income',
      where: 'user_id = ?',
      whereArgs: [currentUserId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => IncomeEntry(
      amount: map['amount'],
      frequency: map['frequency'],
      date: DateTime.parse(map['date']),
    )).toList();
  }

  Future<int> deleteIncome(IncomeEntry income) async {
    final db = await database;
    return await db.delete(
      'income',
      where: 'user_id = ? AND amount = ? AND frequency = ? AND date = ?',
      whereArgs: [
        currentUserId,
        income.amount,
        income.frequency,
        income.date.toIso8601String(),
      ],
    );
  }

  // Investment methods
  Future<int> insertInvestment(InvestmentEntry investment) async {
    final db = await database;
    return await db.insert(
      'investments',
      {
        'user_id': currentUserId,
        'name': investment.name,
        'amount': investment.amount,
        'quantity': investment.quantity,
        'type': investment.type,
        'date': investment.date.toIso8601String(),
      },
    );
  }

  Future<List<InvestmentEntry>> getInvestments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'investments',
      where: 'user_id = ?',
      whereArgs: [currentUserId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => InvestmentEntry(
      name: map['name'],
      amount: map['amount'],
      quantity: map['quantity'],
      type: map['type'],
      date: DateTime.parse(map['date']),
    )).toList();
  }

  Future<int> deleteInvestment(InvestmentEntry investment) async {
    final db = await database;
    return await db.delete(
      'investments',
      where: 'user_id = ? AND name = ? AND amount = ? AND quantity = ? AND type = ? AND date = ?',
      whereArgs: [
        currentUserId,
        investment.name,
        investment.amount,
        investment.quantity,
        investment.type,
        investment.date.toIso8601String(),
      ],
    );
  }

  // Session management
  Future<void> logout() async {
    currentUserId = null;
  }

  Future<void> deleteAccount() async {
    if (currentUserId == null) return;

    final db = await database;
    await db.transaction((txn) async {
      // Delete all user data
      await txn.delete(
        'expenses',
        where: 'user_id = ?',
        whereArgs: [currentUserId],
      );
      
      await txn.delete(
        'income',
        where: 'user_id = ?',
        whereArgs: [currentUserId],
      );
      
      await txn.delete(
        'investments',
        where: 'user_id = ?',
        whereArgs: [currentUserId],
      );
      
      await txn.delete(
        'users',
        where: 'id = ?',
        whereArgs: [currentUserId],
      );
    });
    
    currentUserId = null;
  }
}