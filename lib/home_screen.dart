import 'package:flutter/material.dart';
import 'income_tracking_screen.dart';
import 'expense_tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedPage,
              hint: Text('Select a page'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPage = newValue;
                });
                if (newValue == 'Income Tracking') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncomeTrackingScreen(),
                    ),
                  );
                } else if (newValue == 'Expense Tracking') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpenseTrackingScreen(),
                    ),
                  );
                }
              },
              items: <String>['Income Tracking', 'Expense Tracking']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
