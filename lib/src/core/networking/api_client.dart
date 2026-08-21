import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_exception.dart';
import 'dio_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  String _normalizePath(String path) {
    if (path.isEmpty) return path;
    return path.startsWith('/') ? path.substring(1) : path;
  }

  Future<T> getJson<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _normalizePath(path),
        queryParameters: queryParameters,
      );
      return _coerceResponse<T>(
        response.data,
        statusCode: response.statusCode,
        contentType: response.headers.value('content-type'),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> postJson<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
      );
      return _coerceResponse<T>(
        response.data,
        statusCode: response.statusCode,
        contentType: response.headers.value('content-type'),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> putJson<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
      );
      return _coerceResponse<T>(
        response.data,
        statusCode: response.statusCode,
        contentType: response.headers.value('content-type'),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> deleteJson<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        _normalizePath(path),
        data: data,
        queryParameters: queryParameters,
      );
      return _coerceResponse<T>(
        response.data,
        statusCode: response.statusCode,
        contentType: response.headers.value('content-type'),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  dynamic _tryDecodeJson(dynamic data) {
    if (data is String) {
      var trimmed = data.trim();
      if (trimmed.startsWith('\uFEFF')) {
        trimmed = trimmed.substring(1);
      }
      try {
        return jsonDecode(trimmed);
      } catch (_) {}
    }
    return data;
  }

  T _coerceResponse<T>(
    dynamic data, {
    required int? statusCode,
    required String? contentType,
  }) {
    final normalized = _tryDecodeJson(data);
    try {
      return normalized as T;
    } catch (_) {
      final isHtml = normalized is String && normalized.trimLeft().startsWith('<');
      final isNotJsonContentType =
          contentType != null && !contentType.toLowerCase().contains('application/json');

      final message = (isHtml || isNotJsonContentType) ? 'err_server' : 'err_unknown';
      throw ApiException(statusCode: statusCode, message: message);
    }
  }

  ApiException _mapDioException(DioException e) {
    final status = e.response?.statusCode;

    dynamic body = e.response?.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {}
    }

    final parsed = _parseLaravelError(body);
    final message = _friendlyMessage(
      statusCode: status,
      dioException: e,
      serverMessage: parsed.message,
    );
    final validation = parsed.validationErrors;

    return ApiException(
      statusCode: status,
      message: message,
      validationErrors: validation,
    );
  }

  String _friendlyMessage({
    required int? statusCode,
    required DioException dioException,
    required String? serverMessage,
  }) {
    if (statusCode == null) {
      switch (dioException.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'err_timeout';
        case DioExceptionType.connectionError:
        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
          return 'err_network';
        case DioExceptionType.cancel:
          return 'err_cancelled';
        case DioExceptionType.badResponse:
          break;
      }
    }

    if (statusCode == 401) return 'err_unauthorized';
    if (statusCode == 403) return 'err_forbidden';
    if (statusCode == 404) return 'err_not_found';
    if (statusCode != null && statusCode >= 301 && statusCode <= 308) return 'err_unauthorized';
    if (statusCode != null && statusCode >= 500) return 'err_server';

    return serverMessage ?? dioException.message ?? 'err_unknown';
  }

  _LaravelError _parseLaravelError(dynamic body) {
    if (body is Map<String, dynamic>) {
      final message = body['message']?.toString();

      final errors = body['errors'];
      if (errors is Map<String, dynamic>) {
        final mapped = <String, List<String>>{};
        for (final entry in errors.entries) {
          final v = entry.value;
          if (v is List) {
            mapped[entry.key] = v.map((e) => e.toString()).toList();
          } else if (v != null) {
            mapped[entry.key] = [v.toString()];
          }
        }
        return _LaravelError(message: message, validationErrors: mapped);
      }

      if (body['success'] == false) {
        final m = body['message']?.toString();
        final errors2 = body['errors'];
        if (errors2 is Map<String, dynamic>) {
          final mapped = <String, List<String>>{};
          for (final entry in errors2.entries) {
            final v = entry.value;
            if (v is List) {
              mapped[entry.key] = v.map((e) => e.toString()).toList();
            } else if (v != null) {
              mapped[entry.key] = [v.toString()];
            }
          }
          return _LaravelError(message: m ?? message, validationErrors: mapped);
        }
        return _LaravelError(message: m ?? message);
      }

      return _LaravelError(message: message);
    }

    return const _LaravelError(message: null);
  }
}

class _LaravelError {
  const _LaravelError({required this.message, this.validationErrors});

  final String? message;
  final Map<String, List<String>>? validationErrors;
}
