import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'income_tracking_screen.dart';
import 'expense_tracking_screen.dart';
import 'savings_tracking_screen.dart';
import 'report_screen.dart';
import 'investments_screen.dart';
import 'database_helper.dart';

class HomeScreen extends StatelessWidget {
  final int userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeScreenContent(userId: userId);
  }
}

class HomeScreenContent extends StatefulWidget {
  final int userId;

  const HomeScreenContent({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: AppDrawer(userId: widget.userId),
      body: HomeContent(userId: widget.userId),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final int userId;

  const AppDrawer({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final DatabaseHelper dbHelper = DatabaseHelper();

    return Drawer(
      width: screenWidth * 0.5,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<String?>(
            future: dbHelper.getUsername(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              }
              final username = snapshot.data ?? "Guest";
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.red[600],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      username,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildDrawerItem(context, Icons.dashboard, 'Report', () {
            Navigator.pushNamed(
              context,
              '/report',
              arguments: {'userId': userId},
            );
          }),
          _buildDrawerItem(context, Icons.home, 'Home', () {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: {'userId': userId},
            );
          }),
          _buildDrawerItem(context, Icons.favorite, 'Savings', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SavingsTrackingScreen(userId: userId),
              ),
            );
          }),
          _buildDrawerItem(context, Icons.show_chart, 'Investments', () {
            Navigator.pushNamed(
              context,
              '/investments',
              arguments: {'userId': userId},
            );
          }),
          _buildDrawerItem(context, Icons.money, 'Expenses', () {
            Navigator.pushNamed(
              context,
              '/expenses',
              arguments: {'userId': userId},
            );
          }),
          _buildDrawerItem(context, Icons.account_balance_wallet, 'Income', () {
            Navigator.pushNamed(
              context,
              '/income',
              arguments: {'userId': userId},
            );
          }),
          _buildDrawerItem(context, Icons.settings, 'Settings', null),
          const Divider(),
          _buildDrawerItem(context, Icons.logout, 'Sign Out', () {
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}

class HomeContent extends StatefulWidget {
  final int userId;

  const HomeContent({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>>? _recentExpenses;
  Map<String, dynamic>? _budgetData;
  List<Map<String, dynamic>>? _savingsData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Get current date and date ranges
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final lastMonthStart = DateTime(now.year, now.month - 1, now.day);

    // Load expenses data
    final allExpenses = await _dbHelper.getUserExpenses(
      widget.userId,
      startDate: null,
      endDate: null,
    );

    // Sort expenses by date and take last 3
    final recentExpenses = List<Map<String, dynamic>>.from(allExpenses)
      ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String))
      ..take(3);

    // Filter expenses for different periods
    final currentWeekExpenses = allExpenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      return expenseDate.isAfter(currentWeekStart) && expenseDate.isBefore(now);
    }).toList();

    final lastWeekExpenses = allExpenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      return expenseDate.isAfter(lastWeekStart) && expenseDate.isBefore(currentWeekStart);
    }).toList();

    final lastMonthExpenses = allExpenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      return expenseDate.isAfter(lastMonthStart) && expenseDate.isBefore(now);
    }).toList();

    // Get savings data for the chart
    final savingsData = await _dbHelper.getUserSavings(widget.userId);

    // Calculate budget usage percentages
    const weeklyBudget = 1000.0;  // Example budget values
    const monthlyBudget = 4000.0;

    double currentWeekTotal = currentWeekExpenses.fold(0.0, (sum, expense) => sum + (expense['amount'] as num));
    double lastWeekTotal = lastWeekExpenses.fold(0.0, (sum, expense) => sum + (expense['amount'] as num));
    double lastMonthTotal = lastMonthExpenses.fold(0.0, (sum, expense) => sum + (expense['amount'] as num));

    if (mounted) {
      setState(() {
        _recentExpenses = recentExpenses;
        _budgetData = {
          'currentWeek': (currentWeekTotal / weeklyBudget * 100).clamp(0, 100),
          'lastWeek': (lastWeekTotal / weeklyBudget * 100).clamp(0, 100),
          'lastMonth': (lastMonthTotal / monthlyBudget * 100).clamp(0, 100),
        };
        _savingsData = savingsData;
      });
    }
  }

  Widget _buildCircularIndicator(double percent, String label, Color color) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(
            value: percent / 100,
            color: color,
            backgroundColor: Colors.grey[200],
            strokeWidth: 8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: TextStyle(color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSavingsChart() {
    if (_savingsData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_savingsData!.isEmpty) {
      return const Center(child: Text('No savings data available'));
    }

    final barGroups = _savingsData!.asMap().entries.map((entry) {
      final saving = entry.value;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: saving['amount'].toDouble(),
            color: Colors.grey[400],
            width: 12,
          ),
          BarChartRodData(
            toY: saving['target_amount']?.toDouble() ?? 0,
            color: Colors.red[400],
            width: 12,
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _savingsData!.fold(0.0, (max, saving) => 
            math.max(max, math.max(
              saving['amount'].toDouble(),
              saving['target_amount']?.toDouble() ?? 0
            ))
          ) * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _savingsData!.length) {
                    final date = DateTime.parse(_savingsData![value.toInt()]['last_updated']);
                    return Text('${date.month}/${date.day}');
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('\$${value.toInt()}');
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildExpenseItem(String category, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Budget Used',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_budgetData != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCircularIndicator(
                    _budgetData!['currentWeek'],
                    'Current Week',
                    Colors.green,
                  ),
                  _buildCircularIndicator(
                    _budgetData!['lastWeek'],
                    'Last Week',
                    Colors.red,
                  ),
                  _buildCircularIndicator(
                    _budgetData!['lastMonth'],
                    'Last Month',
                    Colors.blue,
                  ),
                ],
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 30),
            const Text(
              'Savings Tracker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: _buildSavingsChart(),
            ),
            const SizedBox(height: 30),
            const Text(
              'Recent Expenses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_recentExpenses != null && _recentExpenses!.isNotEmpty)
              Column(
                children: _recentExpenses!.map((expense) {
                  return _buildExpenseItem(
                    expense['category'] as String,
                    expense['amount'] as double,
                  );
                }).toList(),
              )
            else if (_recentExpenses != null && _recentExpenses!.isEmpty)
              const Text('No recent expenses')
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
