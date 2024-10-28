import 'package:flutter/material.dart';
import 'database_helper.dart';

class InvestmentsScreen extends StatefulWidget {
  final List<InvestmentEntry> initialInvestments;

  const InvestmentsScreen({
    Key? key,
    this.initialInvestments = const [],
  }) : super(key: key);

  @override
  _InvestmentsScreenState createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  late List<InvestmentEntry> _investmentHistory;
  String? _errorMessage;
  InvestmentEntry? _editingEntry;
  String _selectedType = 'Crypto';
  final List<String> _types = ['Crypto', 'Gold', 'Stocks', 'Bonds', 'Other'];

  @override
  void initState() {
    super.initState();
    _investmentHistory = List.from(widget.initialInvestments);
  }

  void _addOrUpdateInvestment() {
    String name = _nameController.text;
    String amountInput = _amountController.text;
    String quantityInput = _quantityController.text;

    if (name.isEmpty) {
      setState(() {
        _errorMessage = "Please enter an investment name.";
      });
      return;
    }

    if (!_isValidNumber(amountInput) || !_isValidNumber(quantityInput)) {
      setState(() {
        _errorMessage = "Please enter valid numbers for amount and quantity.";
      });
      return;
    }

    setState(() {
      if (_editingEntry != null) {
        // Update existing entry
        final index = _investmentHistory.indexOf(_editingEntry!);
        final newEntry = InvestmentEntry(
          name: name,
          amount: double.parse(amountInput),
          quantity: double.parse(quantityInput),
          type: _selectedType,
          date: DateTime.now(),
        );
        _investmentHistory[index] = newEntry;
        // Update in database
        DatabaseHelper().insertInvestment(newEntry);
        _editingEntry = null;
      } else {
        // Add new entry
        final newEntry = InvestmentEntry(
          name: name,
          amount: double.parse(amountInput),
          quantity: double.parse(quantityInput),
          type: _selectedType,
          date: DateTime.now(),
        );
        _investmentHistory.insert(0, newEntry);
        // Save to database
        DatabaseHelper().insertInvestment(newEntry);
      }

      // Reset form
      _nameController.clear();
      _amountController.clear();
      _quantityController.clear();
      _selectedType = 'Crypto';
      _errorMessage = null;
    });
  }

  bool _isValidNumber(String input) {
    final number = double.tryParse(input);
    return number != null && number > 0;
  }

  void _editInvestment(InvestmentEntry entry) {
    setState(() {
      _editingEntry = entry;
      _nameController.text = entry.name;
      _amountController.text = entry.amount.toString();
      _quantityController.text = entry.quantity.toString();
      _selectedType = entry.type;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingEntry = null;
      _nameController.clear();
      _amountController.clear();
      _quantityController.clear();
      _selectedType = 'Crypto';
      _errorMessage = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_investmentHistory);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Investment Tracking'),
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
                        _editingEntry != null ? 'Edit Investment' : 'Add Investment',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Investment Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount per Unit',
                          prefixText: '\$',
                          errorText: _errorMessage,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _types.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addOrUpdateInvestment,
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
                'Investment History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _investmentHistory.length,
                  itemBuilder: (context, index) {
                    final entry = _investmentHistory[index];
                    final bool isEditing = _editingEntry == entry;
                    final totalValue = entry.amount * entry.quantity;

                    return Card(
                      color: isEditing ? Theme.of(context).colorScheme.primaryContainer : null,
                      child: ListTile(
                        leading: Icon(
                          Icons.trending_up,
                          color: Colors.purple,
                        ),
                        title: Text(
                          entry.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.quantity} units @ \$${entry.amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Total: \$${totalValue.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${entry.type} - ${_formatDate(entry.date)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editInvestment(entry),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _investmentHistory.removeAt(index);
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
    _nameController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}

class InvestmentEntry {
  final String name;
  final double amount;
  final double quantity;
  final String type;
  final DateTime date;

  InvestmentEntry({
    required this.name,
    required this.amount,
    required this.quantity,
    required this.type,
    required this.date,
  });
}