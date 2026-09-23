import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/app_errors.dart';
import '../network/dio_client.dart';

abstract class MediaUploadService {
  Future<String> uploadImage(File imageFile);
}

class MediaUploadServiceImpl implements MediaUploadService {
  final Dio _dio;

  MediaUploadServiceImpl(this._dio);

  @override
  Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post<dynamic>(
        '/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          final nested = data['data'] as Map<String, dynamic>;
          return nested['url']?.toString() ?? nested['secure_url']?.toString() ?? '';
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
      throw e.error ?? NetworkError(e.message ?? 'Failed to upload image');
    } catch (e) {
      throw UnknownError(e.toString());
    }
  }
}

final mediaUploadServiceProvider = Provider<MediaUploadService>((ref) {
  final dio = ref.watch(dioProvider);
  return MediaUploadServiceImpl(dio);
});
