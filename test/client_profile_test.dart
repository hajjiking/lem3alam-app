import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/profile/data/client_profile_api.dart';
import 'package:lem3alam_mobile/src/features/profile/data/client_profile_repository.dart';
import 'package:lem3alam_mobile/src/features/profile/domain/client_profile.dart';
import 'package:lem3alam_mobile/src/features/profile/presentation/client_profile_screen.dart';

AuthState clientIdentity([int id = 20]) => AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: id,
        name: 'Amina Idrissi',
        email: 'amina@example.com',
        role: 'client',
        status: 'active',
        city: 'Rabat',
      ),
    );

Map<String, dynamic> profileJson(
        {int id = 20, String name = 'Amina Idrissi'}) =>
    {
      'id': id,
      'name': name,
      'email': 'amina@example.com',
      'phone': '+212600000000',
      'role': 'client',
      'status': 'active',
      'city': 'Rabat',
      'location': 'Agdal, Rabat',
      'is_verified': true,
    };

class ProfileApiClient extends ApiClient {
  ProfileApiClient() : super(Dio());

  Map<String, dynamic> profile = profileJson();
  Map<String, dynamic>? updatePayload;
  Object? error;
  int avatarUploads = 0;
  int avatarDeletes = 0;
  FormData? avatarPayload;

  @override
  Future<T> getJson<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    if (error case final Object value) throw value;
    if (path == 'kyc/documents') {
      return {
        'success': true,
        'data': {
          'is_verified': false,
          'verified_at': null,
          'documents': const [],
        }
      } as T;
    }
    expectSync(path, 'profile');
    return {'success': true, 'data': profile} as T;
  }

  @override
  Future<T> putJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    expectSync(path, 'profile');
    if (error case final Object value) throw value;
    updatePayload = (data! as Map).cast<String, dynamic>();
    profile = {...profile, ...updatePayload!};
    return {'success': true, 'data': profile} as T;
  }

  @override
  Future<T> postJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    expectSync(path, 'profile/avatar');
    if (error case final Object value) throw value;
    avatarUploads++;
    avatarPayload = data! as FormData;
    profile = {...profile, 'avatar': '/storage/avatars/profile.png'};
    return {
      'success': true,
      'data': {'avatar_url': '/storage/avatars/profile.png'}
    } as T;
  }

  @override
  Future<T> deleteJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    expectSync(path, 'profile/avatar');
    if (error case final Object value) throw value;
    avatarDeletes++;
    profile = {...profile, 'avatar': null};
    return {'success': true, 'data': const {}} as T;
  }
}

ClientProfileRepository repository(
  ProfileApiClient client, {
  AuthState Function()? auth,
  Future<void> Function()? expire,
}) =>
    ClientProfileRepository(
      api: ClientProfileApi(client),
      readAuth: auth ?? clientIdentity,
      expireSession: expire ?? () async {},
    );

class TestAuthController extends AuthController {
  @override
  AuthState build() => clientIdentity();

  @override
  Future<void> logout() async => state = AuthState.unauthenticated;
}

void main() {
  test('profile model maps contact and verification fields', () {
    final profile = ClientProfile.fromJson(profileJson());
    expect(profile.id, 20);
    expect(profile.phone, '+212600000000');
    expect(profile.location, 'Agdal, Rabat');
    expect(profile.isVerified, isTrue);
  });

  test('repository loads and updates only the authenticated client profile',
      () async {
    final api = ProfileApiClient();
    final repo = repository(api);

    expect((await repo.load()).name, 'Amina Idrissi');
    final updated = await repo.update(const ClientProfileUpdate(
      name: ' Amina El Idrissi ',
      email: ' amina@example.com ',
      phone: ' +212611111111 ',
      location: ' Hay Riad ',
    ));

    expect(updated.name, 'Amina El Idrissi');
    expect(api.updatePayload, {
      'name': 'Amina El Idrissi',
      'email': 'amina@example.com',
      'phone': '+212611111111',
      'location': 'Hay Riad',
    });
  });

  test('repository rejects a profile belonging to another account', () async {
    final api = ProfileApiClient()..profile = profileJson(id: 99);
    await expectLater(repository(api).load(), throwsA(isA<FormatException>()));
  });

  test('repository expires the matching session on unauthorized response',
      () async {
    var expired = false;
    final api = ProfileApiClient()
      ..error =
          const ApiException(statusCode: 401, message: 'err_unauthorized');
    await expectLater(
      repository(api, expire: () async => expired = true).load(),
      throwsA(isA<ApiException>()),
    );
    expect(expired, isTrue);
  });

  test('repository uploads and removes a validated avatar', () async {
    final api = ProfileApiClient();
    final repo = repository(api);
    final uploaded = await repo.uploadAvatar(ClientAvatarFile(
      name: 'portrait.png',
      bytes: Uint8List.fromList([1, 2, 3]),
    ));

    expect(api.avatarUploads, 1);
    expect(api.avatarPayload?.files.single.key, 'avatar');
    expect(uploaded.avatarUrl, '/storage/avatars/profile.png');

    final removed = await repo.deleteAvatar();
    expect(api.avatarDeletes, 1);
    expect(removed.avatarUrl, isNull);
  });

  test('repository rejects an invalid avatar before upload', () async {
    final api = ProfileApiClient();
    await expectLater(
      repository(api).uploadAvatar(ClientAvatarFile(
        name: 'document.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      )),
      throwsA(isA<ApiException>()),
    );
    expect(api.avatarUploads, 0);
  });

  testWidgets('client can open and save the profile editor', (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = ProfileApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(TestAuthController.new),
          apiClientProvider.overrideWithValue(api),
          clientProfileRepositoryProvider.overrideWithValue(repository(api)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ClientProfileScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amina Idrissi'), findsOneWidget);
    expect(find.text('Verified account'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('client-profile-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a new photo'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Amina El Idrissi',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(api.updatePayload?['name'], 'Amina El Idrissi');
    expect(find.text('Profile updated successfully.'), findsOneWidget);
  });
}
