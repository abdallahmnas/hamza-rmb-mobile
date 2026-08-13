import 'package:flutter/material.dart';
import '../../../core/widgets/app_bottom_navigation.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Dashboard Placeholder')),
    Center(child: Text('Shipments Placeholder')),
    Center(child: Text('Wallet Placeholder')),
    Center(child: Text('Account Placeholder')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
