import 'package:flutter/material.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../core/auth/auth_guard.dart';
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

  // Dashboard is public; Shipments, Wallet, and Profile are protected by AuthGuard
  final List<Widget> _pages = const [
    DashboardPage(),
    AuthGuard(
      title: 'Track Your Shipments',
      subtitle:
          'Log in to view live parcels, waybills, cargo flight status, and arrival milestones in real-time.',
      illustrationPath: 'assets/svg/illust_delivery.svg',
      featureBadge: 'LIVE SHIPMENTS',
      features: [
        'Real-time Flight & Sea Cargo Tracking',
        'Waybill & Customs Clearance Documents',
        'Instant Push Arrival Notifications',
      ],
      child: ShipmentsListPage(),
    ),
    AuthGuard(
      title: 'Access Your Wallet',
      subtitle:
          'Log in to check your RMB & NGN balances, view transaction statements, and swap currencies instantly.',
      illustrationPath: 'assets/svg/illust_exchange.svg',
      featureBadge: 'MULTI-CURRENCY WALLET',
      features: [
        'Live RMB & NGN Balances',
        'Instant Currency Swaps & Alipay Payouts',
        'Transparent Rates with Zero Hidden Fees',
      ],
      child: WalletPage(),
    ),
    AuthGuard(
      title: 'Account & Settings',
      subtitle:
          'Log in to manage your profile, saved warehouse addresses, and security preferences.',
      illustrationPath: 'assets/svg/illust_procurement.svg',
      featureBadge: 'MY ACCOUNT',
      features: [
        'China & Global Warehouse Addresses',
        '2FA & Security Controls',
        'Dedicated Priority Support',
      ],
      child: ProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
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
