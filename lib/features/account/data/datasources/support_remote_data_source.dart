import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/ticket_model.dart';

abstract class SupportRemoteDataSource {
  Future<TicketModel> createTicket({
    required String subject,
    required String category,
    required String description,
    String? priority,
    String? message,
    String? referenceId,
    String? imageUrl,
    List<String>? attachments,
  });

  Future<List<TicketModel>> fetchTickets();

  Future<TicketModel> fetchTicketDetails(String id);

  Future<TicketModel> replyTicket({
    required String ticketId,
    required String message,
  });
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final Dio _dio;

  SupportRemoteDataSourceImpl(this._dio);

  @override
  Future<TicketModel> createTicket({
    required String subject,
    required String category,
    required String description,
    String? priority,
    String? message,
    String? referenceId,
    String? imageUrl,
    List<String>? attachments,
  }) async {
    try {
      final body = <String, dynamic>{
        'subject': subject,
        'category': category.toLowerCase(),
        'description': description,
        'message': message ?? description,
        if (priority != null && priority.isNotEmpty)
          'priority': priority.toLowerCase(),
        if (referenceId != null && referenceId.isNotEmpty)
          'referenceId': referenceId,
        if (imageUrl != null && imageUrl.isNotEmpty)
          'imageUrl': imageUrl,
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments,
      };
      final response = await _dio.post<dynamic>(
        '/support/tickets',
        data: body,
      );
      final data = response.data;
      if (data is Map) {
        final tJson = data['data'] ?? data;
        if (tJson is Map) {
          return TicketModel.fromJson(Map<String, dynamic>.from(tJson));
        }
      }
      return TicketModel(
        id: 'tck-${DateTime.now().millisecondsSinceEpoch}',
        subject: subject,
        category: category,
        description: description,
        priority: priority ?? 'medium',
        referenceId: referenceId,
        imageUrl: imageUrl,
        attachments: attachments ?? const [],
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to create ticket');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<List<TicketModel>> fetchTickets() async {
    try {
      final response = await _dio.get<dynamic>('/support/tickets');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map) {
        if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['tickets'] is List) {
          list = data['tickets'] as List;
        }
      } else if (data is List) {
        list = data;
      }
      return list
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => TicketModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load tickets');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<TicketModel> fetchTicketDetails(String id) async {
    try {
      final response = await _dio.get<dynamic>('/support/tickets/$id');
      final data = response.data;
      if (data is Map) {
        final tJson = data['data'] ?? data['ticket'] ?? data;
        if (tJson is Map) {
          return TicketModel.fromJson(Map<String, dynamic>.from(tJson));
        }
      }
      throw ApiError('Ticket not found');
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to load ticket details');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<TicketModel> replyTicket({
    required String ticketId,
    required String message,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/support/tickets/$ticketId/reply',
        data: {'message': message},
      );
      final data = response.data;
      if (data is Map) {
        final tJson = data['data'] ?? data['ticket'] ?? data;
        if (tJson is Map) {
          return TicketModel.fromJson(Map<String, dynamic>.from(tJson));
        }
      }
      return TicketModel(
        id: ticketId,
        subject: 'Support Ticket',
        description: message,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to send reply');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final supportRemoteDataSourceProvider =
    Provider<SupportRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return SupportRemoteDataSourceImpl(dio);
});
