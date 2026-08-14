import 'package:flutter/material.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../app/theme/app_colors.dart';

import '../../dashboard/views/dashboard_page.dart';
import '../../shipments/views/shipments_list_page.dart';
import '../../wallet/views/wallet_page.dart';
import '../../account/views/profile_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ShipmentsListPage(),
    WalletPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
