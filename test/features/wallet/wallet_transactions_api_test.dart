import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamza_rmb/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:hamza_rmb/features/wallet/data/models/transaction_model.dart';

class MockAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;

  MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('TransactionModel Unit Tests', () {
    test('Correctly parses nested and alternative transaction fields', () {
      final json = <String, dynamic>{
        'id': 'tx-999',
        'title': 'Customs Duty Payment',
        'type': 'debit',
        'amount': '150,000.50',
        'currency': 'NGN',
        'status': 'completed',
        'reference': 'CLR-REF-101',
        'createdAt': '2026-09-30T14:30:00.000Z',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.id, equals('tx-999'));
      expect(model.title, equals('Customs Duty Payment'));
      expect(model.amount, equals(150000.50));
      expect(model.isCredit, isFalse);
      expect(model.reference, equals('CLR-REF-101'));
      expect(model.status, equals('completed'));
    });

    test('Correctly identifies credit types and string amounts with currency signs', () {
      final json = <String, dynamic>{
        '_id': 'tx-1000',
        'description': 'Direct Bank Deposit',
        'transactionType': 'topup',
        'amount': '₦250000',
        'currency': 'NGN',
        'paymentStatus': 'success',
        'txRef': 'DEP-7721',
        'date': '2026-09-30T10:00:00.000Z',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.id, equals('tx-1000'));
      expect(model.title, equals('Direct Bank Deposit'));
      expect(model.amount, equals(250000.0));
      expect(model.isCredit, isTrue);
      expect(model.reference, equals('DEP-7721'));
    });
  });

  group('WalletRemoteDataSource.fetchTransactions Envelope Tests', () {
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://hamza-rmb.onrender.com/api/v1'));
    });

    test('Unpacks standard {status: success, data: [ ... ]} envelope', () async {
      dio.httpClientAdapter = MockAdapter((options) {
        if (options.path.contains('/wallet/transactions')) {
          return ResponseBody.fromString(
            '{"status":"success","data":[{"id":"tx-1","title":"Deposit","type":"credit","amount":50000,"status":"completed"}]}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not found', 404);
      });

      final dataSource = WalletRemoteDataSourceImpl(dio);
      final result = await dataSource.fetchTransactions();

      expect(result.length, equals(1));
      expect(result.first.id, equals('tx-1'));
      expect(result.first.amount, equals(50000.0));
      expect(result.first.isCredit, isTrue);
    });

    test('Unpacks nested {data: {transactions: [ ... ]}} envelope', () async {
      dio.httpClientAdapter = MockAdapter((options) {
        if (options.path.contains('/wallet/transactions')) {
          return ResponseBody.fromString(
            '{"status":"success","data":{"transactions":[{"id":"tx-2","title":"Exchange CNY","type":"exchange","amount":100000,"status":"completed"}]}}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not found', 404);
      });

      final dataSource = WalletRemoteDataSourceImpl(dio);
      final result = await dataSource.fetchTransactions();

      expect(result.length, equals(1));
      expect(result.first.id, equals('tx-2'));
      expect(result.first.title, equals('Exchange CNY'));
      expect(result.first.amount, equals(100000.0));
    });
  });
}
