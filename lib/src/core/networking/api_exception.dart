class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, List<String>>? validationErrors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.validationErrors,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

