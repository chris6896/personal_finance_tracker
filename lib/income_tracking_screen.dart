import 'package:flutter/material.dart';
import 'database_helper.dart';

class IncomeTrackingScreen extends StatefulWidget {
  final int userId;

  IncomeTrackingScreen({required this.userId});

  @override
  _IncomeTrackingScreenState createState() => _IncomeTrackingScreenState();
}

class _IncomeTrackingScreenState extends State<IncomeTrackingScreen> {
  final TextEditingController _incomeController = TextEditingController();
  List<IncomeEntry> _incomeHistory = [];
  String? _errorMessage;
  IncomeEntry? _editingEntry;
  String _selectedFrequency = 'Daily';
  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly', 'One-time'];

  @override
  void initState() {
    super.initState();
    _loadIncome();
  }

  void _loadIncome() async {
    final db = DatabaseHelper();
    final incomeList = await db.getUserIncome(widget.userId);
    setState(() {
      _incomeHistory = incomeList.map((income) => IncomeEntry.fromMap(income)).toList();
    });
  }

  void _addOrUpdateIncome() async {
    String input = _incomeController.text;
    if (_isValidNumber(input)) {
      final amount = double.parse(input);
      final incomeData = {
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'frequency': _selectedFrequency,
      };
      final db = DatabaseHelper();

      if (_editingEntry != null) {
        // Update existing entry
        await db.insertIncome(widget.userId, incomeData);
      } else {
        // Add new entry
        await db.insertIncome(widget.userId, incomeData);
      }

      _loadIncome(); // Reload income after addition/update
      _resetForm();
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

  void _editIncome(IncomeEntry entry) {
    setState(() {
      _editingEntry = entry;
      _incomeController.text = entry.amount.toString();
      _selectedFrequency = entry.frequency;
    });
  }

  void _cancelEditing() {
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _incomeController.clear();
      _selectedFrequency = 'Daily';
      _errorMessage = null;
      _editingEntry = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Tracking'),
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
                      _editingEntry != null ? 'Edit Income' : 'Add Income',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _incomeController,
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
                      value: _selectedFrequency,
                      decoration: InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                      ),
                      items: _frequencies.map((frequency) {
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequency = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addOrUpdateIncome,
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
                itemCount: _incomeHistory.length,
                itemBuilder: (context, index) {
                  final entry = _incomeHistory[index];
                  final bool isEditing = _editingEntry == entry;

                  return Card(
                    color: isEditing ? Theme.of(context).colorScheme.primaryContainer : null,
                    child: ListTile(
                      leading: Icon(
                        Icons.add_circle,
                        color: Colors.green,
                      ),
                      title: Text(
                        '\$${entry.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
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
                            entry.frequency,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editIncome(entry),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _incomeHistory.removeAt(index);
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
}

class IncomeEntry {
  final DateTime date;
  final double amount;
  final String frequency;

  IncomeEntry({
    required this.date,
    required this.amount,
    required this.frequency,
  });

  static IncomeEntry fromMap(Map<String, dynamic> map) {
    return IncomeEntry(
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      frequency: map['frequency'],
    );
  }
}
