import 'package:flutter/material.dart';
import 'database_helper.dart';

class ReportScreen extends StatefulWidget {
  final int userId;

  const ReportScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>>? _incomeData;
  List<Map<String, dynamic>>? _savingsData;
  List<Map<String, dynamic>>? _investmentsData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final income = await _dbHelper.getUserIncome(widget.userId);
    final savings = await _dbHelper.getUserSavings(widget.userId);
    final investments = await _dbHelper.getInvestments();

    setState(() {
      _incomeData = income;
      _savingsData = savings;
      _investmentsData = investments;
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildReportItem(String date, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '\$$amount',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(String title, List<Map<String, dynamic>>? data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        if (data == null)
          const Center(child: CircularProgressIndicator())
        else if (data.isEmpty)
          Text('No $title data available')
        else
          ...data.map((item) {
            String date = '';
            String amount = '0.00';
            
            if (title == 'Income') {
              date = item['date'] ?? '';
              amount = (item['amount'] ?? 0.0).toStringAsFixed(2);
            } else if (title == 'Savings') {
              date = item['last_updated'] ?? '';
              amount = (item['amount'] ?? 0.0).toStringAsFixed(2);
            } else if (title == 'Investments') {
              date = item['last_updated'] ?? '';
              amount = (item['total_value'] ?? 0.0).toStringAsFixed(2);
            }

            // Format the date string
            try {
              final dateTime = DateTime.parse(date);
              date = '${dateTime.month}/${dateTime.day}/${dateTime.year} '
                  '${dateTime.hour.toString().padLeft(2, '0')}:'
                  '${dateTime.minute.toString().padLeft(2, '0')}${dateTime.hour >= 12 ? 'PM' : 'AM'}';
            } catch (e) {
              print('Error parsing date: $e');
            }

            return _buildReportItem(date, amount);
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Combined Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportSection('Income', _incomeData),
              const SizedBox(height: 24),
              _buildReportSection('Savings', _savingsData),
              const SizedBox(height: 24),
              _buildReportSection('Investments', _investmentsData),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}