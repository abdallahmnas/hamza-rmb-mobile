import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/features/account/data/datasources/support_remote_data_source.dart';
import 'package:hamza_rmb/features/account/data/models/ticket_model.dart';

class MockHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late SupportRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://hamza-rmb.onrender.com/api/v1'));
    dataSource = SupportRemoteDataSourceImpl(dio);
  });

  group('Support Ticket Reply & Model Tests', () {
    test('TicketModel parses sample response from POST api/v1/support/', () {
      final sampleJson = {
        "id": "0822547a-0bbc-4261-b583-8f9cd3ed87d2",
        "customerId": "HZ-20260922-2212",
        "customerName": "Mr Ab",
        "subject": "9876543210",
        "category": "other",
        "status": "open",
        "priority": "urgent",
        "referenceId": null,
        "imageUrl": null,
        "attachments": [],
        "createdAt": "2026-09-24T01:51:36.911Z",
        "updatedAt": "2026-09-24T01:51:36.911Z"
      };

      final ticket = TicketModel.fromJson(sampleJson);

      expect(ticket.id, '0822547a-0bbc-4261-b583-8f9cd3ed87d2');
      expect(ticket.customerId, 'HZ-20260922-2212');
      expect(ticket.customerName, 'Mr Ab');
      expect(ticket.subject, '9876543210');
      expect(ticket.category, 'other');
      expect(ticket.status, 'open');
      expect(ticket.priority, 'urgent');
      expect(ticket.referenceId, isNull);
      expect(ticket.imageUrl, isNull);
      expect(ticket.attachments, isEmpty);
      expect(ticket.createdAt, DateTime.parse("2026-09-24T01:51:36.911Z"));
      expect(ticket.updatedAt, DateTime.parse("2026-09-24T01:51:36.911Z"));
    });

    test('replyTicket posts FormData with ticketId and message to /support',
        () async {
      final responsePayload = {
        "success": true,
        "data": {
          "id": "0822547a-0bbc-4261-b583-8f9cd3ed87d2",
          "customerId": "HZ-20260922-2212",
          "customerName": "Mr Ab",
          "subject": "9876543210",
          "category": "other",
          "status": "open",
          "priority": "urgent",
          "referenceId": null,
          "imageUrl": null,
          "attachments": [],
          "createdAt": "2026-09-24T01:51:36.911Z",
          "updatedAt": "2026-09-24T01:51:36.911Z"
        }
      };

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        expect(options.path, '/support');
        expect(options.method, 'POST');
        expect(options.data, isA<FormData>());
        final formData = options.data as FormData;
        final fields = Map.fromEntries(formData.fields);
        expect(fields['ticketId'], '0822547a-0bbc-4261-b583-8f9cd3ed87d2');
        expect(fields['message'], 'Awsome');

        return ResponseBody.fromString(
          jsonEncode(responsePayload),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await dataSource.replyTicket(
        ticketId: '0822547a-0bbc-4261-b583-8f9cd3ed87d2',
        message: 'Awsome',
      );

      expect(result.id, '0822547a-0bbc-4261-b583-8f9cd3ed87d2');
      expect(result.customerId, 'HZ-20260922-2212');
      expect(result.customerName, 'Mr Ab');
      expect(result.status, 'open');
      expect(result.priority, 'urgent');
    });
  });
}
