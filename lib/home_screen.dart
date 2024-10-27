import 'package:flutter/material.dart';
import 'income_tracking_screen.dart';
import 'expense_tracking_screen.dart';
import 'savings_tracking_screen.dart';  // Import the SavingsTrackingScreen

class HomeScreen extends StatelessWidget {
  final int userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeScreenContent(userId: userId);
  }
}

class HomeScreenContent extends StatefulWidget {
  final int userId;

  const HomeScreenContent({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: AppDrawer(userId: widget.userId),
      body: const HomeContent(),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final int userId;

  const AppDrawer({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth * 0.5,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red[600],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.red),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Username',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.dashboard, 'Report', null),
          _buildDrawerItem(context, Icons.home, 'Home', () {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: {'userId': userId},
            );
          }),
          _buildDrawerItem(context, Icons.favorite, 'Savings', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SavingsTrackingScreen(userId: userId),
              ),
            );
          }),
          _buildDrawerItem(context, Icons.show_chart, 'Investments', null),
          _buildDrawerItem(context, Icons.money, 'Expenses', () {
            Navigator.pushNamed(
              context,
              '/expenses',
              arguments: {'userId': userId},
            );
          }),
          _buildDrawerItem(context, Icons.account_balance_wallet, 'Income', () {
            Navigator.pushNamed(
              context,
              '/income',
              arguments: {'userId': userId},
            );
          }),
          _buildDrawerItem(context, Icons.settings, 'Settings', null),
          const Divider(),
          _buildDrawerItem(context, Icons.logout, 'Sign Out', () {
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Budget Used',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircularIndicator(64, 'Current Week', Colors.green),
              _buildCircularIndicator(40, 'Last Week', Colors.red),
              _buildCircularIndicator(90, 'Last Month', Colors.blue),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Savings Tracker',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            height: 100,
            color: Colors.grey[300],
            child: const Center(child: Text('Savings Chart Placeholder')),
          ),
          const SizedBox(height: 30),
          const Text(
            'Expenses',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildExpenseItem('Food & Drink', 120.42),
          _buildExpenseItem('Car Payment', 980.76),
          _buildExpenseItem('Credit Card', 420.83),
        ],
      ),
    );
  }

  Widget _buildCircularIndicator(double percent, String label, Color color) {
    return Column(
      children: [
        CircularProgressIndicator(
          value: percent / 100,
          color: color,
        ),
        const SizedBox(height: 5),
        Text('$percent%', style: TextStyle(color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildExpenseItem(String name, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
