// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'screens/dashboard_screen.dart';
import 'screens/donations_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/funds_screen.dart';
import 'screens/create_fund_record_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';
  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext ctx) => MaterialApp(
        title: 'E-Donate CMS',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          primaryColor: const Color(0xFF4D5BFF),
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        // keep the existing home property unchanged
        home: MainTabView(),
        // add routes without modifying existing functions
        routes: {
          '/uang-donasi/create': (ctx) => const CreateFundRecordScreen(),
        },
      );
}

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  _MainTabViewState createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;
  final _pages = [
    const DashboardScreen(),
    DonationsScreen(),
    ReportsScreen(),
    const FundsScreen(),
  ];

  @override
  Widget build(BuildContext ctx) => Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF4D5BFF),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Donasi'),
            BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart), label: 'Laporan'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet), label: 'Uang Donasi'),
          ],
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      );
}
