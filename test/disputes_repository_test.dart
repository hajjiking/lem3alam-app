import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/disputes/data/disputes_repository.dart';
import 'package:lem3alam_mobile/src/features/disputes/domain/dispute_draft.dart';

// Test transport only; the production provider always uses the authenticated API.
class CapturingApi extends ApiClient {
  CapturingApi() : super(Dio());
  Object? payload;
  String? path;
  Map<String, dynamic>? query;
  Object? failure;
  Map<String, dynamic> response = {
    'success': true,
    'data': {'id': 7, 'task_id': 10, 'respondent_id': 20}
  };
  @override
  Future<T> postJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    this.path = path;
    payload = data;
    if (failure != null) throw failure!;
    return response as T;
  }

  @override
  Future<T> getJson<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    this.path = path;
    query = queryParameters;
    return response as T;
  }
}

void main() {
  late CapturingApi api;
  late ApiDisputesRepository repository;
  late AuthState auth;
  late bool expired;
  const draft = DisputeDraft(
      taskId: 10,
      againstUserId: 20,
      disputeType: DisputeType.noShow,
      subject: 'Missed appointment',
      description: 'No one arrived.',
      additionalInfo: 'Please call.');
  setUp(() {
    api = CapturingApi();
    expired = false;
    auth = const AuthState(
        status: AuthStatus.authenticated,
        user: User(
            id: 1,
            name: 'Client',
            email: '',
            role: 'client',
            status: 'active',
            city: null));
    repository = ApiDisputesRepository(
        api: api,
        auth: () => auth,
        expireSession: () async {
          expired = true;
        });
  });
  test('sends every evidence file and notes in the API contract', () async {
    await repository.submit(draft.copyWith(evidenceFiles: [
      for (final name in ['a.png', 'b.pdf'])
        EvidenceFile(
            localPathOrUrl: name,
            fileName: name,
            fileType: EvidenceFileType.document,
            bytes: Uint8List.fromList([1, 2, 3]))
    ]));
    expect(api.path, 'disputes');
    final form = api.payload as FormData;
    expect(Map.fromEntries(form.fields), containsPair('type', 'no_show'));
    expect(Map.fromEntries(form.fields),
        containsPair('additional_info', 'Please call.'));
    expect(Map.fromEntries(form.fields), containsPair('task_id', '10'));
    expect(form.files.map((f) => f.key), ['evidence[]', 'evidence[]']);
    expect(form.files.map((f) => f.value.filename), ['a.png', 'b.pdf']);
  });
  test('rejects success without a matching persisted record', () async {
    api.response = {'success': true, 'data': {}};
    await expectLater(repository.submit(draft), throwsA(isA<ApiException>()));
    api.response = {
      'success': false,
      'data': {'id': 7}
    };
    await expectLater(repository.submit(draft), throwsA(isA<ApiException>()));
  });
  test('propagates API failures and expires unauthorized sessions', () async {
    api.failure =
        const ApiException(statusCode: 401, message: 'err_unauthorized');
    await expectLater(repository.submit(draft), throwsA(isA<ApiException>()));
    expect(expired, isTrue);
  });
  test('requires authentication before sending data', () async {
    auth = AuthState.unauthenticated;
    await expectLater(repository.submit(draft), throwsA(isA<ApiException>()));
    expect(api.payload, isNull);
  });
  test('reads paginated persisted disputes', () async {
    api.response = {
      'success': true,
      'data': {
        'current_page': 2,
        'last_page': 3,
        'data': [
          {
            'id': 7,
            'task_id': 10,
            'subject': 'Missed appointment',
            'description': 'No one arrived.',
            'status': 'open',
            'additional_info': 'Please call.'
          }
        ]
      }
    };
    final result = await repository.list(page: 2);
    expect(api.query, {'page': 2, 'per_page': 15});
    expect(result.items.single.id, 7);
    expect(result.page, 2);
    expect(result.lastPage, 3);
  });
}
