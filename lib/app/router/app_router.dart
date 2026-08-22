import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/views/onboarding_page.dart';
import '../../features/splash/views/splash_page.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/shell/views/main_shell_page.dart';
import '../../features/shipments/views/shipments_list_page.dart';
import '../../features/exchange/views/exchange_page.dart';
import '../../features/procurement/views/buy_for_me_page.dart';
import '../../features/consolidation/views/consolidation_flow_page.dart';
import '../../features/consolidation/views/consolidation_review_page.dart';
import '../../features/wallet/views/transaction_details_page.dart';
import '../../features/warehouse/views/warehouse_addresses_page.dart';
import '../../features/pre_alert/views/pre_alert_page.dart';
import '../../features/pre_alert/views/pre_alert_history_page.dart';
import '../../features/account/views/support_tickets_page.dart';
import '../../features/account/views/ticket_details_page.dart';
import '../../features/account/views/new_ticket_page.dart';
import '../../features/account/views/settings_page.dart';
import '../../features/notifications/views/notifications_page.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const MainShellPage(),
    ),
    GoRoute(
      path: '/track',
      name: 'track',
      builder: (context, state) => const ShipmentsListPage(),
    ),
    GoRoute(
      path: '/exchange',
      name: 'exchange',
      builder: (context, state) => const ExchangePage(),
    ),
    GoRoute(
      path: '/buy-for-me',
      name: 'buyForMe',
      builder: (context, state) => const BuyForMePage(),
    ),
    GoRoute(
      path: '/consolidate',
      name: 'consolidate',
      builder: (context, state) => const ConsolidationFlowPage(),
    ),
    GoRoute(
      path: '/consolidation-review',
      name: 'consolidationReview',
      builder: (context, state) => const ConsolidationReviewPage(),
    ),
    GoRoute(
      path: '/transaction-details',
      name: 'transactionDetails',
      builder: (context, state) => const TransactionDetailsPage(),
    ),
    GoRoute(
      path: '/warehouse-addresses',
      name: 'warehouseAddresses',
      builder: (context, state) => const WarehouseAddressesPage(),
    ),
    GoRoute(
      path: '/pre-alert',
      name: 'preAlert',
      builder: (context, state) => const PreAlertPage(),
    ),
    GoRoute(
      path: '/pre-alert-history',
      name: 'preAlertHistory',
      builder: (context, state) => const PreAlertHistoryPage(),
    ),
    GoRoute(
      path: '/support-tickets',
      name: 'supportTickets',
      builder: (context, state) => const SupportTicketsPage(),
    ),
    GoRoute(
      path: '/ticket-details',
      name: 'ticketDetails',
      builder: (context, state) => const TicketDetailsPage(),
    ),
    GoRoute(
      path: '/new-ticket',
      name: 'newTicket',
      builder: (context, state) => const NewTicketPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
  ],
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found!'))),
);
