import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_errors.dart';
import '../../../../core/network/dio_client.dart';
import '../models/clearance_request_model.dart';

abstract class ClearanceRemoteDataSource {
  Future<List<ClearanceRequestModel>> getClearanceRequests({String? status});
  Future<ClearanceRequestModel> getClearanceRequestById(String id);
  Future<ClearanceRequestModel> createClearanceRequest(
    ClearanceRequestModel request,
  );
  Future<ClearanceRequestModel> payClearanceCharges(String id);
  Future<ClearanceDocument> uploadClearanceDocument(
    String id,
    ClearanceDocument document,
  );
  Future<ClearanceMessage> sendClearanceMessage(
    String id,
    String message, {
    String? attachmentUrl,
  });
  Future<ClearanceRequestModel> cancelClearanceRequest(
    String id, {
    String? reason,
  });
  Future<String> uploadFile(File file);
}

class ClearanceRemoteDataSourceImpl implements ClearanceRemoteDataSource {
  final Dio _dio;

  ClearanceRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ClearanceRequestModel>> getClearanceRequests({
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null &&
          status.trim().isNotEmpty &&
          status.toLowerCase() != 'all') {
        queryParams['status'] = status.trim();
      }

      Response<dynamic> response;
      try {
        response = await _dio.get<dynamic>(
          '/clearance/requests',
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.get<dynamic>(
            '/clearance',
            queryParameters: queryParams.isNotEmpty ? queryParams : null,
          );
        } else {
          rethrow;
        }
      }

      final data = response.data;
      List<dynamic> list = [];

      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['requests'] is List) {
          list = data['requests'] as List;
        } else if (data['rows'] is List) {
          list = data['rows'] as List;
        } else if (data['result'] is List) {
          list = data['result'] as List;
        } else if (data['items'] is List) {
          list = data['items'] as List;
        } else if (data['clearanceRequests'] is List) {
          list = data['clearanceRequests'] as List;
        } else if (data['data'] is Map) {
          final inner = data['data'] as Map;
          if (inner['requests'] is List) {
            list = inner['requests'] as List;
          } else if (inner['rows'] is List) {
            list = inner['rows'] as List;
          } else if (inner['result'] is List) {
            list = inner['result'] as List;
          } else if (inner['items'] is List) {
            list = inner['items'] as List;
          } else if (inner['clearanceRequests'] is List) {
            list = inner['clearanceRequests'] as List;
          } else if (inner['data'] is List) {
            list = inner['data'] as List;
          }
        }
      }

      final List<ClearanceRequestModel> result = [];
      for (final item in list) {
        if (item is Map) {
          try {
            result.add(
              ClearanceRequestModel.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (_) {}
        }
      }

      return result;
    } on DioException catch (e) {
      throw e.error ??
          NetworkError(e.message ?? 'Failed to load clearance requests');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<ClearanceRequestModel> getClearanceRequestById(String id) async {
    try {
      Response<dynamic> response;
      try {
        response = await _dio.get<dynamic>('/clearance/requests/$id');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.get<dynamic>('/clearance/$id');
        } else {
          rethrow;
        }
      }
      final data = response.data;
      Map<String, dynamic>? json;
      if (data is Map) {
        final candidate =
            data['data'] ?? data['request'] ?? data['clearanceRequest'] ?? data;
        if (candidate is Map) {
          json = Map<String, dynamic>.from(candidate);
        }
      }

      if (json != null) {
        return ClearanceRequestModel.fromJson(json);
      }
      throw ApiError('Failed to parse clearance request details');
    } on DioException catch (e) {
      throw e.error ??
          NetworkError(e.message ?? 'Failed to load clearance details');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<ClearanceRequestModel> createClearanceRequest(
    ClearanceRequestModel request,
  ) async {
    try {
      final payload = request.toJson();
      Response<dynamic> response;
      try {
        response = await _dio.post<dynamic>(
          '/clearance/requests',
          data: payload,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.post<dynamic>(
            '/clearance',
            data: payload,
          );
        } else {
          rethrow;
        }
      }

      final data = response.data;
      if (data is Map) {
        final candidate = data['data'] ?? data['request'] ?? data['clearanceRequest'] ?? data;
        if (candidate is Map) {
          final serverModel = ClearanceRequestModel.fromJson(
            Map<String, dynamic>.from(candidate),
          );
          // Preserve client-entered items, documents, and address if server returned summary
          return serverModel.copyWith(
            items: serverModel.items.isNotEmpty
                ? serverModel.items
                : request.items,
            documents: serverModel.documents.isNotEmpty
                ? serverModel.documents
                : request.documents,
            deliveryAddress:
                serverModel.deliveryAddress ?? request.deliveryAddress,
            deliveryPreference: serverModel.deliveryPreference.isNotEmpty
                ? serverModel.deliveryPreference
                : request.deliveryPreference,
            status: serverModel.status == ClearanceStatus.draft
                ? ClearanceStatus.submitted
                : serverModel.status,
          );
        }
      }

      return request.copyWith(status: ClearanceStatus.submitted);
    } on DioException catch (e) {
      throw e.error ??
          NetworkError(e.message ?? 'Failed to submit clearance request');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<ClearanceRequestModel> payClearanceCharges(String id) async {
    try {
      final response = await _dio.post<dynamic>('/clearance/requests/$id/pay');
      final data = response.data;
      if (data is Map) {
        final candidate = data['data'] ?? data['request'] ?? data;
        if (candidate is Map) {
          return ClearanceRequestModel.fromJson(
            Map<String, dynamic>.from(candidate),
          );
        }
      }

      throw ApiError('Payment successful but failed to parse updated request');
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Payment failed');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<ClearanceDocument> uploadClearanceDocument(
    String id,
    ClearanceDocument document,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        '/clearance/requests/$id/documents',
        data: {
          'documentType': document.documentType,
          'fileName': document.fileName,
          'fileUrl': document.fileUrl,
          'status': document.status,
          'note': document.note,
          'isMissingNoted': document.isNotAvailable,
        },
      );

      final data = response.data;
      Map<String, dynamic>? json;
      if (data is Map<String, dynamic>) {
        final candidate = data['data'] ?? data['document'] ?? data;
        if (candidate is Map<String, dynamic>) {
          json = candidate;
        }
      }

      if (json != null) {
        return ClearanceDocument.fromJson(json);
      }
      return document;
    } on DioException catch (e) {
      throw e.error ??
          NetworkError(e.message ?? 'Failed to upload document to request');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<ClearanceMessage> sendClearanceMessage(
    String id,
    String message, {
    String? attachmentUrl,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/clearance/requests/$id/messages',
        data: {
          'message': message,
          if (attachmentUrl != null && attachmentUrl.isNotEmpty)
            'attachmentUrl': attachmentUrl,
        },
      );

      final data = response.data;
      Map<String, dynamic>? json;
      if (data is Map<String, dynamic>) {
        final candidate = data['data'] ?? data['message'] ?? data;
        if (candidate is Map<String, dynamic>) {
          json = candidate;
        }
      }

      if (json != null) {
        return ClearanceMessage.fromJson(json);
      }
      return ClearanceMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        clearanceRequestId: id,
        senderType: 'customer',
        senderName: 'You',
        message: message,
        attachmentUrl: attachmentUrl,
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to send message');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<ClearanceRequestModel> cancelClearanceRequest(
    String id, {
    String? reason,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/clearance/requests/$id/cancel',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );

      final data = response.data;
      Map<String, dynamic>? json;
      if (data is Map<String, dynamic>) {
        final candidate = data['data'] ?? data['request'] ?? data;
        if (candidate is Map<String, dynamic>) {
          json = candidate;
        }
      }

      if (json != null) {
        return ClearanceRequestModel.fromJson(json);
      }
      throw ApiError('Failed to parse cancelled request');
    } on DioException catch (e) {
      throw e.error ?? NetworkError(e.message ?? 'Failed to cancel request');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }

  @override
  Future<String> uploadFile(File file) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post<dynamic>(
        '/upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          final nested = data['data'] as Map<String, dynamic>;
          return nested['url']?.toString() ??
              nested['secure_url']?.toString() ??
              '';
        }
        if (data['data'] is String) {
          return data['data'] as String;
        }
        if (data['url'] != null) {
          return data['url'].toString();
        }
        if (data['secure_url'] != null) {
          return data['secure_url'].toString();
        }
      }
      return '';
    } on DioException catch (e) {
      throw e.error ??
          NetworkError(e.message ?? 'Failed to upload document file');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final clearanceRemoteDataSourceProvider = Provider<ClearanceRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return ClearanceRemoteDataSourceImpl(dio);
});
