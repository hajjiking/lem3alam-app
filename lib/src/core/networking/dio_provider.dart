import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage(ref.watch(secureStorageProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final defaultHeaders = <String, String>{
    'Accept': 'application/json',
    if (!kIsWeb) 'User-Agent': 'Mozilla/5.0',
  };

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      followRedirects: false,
      maxRedirects: 0,
      headers: defaultHeaders,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          final contentType = response.headers.value('content-type');
          debugPrint(
            'HTTP ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri} ($contentType)',
          );
          if (contentType != null && !contentType.toLowerCase().contains('application/json')) {
            final data = response.data;
            var preview = '';
            if (data is String) {
              preview = data.trimLeft();
              if (preview.length > 300) preview = preview.substring(0, 300);
            } else if (data != null) {
              try {
                preview = jsonEncode(data);
                if (preview.length > 300) preview = preview.substring(0, 300);
              } catch (_) {}
            }
            if (preview.isNotEmpty) {
              debugPrint('HTTP NON-JSON PREVIEW: $preview');
            }
          }
        }
        handler.next(response);
      },
      onError: (e, handler) {
        if (kDebugMode) {
          final status = e.response?.statusCode;
          final contentType = e.response?.headers.value('content-type');
          final data = e.response?.data;
          var preview = '';
          if (data is String) {
            preview = data.trimLeft();
            if (preview.length > 200) preview = preview.substring(0, 200);
          } else if (data != null) {
            try {
              preview = jsonEncode(data);
              if (preview.length > 200) preview = preview.substring(0, 200);
            } catch (_) {}
          }
          debugPrint(
            'HTTP ERROR $status ${e.requestOptions.method} ${e.requestOptions.uri} ($contentType) ${e.type} ${preview.isEmpty ? '' : preview}',
          );
        }
        handler.next(e);
      },
    ),
  );

  return dio;
});
