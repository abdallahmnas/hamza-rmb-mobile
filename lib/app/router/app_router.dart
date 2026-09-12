import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_guard.dart';
import '../../core/storage/local_storage.dart';
import '../../features/onboarding/views/onboarding_page.dart';
import '../../features/splash/views/splash_page.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/shell/views/main_shell_page.dart';
import '../../features/shipments/views/shipments_list_page.dart';
import '../../features/shipments/views/live_tracking_page.dart';
import '../../features/shipments/views/shipment_details_page.dart';
import '../../features/shipments/views/air_freight_details_page.dart';
import '../../features/shipments/views/sea_freight_details_page.dart';
import '../../features/exchange/views/exchange_page.dart';
import '../../features/exchange/views/exchange_review_page.dart';
import '../../features/exchange/models/exchange_review_data.dart';
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

/// Provider for the GoRouter — uses Riverpod so it can read onboarding state.
final appRouterProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(localStorageProvider);
  final onboardingCompleted =
      storage.getString('onboarding_completed') == 'true';

  return GoRouter(
    initialLocation: onboardingCompleted ? '/splash' : '/onboarding',
    routes: [
      // ── Public Routes ──────────────────────────────────────────────────
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
        path: '/live-tracking',
        name: 'liveTracking',
        builder: (context, state) => const LiveTrackingPage(),
      ),
      GoRoute(
        path: '/shipment-details',
        name: 'shipmentDetails',
        builder: (context, state) => const ShipmentDetailsPage(),
      ),
      GoRoute(
        path: '/air-freight',
        name: 'airFreight',
        builder: (context, state) => const AirFreightDetailsPage(),
      ),
      GoRoute(
        path: '/sea-freight',
        name: 'seaFreight',
        builder: (context, state) => const SeaFreightDetailsPage(),
      ),

      // ── Protected Routes ───────────────────────────────────────────────
      GoRoute(
        path: '/exchange',
        name: 'exchange',
        builder: (context, state) => const ExchangePage(),
        // AuthGuard(child: ExchangePage()),
      ),
      GoRoute(
        path: '/exchange-review',
        name: 'exchangeReview',
        builder: (context, state) {
          final data =
              state.extra as ExchangeReviewData? ??
              const ExchangeReviewData(
                sendAmount: '0',
                receiveAmount: '0',
                sendCurrency: 'NGN',
                receiveCurrency: 'CNY',
                exchangeRate: '',
                selectedPlatform: 'alipay',
                beneficiaryName: '',
                accountId: '',
              );
          return AuthGuard(child: ExchangeReviewPage(reviewData: data));
        },
      ),
      GoRoute(
        path: '/buy-for-me',
        name: 'buyForMe',
        builder: (context, state) => const AuthGuard(child: BuyForMePage()),
      ),
      GoRoute(
        path: '/consolidate',
        name: 'consolidate',
        builder: (context, state) =>
            const AuthGuard(child: ConsolidationFlowPage()),
      ),
      GoRoute(
        path: '/consolidation-review',
        name: 'consolidationReview',
        builder: (context, state) =>
            const AuthGuard(child: ConsolidationReviewPage()),
      ),
      GoRoute(
        path: '/transaction-details',
        name: 'transactionDetails',
        builder: (context, state) =>
            const AuthGuard(child: TransactionDetailsPage()),
      ),
      GoRoute(
        path: '/warehouse-addresses',
        name: 'warehouseAddresses',
        builder: (context, state) =>
            const AuthGuard(child: WarehouseAddressesPage()),
      ),
      GoRoute(
        path: '/pre-alert',
        name: 'preAlert',
        builder: (context, state) => const AuthGuard(child: PreAlertPage()),
      ),
      GoRoute(
        path: '/pre-alert-history',
        name: 'preAlertHistory',
        builder: (context, state) =>
            const AuthGuard(child: PreAlertHistoryPage()),
      ),
      GoRoute(
        path: '/support-tickets',
        name: 'supportTickets',
        builder: (context, state) =>
            const AuthGuard(child: SupportTicketsPage()),
      ),
      GoRoute(
        path: '/ticket-details',
        name: 'ticketDetails',
        builder: (context, state) =>
            const AuthGuard(child: TicketDetailsPage()),
      ),
      GoRoute(
        path: '/new-ticket',
        name: 'newTicket',
        builder: (context, state) => const AuthGuard(child: NewTicketPage()),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const AuthGuard(child: SettingsPage()),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) =>
            const AuthGuard(child: NotificationsPage()),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page not found!'))),
  );
});
