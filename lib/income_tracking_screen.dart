import 'package:flutter/material.dart';

class IncomeTrackingScreen extends StatefulWidget {
  @override
  _IncomeTrackingScreenState createState() => _IncomeTrackingScreenState();
}

class _IncomeTrackingScreenState extends State<IncomeTrackingScreen> {
  final TextEditingController _incomeController = TextEditingController();
  List<Map<String, String>> _incomeHistory = [];
  String? _errorMessage;
  int? _editIndex;

  // Add Income function
  void _addIncome() {
    String input = _incomeController.text;

    // Validate if the input is a valid number
    if (_isValidNumber(input)) {
      setState(() {
        if (_editIndex != null) {
          // If editing, update the existing entry
          _incomeHistory[_editIndex!] = {
            'date': DateTime.now().toString(),
            'amount': input,
          };
          _editIndex = null; // Reset editing index
        } else {
          // Otherwise, insert a new entry
          _incomeHistory.insert(0, {
            'date': DateTime.now().toString(),
            'amount': input,
          });
        }
        _incomeController.clear();
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

  // Edit an existing income entry
  void _editIncome(int index) {
    setState(() {
      _incomeController.text = _incomeHistory[index]['amount']!;
      _editIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Tracking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Income', style: TextStyle(fontSize: 18)),
                ElevatedButton(
                  onPressed: _addIncome,
                  child: Text(_editIndex == null ? 'Add' : 'Update'), // Change button text if editing
                ),
              ],
            ),
            TextField(
              controller: _incomeController,
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
                itemCount: _incomeHistory.length,
                itemBuilder: (context, index) {
                  var entry = _incomeHistory[index];
                  return ListTile(
                    title: Text(entry['date']!),
                    trailing: Text('\$${entry['amount']}'),
                    onTap: () {
                      _editIncome(index); // Trigger editing mode on tap
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
