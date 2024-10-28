import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  final int userId;

  const ReportScreen({Key? key, required this.userId}) : super(key: key);

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(thickness: 2),
        ],
      ),
    );
  }

  Widget _buildReportItem(String date, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '\$$amount',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        _buildReportItem("1/1/2024 17:06PM", "2400.53"),
        _buildReportItem("1/2/2024 19:06PM", "1700.24"),
        _buildReportItem("2/3/2024 8:10AM", "1200.43"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combined Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportSection("Income"),
            const SizedBox(height: 16),
            _buildReportSection("Savings"),
            const SizedBox(height: 16),
            _buildReportSection("Investments"),
          ],
        ),
      ),
    );
  }
}
