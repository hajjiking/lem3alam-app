import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({
    required this.statusCode,
    required this.body,
    required this.contentType,
  });

  final int statusCode;
  final String body;
  final String contentType;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    );
  }
}

void main() {
  test('throws err_server when server returns HTML with 200 for JSON endpoint', () async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://example.invalid/',
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
      ),
    );
    dio.httpClientAdapter = _FakeAdapter(
      statusCode: 200,
      contentType: 'text/html; charset=UTF-8',
      body: '<html><body>blocked</body></html>',
    );

    final client = ApiClient(dio);

    await expectLater(
      () => client.getJson<Map<String, dynamic>>('tasks'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', 'err_server')
            .having((e) => e.statusCode, 'statusCode', 200),
      ),
    );
  });

  test('accepts JSON string even if content-type is not application/json', () async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://example.invalid/',
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
      ),
    );
    dio.httpClientAdapter = _FakeAdapter(
      statusCode: 200,
      contentType: 'text/html; charset=UTF-8',
      body: '{"success":true,"data":{"x":1}}',
    );

    final client = ApiClient(dio);
    final json = await client.getJson<Map<String, dynamic>>('tasks');
    expect((json['data'] as Map)['x'], 1);
  });

  test('throws err_server for non-JSON text when JSON map is expected', () async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://example.invalid/',
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
      ),
    );
    dio.httpClientAdapter = _FakeAdapter(
      statusCode: 200,
      contentType: 'text/plain; charset=UTF-8',
      body: 'ok',
    );

    final client = ApiClient(dio);

    await expectLater(
      () => client.getJson<Map<String, dynamic>>('tasks'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', 'err_server')
            .having((e) => e.statusCode, 'statusCode', 200),
      ),
    );
  });
}

