abstract class AppError implements Exception {
  final String message;
  AppError(this.message);

  @override
  String toString() => message;
}

class NetworkError extends AppError {
  NetworkError(super.message);
}

class ApiError extends AppError {
  final int? statusCode;
  ApiError(super.message, {this.statusCode});
}

class StorageError extends AppError {
  StorageError(super.message);
}

class UnknownError extends AppError {
  UnknownError(super.message);
}
