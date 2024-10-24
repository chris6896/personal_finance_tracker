import 'package:flutter/material.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  @override
  _ExpenseTrackingScreenState createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  final TextEditingController _expenseController = TextEditingController();
  List<Map<String, String>> _expenseHistory = [];
  String? _errorMessage;
  int? _editIndex;

  // Add Expense function
  void _addExpense() {
    String input = _expenseController.text;

    // Validate if the input is a valid number
    if (_isValidNumber(input)) {
      setState(() {
        if (_editIndex != null) {
          // If editing, update the existing entry
          _expenseHistory[_editIndex!] = {
            'date': DateTime.now().toString(),
            'amount': input,
          };
          _editIndex = null; // Reset editing index
        } else {
          // Otherwise, insert a new entry
          _expenseHistory.insert(0, {
            'date': DateTime.now().toString(),
            'amount': input,
          });
        }
        _expenseController.clear();
        _errorMessage = null; // Clear any error messages
      });
    } else {
      // Show error if input is invalid
      setState(() {
        _errorMessage = "Please enter a valid number.";
      });
    }
  }

  // Check if input is a valid number
  bool _isValidNumber(String input) {
    final number = double.tryParse(input);
    return number != null;
  }

  // Edit an existing expense entry
  void _editExpense(int index) {
    setState(() {
      _expenseController.text = _expenseHistory[index]['amount']!;
      _editIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Expense', style: TextStyle(fontSize: 18)),
                ElevatedButton(
                  onPressed: _addExpense,
                  child: Text(_editIndex == null ? 'Add' : 'Update'), // Change button text if editing
                ),
              ],
            ),
            TextField(
              controller: _expenseController,
              decoration: InputDecoration(
                labelText: 'Add Value',
                errorText: _errorMessage, // Show error message if invalid input
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Text('History', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: _expenseHistory.length,
                itemBuilder: (context, index) {
                  var entry = _expenseHistory[index];
                  return ListTile(
                    title: Text(entry['date']!),
                    trailing: Text('\$${entry['amount']}'),
                    onTap: () {
                      _editExpense(index); // Trigger editing mode on tap
                    },
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


