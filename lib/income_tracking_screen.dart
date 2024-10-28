import 'package:flutter/material.dart';
import 'database_helper.dart';

class IncomeTrackingScreen extends StatefulWidget {
  final List<IncomeEntry> initialHistory;

  const IncomeTrackingScreen({
    Key? key,
    this.initialHistory = const [],
  }) : super(key: key);

  @override
  _IncomeTrackingScreenState createState() => _IncomeTrackingScreenState();
}

class _IncomeTrackingScreenState extends State<IncomeTrackingScreen> {
  final TextEditingController _incomeController = TextEditingController();
  late List<IncomeEntry> _incomeHistory;
  String? _errorMessage;
  IncomeEntry? _editingEntry;
  String _selectedFrequency = 'Daily';
  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly', 'One-time'];

  @override
  void initState() {
    super.initState();
    _incomeHistory = List.from(widget.initialHistory);
  }
  void _cancelEditing() {
  setState(() {
    _incomeController.clear();
    _editingEntry = null;
    _errorMessage = null;
  });
}

bool _isValidNumber(String input) {
  return double.tryParse(input) != null;
}

void _editIncome(IncomeEntry entry) {
  setState(() {
    _incomeController.text = entry.amount.toString();
    _editingEntry = entry;
    _selectedFrequency = entry.frequency;
  });
}


  void _addOrUpdateIncome() {
  String input = _incomeController.text;

  if (_isValidNumber(input)) {
    setState(() {
      if (_editingEntry != null) {
        // Update existing entry
        final index = _incomeHistory.indexOf(_editingEntry!);
        final newEntry = IncomeEntry(
          amount: double.parse(input),
          date: DateTime.now(),
          frequency: _selectedFrequency,
        );
        _incomeHistory[index] = newEntry;
        // Update in database
        DatabaseHelper().insertIncome(newEntry);
        _editingEntry = null;
      } else {
        // Add new entry
        final newEntry = IncomeEntry(
          amount: double.parse(input),
          date: DateTime.now(),
          frequency: _selectedFrequency,
        );
        _incomeHistory.insert(0, newEntry);
        // Save to database
        DatabaseHelper().insertIncome(newEntry);
      }

      // Reset form
      _incomeController.clear();
      _selectedFrequency = 'Daily';
      _errorMessage = null;
    });
  } else {
    setState(() {
      _errorMessage = "Please enter a valid number.";
    });
  }
}

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_incomeHistory);
        return false;
      },
      child: Scaffold(
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
      ),
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
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
}
