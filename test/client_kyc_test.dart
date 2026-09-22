import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/profile/data/client_kyc_api.dart';
import 'package:lem3alam_mobile/src/features/profile/data/client_kyc_repository.dart';
import 'package:lem3alam_mobile/src/features/profile/domain/client_kyc.dart';

AuthState identity() => const AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: 20,
        name: 'Amina',
        email: 'amina@example.com',
        role: 'client',
        status: 'active',
        city: 'Rabat',
      ),
    );

class KycApiClient extends ApiClient {
  KycApiClient() : super(Dio());
  final submissions = <FormData>[];
  List<Map<String, dynamic>> documents = [];

  @override
  Future<T> getJson<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    expectSync(path, 'kyc/documents');
    return {
      'success': true,
      'data': {
        'is_verified': false,
        'verified_at': null,
        'documents': documents,
      }
    } as T;
  }

  @override
  Future<T> postJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    expectSync(path, 'kyc/documents');
    submissions.add(data! as FormData);
    documents = [
      {
        'id': 7,
        'type': 'passport',
        'status': 'pending',
        'submitted_at': '2026-09-22T01:00:00Z',
      }
    ];
    return {
      'success': true,
      'data': {'document': documents.first}
    } as T;
  }
}

ClientKycRepository repository(KycApiClient api) => ClientKycRepository(
      api: ClientKycApi(api),
      readAuth: identity,
      expireSession: () async {},
    );

void main() {
  test('maps verification status and rejection reason', () {
    final overview = KycOverview.fromJson({
      'is_verified': false,
      'documents': [
        {
          'id': 8,
          'type': 'id_card',
          'status': 'rejected',
          'rejection_reason': 'Image is blurry',
        }
      ],
    });
    expect(overview.latest?.type, KycDocumentType.idCard);
    expect(overview.latest?.status, 'rejected');
    expect(overview.latest?.rejectionReason, 'Image is blurry');
  });

  test('submits a validated document and reloads pending status', () async {
    final api = KycApiClient();
    final overview = await repository(api).submit(KycSubmission(
      type: KycDocumentType.passport,
      fileName: 'passport.pdf',
      bytes: Uint8List.fromList([1, 2, 3]),
    ));
    expect(
      api.submissions.single.fields
          .firstWhere((field) => field.key == 'type')
          .value,
      'passport',
    );
    expect(api.submissions.single.files.single.key, 'document');
    expect(overview.latest?.status, 'pending');
  });

  test('rejects unsupported documents before upload', () async {
    final api = KycApiClient();
    await expectLater(
      repository(api).submit(KycSubmission(
        type: KycDocumentType.idCard,
        fileName: 'identity.txt',
        bytes: Uint8List.fromList([1]),
      )),
      throwsA(isA<ApiException>()),
    );
    expect(api.submissions, isEmpty);
  });
}
