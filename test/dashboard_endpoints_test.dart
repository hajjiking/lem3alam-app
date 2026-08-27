import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/features/admin/data/admin_api.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/dashboard/data/dashboard_api.dart';
import 'package:lem3alam_mobile/src/features/dashboard/data/dashboard_repository_impl.dart';

class _Auth extends AuthController {
  @override
  AuthState build() => _state('client');

  void setRole(String role) => state = _state(role);

  AuthState _state(String role) => AuthState(
        status: AuthStatus.authenticated,
        user: User(
            id: 1,
            name: 'API Test',
            email: 'test@example.com',
            role: role,
            status: 'active',
            city: 'Rabat'),
      );
}

Map<String, dynamic> _dashboardResponse() => {
      'success': true,
      'data': {
        'stats': {
          'active_tasks': 1,
          'completed_tasks': 2,
          'pending_tasks': 1,
          'accepted_tasks': 0,
          'success_rate': 66.67,
        },
        'recent_tasks': <dynamic>[],
      },
    };

void main() {
  late Dio dio;
  late ApiClient client;
  late List<RequestOptions> requests;

  setUp(() {
    requests = [];
    dio = Dio(BaseOptions(baseUrl: 'https://example.com/public/api/v1/'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: options.path == 'admin/dashboard'
              ? {
                  'success': true,
                  'data': {'users_count': 3, 'tasks_count': 4}
                }
              : _dashboardResponse()));
    }));
    client = ApiClient(dio);
  });
  tearDown(() => dio.close(force: true));

  for (final audience in DashboardAudience.values) {
    test('GET ${audience.path} uses the configured API prefix', () async {
      final data = await DashboardApi(client).fetch(audience: audience);
      expect(data['success'], true);
      expect(requests.single.method, 'GET');
      expect(requests.single.uri.path, '/public/api/v1/${audience.path}');
      expect(requests.single.queryParameters, isEmpty);
    });
  }

  test('admin dashboard keeps its platform-wide response', () async {
    final response = await AdminApi(client).dashboard();
    expect(requests.single.method, 'GET');
    expect(requests.single.uri.path, '/public/api/v1/admin/dashboard');
    expect((response['data'] as Map)['users_count'], 3);
  });

  test('generic dashboard remains the default for direct API callers',
      () async {
    await DashboardApi(client).fetch();
    expect(requests.single.path, 'dashboard');
  });

  test('repository selects client/tasker endpoints as auth role changes',
      () async {
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      apiClientProvider.overrideWithValue(client),
    ]);
    addTearDown(container.dispose);
    final subscription =
        container.listen(dashboardRepositoryProvider, (previous, next) {});
    addTearDown(subscription.close);

    final clientStats =
        await container.read(dashboardRepositoryProvider).fetchDashboard();
    expect(clientStats.stats.successRate, 66.67);
    (container.read(authControllerProvider.notifier) as _Auth)
        .setRole('tasker');
    await container.read(dashboardRepositoryProvider).fetchDashboard();

    expect(requests.map((request) => request.path),
        ['client/dashboard', 'tasker/dashboard']);
  });

  for (final code in [401, 403, 404, 500]) {
    test('HTTP $code does not silently fall back to the generic endpoint',
        () async {
      dio.interceptors.clear();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        requests.add(options);
        handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
                requestOptions: options,
                statusCode: code,
                data: {'success': false, 'message': 'Dashboard unavailable'})));
      }));
      final repository = DashboardRepositoryImpl(DashboardApi(client),
          audience: DashboardAudience.client);
      await expectLater(
          repository.fetchDashboard(),
          throwsA(isA<ApiException>()
              .having((error) => error.statusCode, 'status', code)));
      expect(requests.map((request) => request.path), ['client/dashboard']);
    });
  }
}
