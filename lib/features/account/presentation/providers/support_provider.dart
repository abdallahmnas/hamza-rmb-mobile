import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/support_remote_data_source.dart';
import '../../data/models/ticket_model.dart';

class SupportState {
  final List<TicketModel> tickets;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const SupportState({
    this.tickets = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  SupportState copyWith({
    List<TicketModel>? tickets,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return SupportState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class SupportNotifier extends Notifier<SupportState> {
  static const String _storageKey = 'cache_tickets';

  @override
  SupportState build() {
    final storage = ref.watch(localStorageProvider);
    List<TicketModel> cached = [];
    final json = storage.getString(_storageKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        cached = list
            .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return SupportState(tickets: cached, isLoading: cached.isEmpty);
  }

  Future<void> fetchTickets({bool isUserInitiated = false}) async {
    state = state.copyWith(isLoading: state.tickets.isEmpty && !isUserInitiated);
    try {
      final remote = ref.read(supportRemoteDataSourceProvider);
      final fresh = await remote.fetchTickets();
      final storage = ref.read(localStorageProvider);
      await storage.setString(
          _storageKey, jsonEncode(fresh.map((e) => e.toJson()).toList()));
      state = state.copyWith(tickets: fresh, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createTicket({
    required String subject,
    required String category,
    required String description,
    String? priority,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final remote = ref.read(supportRemoteDataSourceProvider);
      final newTicket = await remote.createTicket(
        subject: subject,
        category: category,
        description: description,
        priority: priority,
      );
      state = state.copyWith(
        tickets: [newTicket, ...state.tickets],
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  Future<TicketModel?> fetchTicketDetails(String id) async {
    try {
      final remote = ref.read(supportRemoteDataSourceProvider);
      final ticket = await remote.fetchTicketDetails(id);
      final updatedList = state.tickets.map((t) => t.id == id ? ticket : t).toList();
      if (!updatedList.any((t) => t.id == id)) {
        updatedList.insert(0, ticket);
      }
      state = state.copyWith(tickets: updatedList);
      return ticket;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> replyTicket({
    required String id,
    required String message,
  }) async {
    try {
      final remote = ref.read(supportRemoteDataSourceProvider);
      final newMsg = await remote.replyTicket(id: id, message: message);
      
      final updatedList = state.tickets.map((t) {
        if (t.id == id) {
          return TicketModel(
            id: t.id,
            subject: t.subject,
            category: t.category,
            description: t.description,
            status: t.status,
            priority: t.priority,
            createdAt: t.createdAt,
            messages: [...t.messages, newMsg],
          );
        }
        return t;
      }).toList();

      state = state.copyWith(tickets: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => fetchTickets(isUserInitiated: true);
}


final supportProvider =
    NotifierProvider<SupportNotifier, SupportState>(() {
  return SupportNotifier();
});
