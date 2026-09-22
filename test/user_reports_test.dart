import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/safety/data/user_reports_repository.dart';
import 'package:lem3alam_mobile/src/features/safety/domain/user_report.dart';

AuthState identity([int id = 20]) => AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: id,
        name: 'Amina',
        email: 'amina@example.com',
        role: 'client',
        status: 'active',
        city: 'Rabat',
      ),
    );

class ReportsApi extends ApiClient {
  ReportsApi() : super(Dio());
  Map<String, dynamic>? payload;
  int responseTarget = 42;

  @override
  Future<T> postJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    expectSync(path, 'reports');
    payload = (data! as Map).cast<String, dynamic>();
    return {
      'success': true,
      'data': {
        'id': 9,
        'reporter_id': 20,
        'reported_user_id': responseTarget,
        'task_id': payload!['task_id'],
        'reason': payload!['reason'],
        'details': payload!['details'],
        'status': 'open',
      }
    } as T;
  }
}

UserReportsRepository repository(ReportsApi api,
        {AuthState Function()? auth}) =>
    UserReportsRepository(
      api: api,
      readAuth: auth ?? identity,
      expireSession: () async {},
    );

void main() {
  test('submits a scoped user report with trimmed optional details', () async {
    final api = ReportsApi();
    final report = await repository(api).submit(const UserReportDraft(
      reportedUserId: 42,
      taskId: 7,
      reason: ReportReason.fraud,
      details: '  Requested payment outside the app  ',
    ));

    expect(report.status, 'open');
    expect(api.payload, {
      'reported_user_id': 42,
      'task_id': 7,
      'reason': 'fraud',
      'details': 'Requested payment outside the app',
    });
  });

  test('rejects self-reporting before the request', () async {
    final api = ReportsApi();
    await expectLater(
      repository(api).submit(const UserReportDraft(
        reportedUserId: 20,
        reason: ReportReason.other,
        details: '',
      )),
      throwsA(isA<ApiException>()),
    );
    expect(api.payload, isNull);
  });

  test('rejects a response for a different report target', () async {
    final api = ReportsApi()..responseTarget = 99;
    await expectLater(
      repository(api).submit(const UserReportDraft(
        reportedUserId: 42,
        reason: ReportReason.spam,
        details: '',
      )),
      throwsA(isA<FormatException>()),
    );
  });
}
