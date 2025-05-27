// import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'CMS Donasi',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeScreen(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'screens/dashboard_screen.dart';
// import 'screens/donations_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'E-Donate CMS',
//       theme: ThemeData(
//         primaryColor: Color(0xFF4D5BFF),
//         scaffoldBackgroundColor: Colors.grey[100],
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MainTabView(),
//     );
//   }
// }

// class MainTabView extends StatefulWidget {
//   @override
//   _MainTabViewState createState() => _MainTabViewState();
// }

// class _MainTabViewState extends State<MainTabView> {
//   int _currentIndex = 0;
//   final _pages = [
//     DashboardScreen(),
//     DonationsScreen(),

//   ];

//   // final _titles = ['Dashboard', 'Donasi', 'Laporan', 'Uang Donasi'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         selectedItemColor: Color(0xFF4D5BFF),
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
//           BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Donasi'),
//           BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Laporan'),
//           BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Uang Donasi'),
//         ],
//         onTap: (i) => setState(() => _currentIndex = i),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'screens/dashboard_screen.dart';
import 'screens/donations_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/funds_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await initializeDateFormatting('id_ID'); 
  Intl.defaultLocale = 'id_ID';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => MaterialApp(
        title: 'E-Donate CMS',
        theme: ThemeData(
          primaryColor: Color(0xFF4D5BFF),
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: MainTabView(),
      );
}

class MainTabView extends StatefulWidget {
  @override
  _MainTabViewState createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;
  final _pages = [
    DashboardScreen(),
    DonationsScreen(),
    ReportsScreen(),
    FundsScreen(),
  ];

  @override
  Widget build(BuildContext ctx) => Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Color(0xFF4D5BFF),
          unselectedItemColor: Colors.grey,
          items: [
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
