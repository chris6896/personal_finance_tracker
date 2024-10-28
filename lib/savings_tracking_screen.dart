import 'package:flutter/material.dart';
import 'database_helper.dart';

class SavingsTrackingScreen extends StatefulWidget {
  final int userId;

  const SavingsTrackingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SavingsTrackingScreenState createState() => _SavingsTrackingScreenState();
}

class _SavingsTrackingScreenState extends State<SavingsTrackingScreen> {
  final TextEditingController _savingsController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<SavingsEntry> _savingsHistory = [];
  String? _errorMessage;
  SavingsEntry? _editingEntry;
  String _selectedInterval = 'Daily';
  final List<String> _intervals = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    final db = DatabaseHelper();
    final savingsList = await db.getUserSavings(widget.userId);
    setState(() {
      _savingsHistory = savingsList.map((savings) => SavingsEntry.fromMap(savings)).toList();
    });
  }

  Future<void> _addOrUpdateSavings() async {
    String input = _savingsController.text;
    String targetInput = _targetAmountController.text;

    if (_isValidNumber(input) && _isValidNumber(targetInput)) {
      final amount = double.parse(input);
      final targetAmount = double.parse(targetInput);

      // Check if the savings amount exceeds the target amount
      if (amount > targetAmount) {
        setState(() {
          _errorMessage = "Savings amount exceeds target amount.";
        });
        return;
      }
      final interval = _selectedInterval.isNotEmpty ? _selectedInterval : 'Daily';
      final savingsData = {
        'amount': amount,
        'interval': interval,
        'target_amount': targetAmount,
        'description': _descriptionController.text,
        'last_updated': DateTime.now().toIso8601String(),
        'user_id': widget.userId,
      };

      final db = DatabaseHelper();

      // If editing, update the existing entry
      if (_editingEntry != null) {
        await db.updateSavings(_editingEntry!.id, savingsData);
        _editingEntry = null;
      } else {
        // Add new entry
        await db.insertSavings(widget.userId, savingsData);
      }

      // Reload savings after addition/update
      _loadSavings();
      _resetForm();
    } else {
      setState(() {
        _errorMessage = "Please enter valid numbers for amount and target amount.";
      });
    }
  }

  Future<void> _deleteSavings(SavingsEntry entry) async {
    final db = DatabaseHelper();
    await db.deleteSavings(entry.id);
    _loadSavings();
  }

  bool _isValidNumber(String input) {
    final number = double.tryParse(input);
    return number != null && number > 0;
  }

  void _editSavings(SavingsEntry entry) {
    setState(() {
      _editingEntry = entry;
      _savingsController.text = entry.amount.toString();
      _targetAmountController.text = entry.targetAmount.toString();
      _descriptionController.text = entry.description;
      _selectedInterval = entry.interval;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingEntry = null;
      _savingsController.clear();
      _targetAmountController.clear();
      _descriptionController.clear();
      _selectedInterval = 'Daily';
      _errorMessage = null;
    });
  }

  void _resetForm() {
    setState(() {
      _savingsController.clear();
      _targetAmountController.clear();
      _descriptionController.clear();
      _selectedInterval = 'Daily';
      _errorMessage = null;
      _editingEntry = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _savingsController.dispose();
    _targetAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Savings Tracking'),
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
                      _editingEntry != null ? 'Edit Savings' : 'Add Savings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _savingsController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$',
                        errorText: _errorMessage,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _targetAmountController,
                      decoration: InputDecoration(
                        labelText: 'Target Amount',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedInterval,
                      decoration: InputDecoration(
                        labelText: 'Interval',
                        border: OutlineInputBorder(),
                      ),
                      items: _intervals.map((interval) {
                        return DropdownMenuItem(
                          value: interval,
                          child: Text(interval),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedInterval = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addOrUpdateSavings,
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
                itemCount: _savingsHistory.length,
                itemBuilder: (context, index) {
                  final entry = _savingsHistory[index];
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
                      subtitle: Text(
                        '${entry.description}\n${_formatDate(entry.date)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editSavings(entry),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteSavings(entry);
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

class SavingsEntry {
  final int id;
  final DateTime date;
  final double amount;
  final double targetAmount;
  final String interval;
  final String description;

  SavingsEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.targetAmount,
    required this.interval,
    required this.description,
  });

  static SavingsEntry fromMap(Map<String, dynamic> map) {
    return SavingsEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      targetAmount: map['target_amount'] ?? 0.0,
      interval: map['interval'],
      description: map['description'] ?? '',
    );
  }
}
