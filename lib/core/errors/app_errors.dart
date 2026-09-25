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

class UnauthorizedError extends ApiError {
  UnauthorizedError([super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}

class StorageError extends AppError {
  StorageError(super.message);
}

class ValidationError extends AppError {
  ValidationError(super.message);
}

class UnknownError extends AppError {
  UnknownError(super.message);
}

