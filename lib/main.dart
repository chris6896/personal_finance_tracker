import 'package:flutter/material.dart';
// HOME SCREEN
//
//
//

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HomeScreenContent();
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

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
            _scaffoldKey.currentState?.openDrawer();  // Use GlobalKey to open drawer
          },
        ),
      ),
      drawer: const AppDrawer(),  // Add a custom drawer
      body: const HomeContent(),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth * 0.5,  // Make drawer occupy 50% of screen width
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red[600], // Red background for the drawer header
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
          _buildDrawerItem(Icons.dashboard, 'Report'),
          _buildDrawerItem(Icons.home, 'Home'),
          _buildDrawerItem(Icons.favorite, 'Savings'),
          _buildDrawerItem(Icons.show_chart, 'Investments'),
          _buildDrawerItem(Icons.money, 'Expenses'),
          _buildDrawerItem(Icons.account_balance_wallet, 'Income'),
          _buildDrawerItem(Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title),
      onTap: () {
        // Handle navigation on tap
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
          Text('\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
//
//
//
//