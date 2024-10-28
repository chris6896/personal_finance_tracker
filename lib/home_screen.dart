import 'package:flutter/material.dart';
import 'income_tracking_screen.dart';
import 'expense_tracking_screen.dart';
import 'investments_screen.dart';
import 'review_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<ExpenseEntry> initialExpenses;
  final List<IncomeEntry> initialIncome;
  final List<InvestmentEntry> initialInvestments;

  const HomeScreen({
    Key? key,
    this.initialExpenses = const [],
    this.initialIncome = const [],
    this.initialInvestments = const [],
  }) : super(key: key);
  
  // ... rest of the class

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ExpenseEntry> _expenseHistory = [];
  List<IncomeEntry> _incomeHistory = [];
  List<InvestmentEntry> _investmentHistory = [];

  Map<String, double> _calculateExpensesByCategory() {
    final Map<String, double> categoryTotals = {};
    for (var expense in _expenseHistory) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return Map.fromEntries(
      categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
  }

  double get totalExpenses {
    return _expenseHistory.fold(0, (sum, expense) => sum + expense.amount);
  }

  void _navigateToScreen(BuildContext context, String screenName) async {
    // Close the drawer
    Navigator.pop(context);
    
    switch (screenName) {
      case 'Income Tracking':
        final result = await Navigator.push<List<IncomeEntry>>(
          context,
          MaterialPageRoute(
            builder: (context) => IncomeTrackingScreen(
              initialHistory: _incomeHistory,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            _incomeHistory = result;
          });
        }
        break;
      
      case 'Expense Tracking':
        final result = await Navigator.push<List<ExpenseEntry>>(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseTrackingScreen(
              initialHistory: _expenseHistory,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            _expenseHistory = result;
          });
        }
        break;
      
      case 'Investment Tracking':
        final result = await Navigator.push<List<InvestmentEntry>>(
          context,
          MaterialPageRoute(
            builder: (context) => InvestmentsScreen(
              initialInvestments: _investmentHistory,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            _investmentHistory = result;
          });
        }
        break;
      
      case 'Review':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewScreen(
              expenseHistory: _expenseHistory,
              incomeHistory: _incomeHistory,
              investmentHistory: _investmentHistory,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesByCategory = _calculateExpensesByCategory();
    final total = totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Tracker'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Finance Tracker',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your finances',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text('Income Tracking'),
              onTap: () => _navigateToScreen(context, 'Income Tracking'),
            ),
            ListTile(
              leading: Icon(Icons.remove_circle_outline),
              title: Text('Expense Tracking'),
              onTap: () => _navigateToScreen(context, 'Expense Tracking'),
            ),
            ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Investment Tracking'),
              onTap: () => _navigateToScreen(context, 'Investment Tracking'),
            ),
            ListTile(
              leading: Icon(Icons.assessment_outlined),
              title: Text('Review'),
              onTap: () => _navigateToScreen(context, 'Review'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Welcome to Finance Tracker',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Open the menu to get started',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Quick Summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('Income'),
                            Text(
                              '${_incomeHistory.length}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Expenses'),
                            Text(
                              '${_expenseHistory.length}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Investments'),
                            Text(
                              '${_investmentHistory.length}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (expensesByCategory.isNotEmpty) ...[
              SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expenses by Category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Total: \$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...expensesByCategory.entries.map((entry) {
                        final percentage = (entry.value / total * 100).toStringAsFixed(1);
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '\$${entry.value.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$percentage%',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: entry.value / total,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}