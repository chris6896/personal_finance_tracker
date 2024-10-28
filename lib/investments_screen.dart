import 'package:flutter/material.dart';

class InvestmentsScreen extends StatelessWidget {
  final int userId;

  const InvestmentsScreen({Key? key, required this.userId}) : super(key: key);

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(thickness: 2),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPieChart() {
    return Container(
      height: 150,
      width: 150,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: Center(
        child: Text(
          'Pie Chart',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPlaceholderLineChart() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          'Line Chart',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCryptoListItem(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '\$$value',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Portfolio"),
            Row(
              children: [
                _buildLegendItem("Retirement", Colors.grey),
                const SizedBox(width: 16),
                _buildLegendItem("Stocks", Colors.yellow),
                const SizedBox(width: 16),
                _buildLegendItem("Cryptocurrency", Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            Center(child: _buildPlaceholderPieChart()),
            const SizedBox(height: 24),
            _buildSectionHeader("Watchlist"),
            Row(
              children: [
                _buildLegendItem("NVIDIA", Colors.grey),
                const SizedBox(width: 16),
                _buildLegendItem("AMD", Colors.pink),
                const SizedBox(width: 16),
                _buildLegendItem("INTL", Colors.brown),
              ],
            ),
            const SizedBox(height: 16),
            _buildPlaceholderLineChart(),
            const SizedBox(height: 24),
            _buildSectionHeader("Crypto"),
            _buildCryptoListItem("BTC", "120.42"),
            _buildCryptoListItem("DOGE", "980.76"),
            _buildCryptoListItem("USDC", "420.83"),
          ],
        ),
      ),
    );
  }
}
