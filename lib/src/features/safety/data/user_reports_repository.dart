import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/user_report.dart';

final userReportsRepositoryProvider = Provider<UserReportsRepository>((ref) {
  return UserReportsRepository(
    api: ref.watch(apiClientProvider),
    readAuth: () => ref.read(authControllerProvider),
    expireSession: () =>
        ref.read(authControllerProvider.notifier).expireSession(),
  );
});

class UserReportsRepository {
  UserReportsRepository({
    required this.api,
    required this.readAuth,
    required this.expireSession,
  });

  final ApiClient api;
  final AuthState Function() readAuth;
  final Future<void> Function() expireSession;

  Future<SubmittedUserReport> submit(UserReportDraft draft) async {
    final requested = readAuth().user;
    if (readAuth().status != AuthStatus.authenticated ||
        requested == null ||
        (!requested.isClient && !requested.isTasker) ||
        draft.reportedUserId <= 0 ||
        draft.reportedUserId == requested.id) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    try {
      final response = await api.postJson<Map<String, dynamic>>(
        'reports',
        data: draft.toJson(),
      );
      final current = readAuth().user;
      if (current?.id != requested.id || current?.role != requested.role) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      final data = response['data'];
      if (response['success'] != true || data is! Map) {
        throw const FormatException('Invalid report response');
      }
      final report = SubmittedUserReport.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
      if (report.reportedUserId != draft.reportedUserId) {
        throw const FormatException('Report target does not match request');
      }
      return report;
    } on ApiException catch (error) {
      if (error.statusCode == 401 && readAuth().user?.id == requested.id) {
        await expireSession();
      }
      rethrow;
    }
  }
}
