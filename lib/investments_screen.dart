import 'package:flutter/material.dart';
import 'database_helper.dart';

class InvestmentsScreen extends StatefulWidget {
  final int userId;

  const InvestmentsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _InvestmentsScreenState createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  List<Map<String, dynamic>> _investmentList = [];

  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInvestments();
  }

  Future<void> _loadInvestments() async {
    final db = DatabaseHelper();
    final investments = await db.getInvestments();
    setState(() {
      _investmentList = investments;
    });
  }

  Future<void> _addInvestment() async {
    if (_isValidInput()) {
      final db = DatabaseHelper();
      final investmentData = {
        'asset_name': _assetNameController.text,
        'quantity': double.parse(_quantityController.text),
        'value': double.parse(_valueController.text),
        'last_updated': DateTime.now().toIso8601String(),
      };
      await db.insertInvestment(investmentData);
      _resetForm();
      _loadInvestments();
    } else {
      setState(() {
        _errorMessage = "Please enter valid input for all fields.";
      });
    }
  }

  bool _isValidInput() {
    final quantity = double.tryParse(_quantityController.text);
    final value = double.tryParse(_valueController.text);
    return _assetNameController.text.isNotEmpty && quantity != null && value != null && quantity > 0 && value > 0;
  }

  void _resetForm() {
    _assetNameController.clear();
    _quantityController.clear();
    _valueController.clear();
    _errorMessage = null;
  }

  @override
  void dispose() {
    _assetNameController.dispose();
    _quantityController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadInvestments,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInvestmentForm(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildInvestmentList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Add New Investment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _assetNameController,
              decoration: const InputDecoration(
                labelText: 'Asset Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Unit Value',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addInvestment,
              child: const Text('Add Investment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentList() {
    return ListView.builder(
      itemCount: _investmentList.length,
      itemBuilder: (context, index) {
        final investment = _investmentList[index];
        final assetName = investment['asset_name'];
        final quantity = investment['quantity'];
        final value = investment['value'];
        final totalValue = quantity * value;

        return Card(
          child: ListTile(
            title: Text(assetName),
            subtitle: Text(
              'Quantity: $quantity\nUnit Value: \$${value.toStringAsFixed(2)}\nTotal Value: \$${totalValue.toStringAsFixed(2)}',
            ),
          ),
        );
      },
    );
  }
}
