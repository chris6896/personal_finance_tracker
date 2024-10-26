import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';
import 'home_screen.dart';
import 'income_tracking_screen.dart';
import 'expense_tracking_screen.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
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
      initialRoute: '/login',
      routes: {
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return HomeScreen(userId: args['userId']);
        },
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/income': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return IncomeTrackingScreen(userId: args['userId']);
        },
        '/expenses': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ExpenseTrackingScreen(userId: args['userId']);
        },
      },
    );
  }
}
