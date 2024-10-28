import 'package:flutter/material.dart';
import 'expense_tracking_screen.dart';
import 'income_tracking_screen.dart';
import 'investments_screen.dart';

class ReviewScreen extends StatelessWidget {
  final List<ExpenseEntry> expenseHistory;
  final List<IncomeEntry> incomeHistory;
  final List<InvestmentEntry> investmentHistory;

  const ReviewScreen({
    Key? key,
    required this.expenseHistory,
    required this.incomeHistory,
    required this.investmentHistory,
  }) : super(key: key);

  double get totalIncome {
    return incomeHistory.fold(0, (sum, entry) => sum + entry.amount);
  }

  double get totalExpenses {
    return expenseHistory.fold(0, (sum, entry) => sum + entry.amount);
  }

  double get totalInvestments {
    return investmentHistory.fold(0, (sum, entry) => sum + (entry.amount * entry.quantity));
  }

  double get balance {
    return totalIncome - totalExpenses;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, double> _calculateExpensesByCategory() {
    final Map<String, double> categoryTotals = {};
    for (var expense in expenseHistory) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  Map<String, double> _calculateIncomeByFrequency() {
    final Map<String, double> frequencyTotals = {};
    for (var income in incomeHistory) {
      frequencyTotals[income.frequency] = (frequencyTotals[income.frequency] ?? 0) + income.amount;
    }
    return frequencyTotals;
  }

  Map<String, double> _calculateInvestmentsByType() {
    final Map<String, double> typeTotals = {};
    for (var investment in investmentHistory) {
      typeTotals[investment.type] = (typeTotals[investment.type] ?? 0) + (investment.amount * investment.quantity);
    }
    return typeTotals;
  }

  @override
  Widget build(BuildContext context) {
    final expensesByCategory = _calculateExpensesByCategory();
    final incomeByFrequency = _calculateIncomeByFrequency();
    final investmentsByType = _calculateInvestmentsByType();

    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Review'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SummaryItem(
                          label: 'Total Income',
                          amount: totalIncome,
                          color: Colors.green,
                        ),
                        _SummaryItem(
                          label: 'Total Expenses',
                          amount: totalExpenses,
                          color: Colors.red,
                        ),
                        _SummaryItem(
                          label: 'Total Investments',
                          amount: totalInvestments,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _SummaryItem(
                      label: 'Balance',
                      amount: balance,
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            if (expensesByCategory.isNotEmpty) ...[
              Text(
                'Expenses by Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: expensesByCategory.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final category = expensesByCategory.keys.elementAt(index);
                    final amount = expensesByCategory[category]!;
                    final percentage = (amount / totalExpenses * 100).toStringAsFixed(1);
                    
                    return ListTile(
                      title: Text(category),
                      subtitle: LinearProgressIndicator(
                        value: amount / totalExpenses,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${amount.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('$percentage%'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (investmentsByType.isNotEmpty) ...[
              SizedBox(height: 24),
              Text(
                'Investments by Type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: investmentsByType.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final type = investmentsByType.keys.elementAt(index);
                    final amount = investmentsByType[type]!;
                    final percentage = (amount / totalInvestments * 100).toStringAsFixed(1);
                    
                    return ListTile(
                      title: Text(type),
                      subtitle: LinearProgressIndicator(
                        value: amount / totalInvestments,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${amount.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('$percentage%'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: 24),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final allTransactions = [
                    ...expenseHistory.map((e) => _Transaction(
                          date: e.date,
                          amount: -e.amount,
                          description: e.category,
                          type: 'expense',
                        )),
                    ...incomeHistory.map((i) => _Transaction(
                          date: i.date,
                          amount: i.amount,
                          description: i.frequency,
                          type: 'income',
                        )),
                    ...investmentHistory.map((inv) => _Transaction(
                          date: inv.date,
                          amount: inv.amount * inv.quantity,
                          description: '${inv.name} (${inv.type})',
                          type: 'investment',
                        )),
                  ]..sort((a, b) => b.date.compareTo(a.date));

                  if (index >= allTransactions.length) return null;

                  final transaction = allTransactions[index];
                  final color = switch (transaction.type) {
                    'expense' => Colors.red,
                    'income' => Colors.green,
                    'investment' => Colors.purple,
                    _ => Colors.grey,
                  };
                  final icon = switch (transaction.type) {
                    'expense' => Icons.remove_circle,
                    'income' => Icons.add_circle,
                    'investment' => Icons.trending_up,
                    _ => Icons.circle,
                  };

                  return ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(
                      '\$${transaction.amount.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatDate(transaction.date)),
                        Text(transaction.description),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Transaction {
  final DateTime date;
  final double amount;
  final String description;
  final String type;

  _Transaction({
    required this.date,
    required this.amount,
    required this.description,
    required this.type,
  });
}