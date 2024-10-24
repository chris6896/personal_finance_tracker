import 'package:flutter/material.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  @override
  _ExpenseTrackingScreenState createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  final TextEditingController _expenseController = TextEditingController();
  List<ExpenseEntry> _expenseHistory = [];
  String? _errorMessage;
  ExpenseEntry? _editingEntry;
  String _selectedCategory = 'Food and Drink';
  final List<String> _categories = [
    'Food and Drink',
    'Transportation',
    'Entertainment',
    'Bills',
    'Shopping',
    'Other'
  ];

  void _addOrUpdateExpense() {
    String input = _expenseController.text;

    if (_isValidNumber(input)) {
      setState(() {
        if (_editingEntry != null) {
          // Update existing entry
          final index = _expenseHistory.indexOf(_editingEntry!);
          _expenseHistory[index] = ExpenseEntry(
            amount: double.parse(input),
            date: DateTime.now(),
            category: _selectedCategory,
          );
          _editingEntry = null;
        } else {
          // Add new entry
          _expenseHistory.insert(0, ExpenseEntry(
            amount: double.parse(input),
            date: DateTime.now(),
            category: _selectedCategory,
          ));
        }

        // Reset form
        _expenseController.clear();
        _selectedCategory = 'Food and Drink';
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = "Please enter a valid number.";
      });
    }
  }

  bool _isValidNumber(String input) {
    final number = double.tryParse(input);
    return number != null && number > 0;
  }

  void _editExpense(ExpenseEntry entry) {
    setState(() {
      _editingEntry = entry;
      _expenseController.text = entry.amount.toString();
      _selectedCategory = entry.category;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingEntry = null;
      _expenseController.clear();
      _selectedCategory = 'Food and Drink';
      _errorMessage = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracking'),
        actions: [
          if (_editingEntry != null)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _cancelEditing,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _editingEntry != null ? 'Edit Expense' : 'Add Expense',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _expenseController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$',
                        errorText: _errorMessage,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addOrUpdateExpense,
                      child: Text(_editingEntry != null ? 'Update' : 'Add'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _expenseHistory.length,
                itemBuilder: (context, index) {
                  final entry = _expenseHistory[index];
                  final bool isEditing = _editingEntry == entry;

                  return Card(
                    color: isEditing ? Theme.of(context).colorScheme.primaryContainer : null,
                    child: ListTile(
                      leading: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                      ),
                      title: Text(
                        '\$${entry.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(entry.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            entry.category,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editExpense(entry),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _expenseHistory.removeAt(index);
                                if (_editingEntry == entry) {
                                  _cancelEditing();
                                }
                              });
                            },
                          ),
                        ],
                      ),
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

  @override
  void dispose() {
    _expenseController.dispose();
    super.dispose();
  }
}

class ExpenseEntry {
  final DateTime date;
  final double amount;
  final String category;

  ExpenseEntry({
    required this.date,
    required this.amount,
    required this.category,
  });
}


